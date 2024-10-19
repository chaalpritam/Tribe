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
} from 'react-native';
import {launchImageLibrary} from 'react-native-image-picker';
import {IMAGE} from 'images';
import {hp, wp} from 'utils/ScreenDimensions';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {PinataJWT, PUBLIC_NEYNAR_API_KEY} from '@env';
// import Icon from 'react-native-vector-icons/Ionicons';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const Casting = ({navigation}: Props) => {
  const [selectedImages, setSelectedImages] = useState([]);
  const [text, setText] = useState('');
  const [pfpUrl, setPfpUrl] = useState<string | null>(null);
  const [imageUrl, setimageUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const GATEWAY = 'beige-grateful-cow-442.mypinata.cloud';

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

  // Function to pick an image
  const pickImage = () => {
    const options = {
      mediaType: 'photo',
    };
    launchImageLibrary(options, response => {
      if (response?.assets) {
        setSelectedImages(prev => [...prev, ...response.assets]);
      }
    });
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

      // Make the POST request to Pinata
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
      console.log('Image uploaded successfully, IPFS URL:', url);
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
        // dispatch(setCastStatus(true));
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
    <Image source={{uri: item.uri}} style={styles.selectedImage} />
  );

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 100 : 0}>
      {/* Top Header */}
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
        {pfpUrl && <Image source={{uri: pfpUrl}} style={styles.profileImage} />}
        <TextInput
          value={text}
          onChangeText={setText}
          placeholder="What's happening?"
          placeholderTextColor="#777"
          // multiline
          style={styles.textInput}
        />
      </View>

      {/* Image picker button and selected images list */}
      <View style={styles.imagePickerContainer}>
        <TouchableOpacity onPress={pickImage} style={styles.imagePickerButton}>
          <Image source={IMAGE.imageAdd} />
        </TouchableOpacity>
        <FlatList
          horizontal
          data={selectedImages}
          renderItem={renderImageItem}
          keyExtractor={item => item.uri}
          showsHorizontalScrollIndicator={false}
          style={styles.imageList}
        />
      </View>
      {/* <Icon name="star-outline" size={30} color="#000" />
      <Icon name="star"  size={30} color="#000" /> */}
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
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
    flexDirection: 'row',
    padding: 16,
    // alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 16,
    height: hp(30),
    marginTop: 16,
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
  },
  imagePickerText: {
    color: '#fff',
    fontSize: 16,
  },
  imageList: {
    flexGrow: 0,
    marginTop: 8,
  },
  selectedImage: {
    width: 80,
    height: 80,
    borderRadius: 10,
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
