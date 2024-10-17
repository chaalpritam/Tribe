import React, {useState} from 'react';
import {
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
  PermissionsAndroid,
  Platform,
  Image,
} from 'react-native';
import {RNCamera} from 'react-native-camera';
import {IMAGE} from 'images';

export function CameraScreen({navigation}: {navigation: any}): JSX.Element {
  const [imageUri, setImageUri] = useState<null | string>(null);
  const [cameraType, setCameraType] = useState(RNCamera.Constants.Type.back);
  const [flashMode, setFlashMode] = useState(RNCamera.Constants.FlashMode.off);

  const takePicture = async (camera: RNCamera) => {
    try {
      const data = await camera.takePictureAsync({
        quality: 0.8,
      });
      console.log(data, 'Image Data uri');
      setImageUri(data.uri);
      navigation.navigate('CropCamera', {
        image: {
          uri: data.uri,
          width: data.width,
          height: data.height,
        },
        nextScreen: 'Mint',
      });
    } catch (error) {
      console.error(error);
    }
  };
  console.log(imageUri, 'imageUri');

  const requestCameraPermission = async () => {
    if (Platform.OS === 'android') {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.CAMERA,
        {
          title: 'Camera Permission',
          message: 'App needs camera permission to take pictures.',
          buttonNeutral: 'Ask Me Later',
          buttonNegative: 'Cancel',
          buttonPositive: 'OK',
        },
      );
      if (granted !== PermissionsAndroid.RESULTS.GRANTED) {
        console.log('Camera permission denied');
        return;
      }
    }
  };

  const toggleFlash = () => {
    setFlashMode(
      flashMode === RNCamera.Constants.FlashMode.off
        ? RNCamera.Constants.FlashMode.on
        : RNCamera.Constants.FlashMode.off,
    );
  };

  const switchCamera = () => {
    setCameraType(
      cameraType === RNCamera.Constants.Type.back
        ? RNCamera.Constants.Type.front
        : RNCamera.Constants.Type.back,
    );
  };

  return (
    <View style={styles.container}>
      <RNCamera
        style={styles.camera}
        type={cameraType}
        flashMode={flashMode}
        captureAudio={false}
        // ratio="16:16"
        autoFocus="on"
        onCameraReady={requestCameraPermission}>
        {({camera, status}) => {
          if (status !== 'READY') {
            return <Text>Camera is not ready</Text>;
          }
          return (
            <View style={styles.cameraControls}>
              <View style={styles.topControls}>
                <TouchableOpacity
                  onPress={toggleFlash}
                  style={styles.controlButton}>
                  {/* <FontAwesome
                  name={
                    flashMode === RNCamera.Constants.FlashMode.off
                      ? 'flash'
                      : 'flash-off'
                  }
                  size={24}
                  color="white"
                /> */}
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={switchCamera}
                  style={styles.controlButton}>
                  {/* <FontAwesome name="refresh" size={24} color="white" /> */}
                  <Image source={IMAGE.RotateCamera} />
                </TouchableOpacity>
              </View>
              <View style={styles.captureButtonContainer}>
                <TouchableOpacity
                  onPress={() => takePicture(camera)}
                  style={styles.captureButton}>
                  {/* <FontAwesome name="camera" size={30} color="white" /> */}
                  <Image source={IMAGE.cameraButton} />
                </TouchableOpacity>
              </View>
            </View>
          );
        }}
      </RNCamera>
    </View>
  );
}

export default CameraScreen;

const styles = StyleSheet.create({
  camera: {
    flex: 1,
    justifyContent: 'space-between',
  },
  container: {
    flex: 1,
    backgroundColor: 'black',
  },
  cameraControls: {
    flex: 1,
    justifyContent: 'space-between',
  },
  topControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 20,
  },
  controlButton: {
    // backgroundColor: 'rgba(0, 0, 0, 0.3)',
    padding: 10,
    borderRadius: 5,
  },
  captureButtonContainer: {
    alignSelf: 'center',
    marginBottom: 30,
  },
  captureButton: {
    // backgroundColor: 'rgba(0, 0, 0, 0.7)',
    padding: 15,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
