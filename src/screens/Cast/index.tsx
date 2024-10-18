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
} from 'react-native';
import {launchImageLibrary} from 'react-native-image-picker';
import {IMAGE} from 'images';
import {hp, wp} from 'utils/ScreenDimensions';
import AsyncStorage from '@react-native-async-storage/async-storage';
// import Icon from 'react-native-vector-icons/Ionicons'; 

type Props = PropsWithChildren<{
  navigation: any;
}>;

const Casting = ({navigation}: Props) => {
  const [selectedImages, setSelectedImages] = useState([]);
  const [text, setText] = useState('');
  const [pfpUrl, setPfpUrl] = useState<string | null>(null);

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

console.log(selectedImages, 'selectedImages')
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
        <TouchableOpacity>
          <View style={styles.btnActive}>
            <Text style={styles.btnTxtActive}>Cast</Text>
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
