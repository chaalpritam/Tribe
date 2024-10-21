import React, {PropsWithChildren, useEffect, useState} from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  Image,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  PermissionsAndroid,
} from 'react-native';
import {launchImageLibrary} from 'react-native-image-picker';
import {IMAGE} from 'images';
import {hp, wp} from 'utils/ScreenDimensions';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {PinataJWT, PUBLIC_NEYNAR_API_KEY} from '@env';
import {CameraRoll} from '@react-native-camera-roll/camera-roll';
import Icon from 'react-native-vector-icons/Ionicons';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const Casting = ({navigation}: Props) => {
  const [selectedImages, setSelectedImages] = useState([]);
  const [photos, setPhotos] = useState([]);
  const [text, setText] = useState('');
  const [pfpUrl, setPfpUrl] = useState<string | null>(null);
  const [imageUrl, setimageUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const GATEWAY = 'beige-grateful-cow-442.mypinata.cloud';

  useEffect(() => {
    const checkPermissionAndFetchPhotos = async () => {
      const permissionGranted = await hasPermission();
      if (permissionGranted) {
        getAllphotos();
      }
    };

    checkPermissionAndFetchPhotos();
  }, []);

  const hasPermission = async () => {
    const permission =
      Platform.Version >= 33
        ? PermissionsAndroid.PERMISSIONS.READ_MEDIA_IMAGES
        : PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE;

    const hasPermission = await PermissionsAndroid.check(permission);

    if (hasPermission) {
      return true;
    }

    const status = await PermissionsAndroid.request(permission);
    return status === PermissionsAndroid.RESULTS.GRANTED;
  };

  useEffect(() => {
    const fetchProfileDetails = async () => {
      try {
        const profileDetail = await AsyncStorage.getItem('profileDetail');
        if (profileDetail) {
          const profileImg = JSON.parse(profileDetail);
          setPfpUrl(profileImg?.user?.pfp_url || null);
        }
      } catch (error) {
        console.error('Error fetching profile details:', error);
      }
    };

    fetchProfileDetails();
  }, []);

  const getAllphotos = async () => {
    try {
      const photos = await CameraRoll.getPhotos({
        first: 20,
        assetType: 'All',
      });
      setPhotos(photos.edges.map(edge => edge.node.image));
    } catch (err) {
      console.error('Error loading images:', err);
    }
  };

  const pickImage = () => {
    const options = {
      mediaType: 'photo',
    };
    launchImageLibrary(options, response => {
      if (response?.assets) {
        if (selectedImages.length + response.assets.length <= 2) {
          setSelectedImages(prev => [...prev, ...response.assets]);
        } else {
          console.warn('You can select up to 2 images only.');
        }
      }
    });
  };
  const selectPhoto = photo => {
    setSelectedImages(prevImages => {
      // Avoid duplicates
      const isAlreadySelected = prevImages.some(
        image => image.uri === photo.uri,
      );
      if (!isAlreadySelected) {
        return [...prevImages, photo];
      }
      return prevImages;
    });
  };
  const deselectImage = imageUri => {
    setSelectedImages(prevImages =>
      prevImages.filter(image => image.uri !== imageUri),
    );
  };

  const ImageUpload = async () => {
    if (selectedImages.length === 0) {
      console.warn('No images selected for upload');
      return;
    }
    setLoading(true);

    try {
      const formData = new FormData();
      formData.append('file', {
        uri: selectedImages[0]?.uri,
        type: selectedImages[0]?.type || 'image/jpeg', // Provide a default type if not available
        name: selectedImages[0]?.fileName || 'uploaded_image.jpg', // Use fileName or a default name
      });

      const metadata = JSON.stringify({
        name: 'File name',
      });

      formData.append('pinataMetadata', metadata);

      const res = await axios.post(
        'https://api.pinata.cloud/pinning/pinFileToIPFS',
        formData,
        {
          headers: {
            Authorization: `Bearer ${PinataJWT}`,
            'Content-Type': 'multipart/form-data',
          },
        },
      );

      const resData = res.data;
      const url = `https://${GATEWAY}/ipfs/${resData.IpfsHash}`;
      setimageUrl(url);

      const signerUuid = await AsyncStorage.getItem('signerUuid');
      const channelId = await AsyncStorage.getItem('channelID');
      if (!signerUuid) {
        throw new Error('signerUuid is missing');
      }

      if (!url) {
        throw new Error('imageURL is missing');
      }

      const options = {
        method: 'POST',
        headers: {
          accept: 'application/json',
          api_key: PUBLIC_NEYNAR_API_KEY,
          'content-type': 'application/json',
        },
        data: {
          embeds: [
            {
              url: url,
            },
          ],
          text: text,
          channel_id: channelId,
          signer_uuid: signerUuid.trim(),
        },
      };

      const response = await axios.post(
        'https://api.neynar.com/v2/farcaster/cast',
        options.data,
        {headers: options.headers},
      );

      const castSuccess = response.data?.success;

      if (castSuccess) {
        navigation.navigate('Home');
      } else {
        console.error('Failed to cast');
      }
    } catch (error: any) {
      console.error('Error uploading image:', error.message);
      if (error.response) {
        console.error('Response data:', error.response.data);
        console.error('Response status:', error.response.status);
        console.error('Response headers:', error.response.headers);
      } else if (error.request) {
        console.error('Request:', error.request);
      } else {
        console.error('Error message:', error.message);
      }
    } finally {
      setLoading(false);
    }
  };

  const renderImageItem = ({item}) => (
    <TouchableOpacity onPress={() => selectPhoto(item)}>
      <Image source={{uri: item.uri}} style={styles.selectedImage} />
    </TouchableOpacity>
  );

  const selectedImageItem = ({item}) => (
    <View>
      <Image
        source={{uri: item.uri}}
        style={
          selectedImages.length === 1
            ? styles.selectImageSingle
            : styles.selectImageDouble
        }
      />
      <TouchableOpacity
        style={styles.iconContainer}
        onPress={() => deselectImage(item.uri)}>
        <Icon name="close-circle" size={20} color="#fff" />
      </TouchableOpacity>
    </View>
  );

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 100 : 0}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.cancelText}>Cancel</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={ImageUpload} disabled={loading}>
          <View style={[styles.btnActive, loading && styles.btnDisabled]}>
            {loading ? (
              <ActivityIndicator color="#FFFFFF" />
            ) : (
              <Text style={styles.btnTxtActive}>Cast</Text>
            )}
          </View>
        </TouchableOpacity>
      </View>
      <View style={styles.inputContainer}>
        <FlatList
          key={selectedImages.length === 1 ? 'one-column' : 'two-columns'}
          numColumns={selectedImages.length === 1 ? 1 : 2}
          data={selectedImages}
          renderItem={selectedImageItem}
          keyExtractor={item => item.uri}
          style={styles.imageList}
          ItemSeparatorComponent={() => <View style={{height: 16}} />}
          columnWrapperStyle={
            selectedImages.length !== 1
              ? {justifyContent: 'space-between'}
              : null
          } // Apply space-between for two-column layout
        />
        <View style={styles.inputContent}>
          {pfpUrl && (
            <Image source={{uri: pfpUrl}} style={styles.profileImage} />
          )}
          <TextInput
            value={text}
            onChangeText={setText}
            placeholder="What's happening?"
            placeholderTextColor="#777"
            style={styles.textInput}
            multiline
          />
        </View>
      </View>

      <View style={styles.imagePickerContainer}>
        <TouchableOpacity
          onPress={pickImage}
          style={styles.imagePickerButton}
          disabled={selectedImages.length >= 2}>
          <Image source={IMAGE.imageAdd} />
        </TouchableOpacity>
        <FlatList
          horizontal
          data={photos}
          renderItem={renderImageItem}
          keyExtractor={item => item.uri}
          showsHorizontalScrollIndicator={false}
          style={styles.imageList}
        />
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  selectedImage: {
    width: 70,
    height: 70,
    borderRadius: 8,
    marginRight: 8,
  },
  imageContainer: {
    position: 'relative',
  },
  iconContainer: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    borderRadius: 10,
    padding: 2,
  },
  selectImageSingle: {
    width: wp(87),
    aspectRatio: 1,
    borderRadius: 8,
    marginBottom: 16,
  },
  selectImageDouble: {
    width: wp(41), // Half width for double images
    aspectRatio: 1,
    borderRadius: 8,
    marginBottom: 16,
  },
  img: {
    marginLeft: 10,
  },
  btnTxtActive: {
    color: '#FFFFFF',
    fontWeight: '600',
    fontSize: 18,
  },
  btnDisabled: {
    backgroundColor: '#555',
  },
  btnActive: {
    backgroundColor: '#121212',
    borderRadius: 16,
    height: hp(4),
    width: wp(15, true),
    alignItems: 'center',
    justifyContent: 'center',
  },
  container: {
    flex: 1,
    margin: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cancelText: {
    fontSize: 16,
    color: '#000',
    marginTop: 10,
  },
  castText: {
    fontSize: 16,
    color: '#000',
  },
  inputContainer: {
    // flex: 1,
    padding: 16,
    // alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 16,
    // height: hp(30, true),
    marginTop: 16,
  },
  inputContent: {
    flexDirection: 'row',
    marginVertical: 16,
  },
  profileImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
  },
  textInput: {
    fontSize: 16,
    color: '#000',
    alignSelf: 'flex-start',
  },
  imagePickerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    marginVertical: 16,
  },
  imagePickerButton: {
    padding: 16,
    backgroundColor: '#FFF',
    borderRadius: 8,
    marginRight: 10,
    width: 70,
    height: 70,
    justifyContent: 'center',
    alignContent: 'center',
  },
  imagePickerText: {
    color: '#fff',
    fontSize: 16,
  },
  imageList: {
    flexGrow: 0,
    // marginTop: 8,
  },
  selectedImage: {
    width: 70,
    height: 70,
    borderRadius: 8,
    marginRight: 8,
  },
  selectImage: {
    width: wp(41),
    // height: 152,
    aspectRatio: 1,
    borderRadius: 8,
    marginRight: 8,
  },
  toolbar: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  toolbarText: {
    fontSize: 16,
    color: '#555',
  },
});

export default Casting;
