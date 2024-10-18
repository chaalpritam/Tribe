import React, {useEffect, useState} from 'react';
import {
  View,
  Image,
  FlatList,
  StyleSheet,
  PermissionsAndroid,
  Platform,
} from 'react-native';
import RNFS from 'react-native-fs';

const Casting = () => {
  const [images, setImages] = useState([]);

  useEffect(() => {
    // Request storage permissions on Android
    const requestPermissions = async () => {
      if (Platform.OS === 'android') {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE,
          {
            title: 'Storage Permission',
            message: 'App needs access to your storage to access images.',
            buttonNeutral: 'Ask Me Later',
            buttonNegative: 'Cancel',
            buttonPositive: 'OK',
          },
        );
        if (granted === PermissionsAndroid.RESULTS.GRANTED) {
          getRecentImages();
        } else {
          console.log('Storage permission denied');
        }
      } else {
        getRecentImages(); // For iOS, permissions are handled automatically
      }
    };

    requestPermissions();
  }, []);

  const getRecentImages = async () => {
    // Define the path to where images are stored on the device
    const imagePath =
      Platform.OS === 'android'
        ? '/storage/emulated/0/DCIM/'
        : RNFS.DocumentDirectoryPath;

    try {
      const files = await RNFS.readDir(imagePath); // Get all files in the directory
      const imageFiles = files
        .filter(file => file.isFile() && /\.(jpg|jpeg|png)$/i.test(file.name)) // Filter only images
        .sort((a, b) => b.mtime - a.mtime) // Sort by modification time (recent first)
        .slice(0, 4); // Take the first 4 images

      const imageUris = imageFiles.map(file => 'file://' + file.path); // Map to file URIs

      setImages(imageUris); // Set the images to state
    } catch (err) {
      console.log(err.message, err.code);
    }
  };

  return (
    <View style={styles.container}>
      <FlatList
        data={images}
        keyExtractor={(item, index) => index.toString()}
        renderItem={({item}) => (
          <Image source={{uri: item}} style={styles.image} />
        )}
        horizontal={true} // Show images horizontally
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: 100,
    height: 100,
    margin: 10,
  },
});

export default Casting;
