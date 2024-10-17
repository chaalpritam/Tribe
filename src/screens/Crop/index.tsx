import React, {useEffect, useState} from 'react';
import {
  View,
  Image,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Text,
  Dimensions,
} from 'react-native';
import {SizeBtn} from 'components/SizeBtn';
import {SizeBtnData} from 'data';
import axios from 'axios';
import {PinataJWT} from '@env';
import {Cbutton} from 'components/Cbutton';
import {CRbutton} from 'components/CRbutton';
import {CBar} from 'components/CBar';
import {IMAGE} from 'images';

type Props = {
  route: any;
  navigation: any;
};

function Crop({route, navigation}: Props): JSX.Element {
  const defaultAspectRatio = SizeBtnData[0];
  const [selectedId, setSelectedId] = useState<number | null>(
    defaultAspectRatio.id,
  );
  const [image] = useState<any>(route.params?.image);
  const [aspectRatio, setAspectRatio] = useState(defaultAspectRatio.size); // Default aspect ratio
  const [imageStyle, setImageStyle] = useState({width: 0, height: 0});
  const GATEWAY = 'beige-grateful-cow-442.mypinata.cloud';

  const calculateNewDimensions = (ar: string) => {
    const [widthRatio, heightRatio] = ar.split(':').map(Number);
    const newWidth = Dimensions.get('window').width;
    const newHeight = (newWidth * heightRatio) / widthRatio;
    return {width: newWidth, height: newHeight};
  };

  const handleSizeChange = (id: number, size: string) => {
    setSelectedId(id);
    const {width, height} = calculateNewDimensions(size);
    setImageStyle({width, height});
    setAspectRatio(size);
  };

  const handleSubmission = async () => {
    console.log('Starting image upload...');

    const navigateToNextScreen = (url: any) => {
      navigation.navigate(route.params?.nextScreen, {
        image: url,
        rawImage: image,
      });
    };

    // Start the upload process
    try {
      const formData = new FormData();
      formData.append('file', {
        uri: image.uri,
        type: 'image/jpeg', // Use a default type if not provided
        name: 'image.jpg', // Use a default name if not provided
      });

      const metadata = JSON.stringify({
        name: 'File name',
      });
      formData.append('pinataMetadata', metadata);

      console.log('Making API request...');

      // Start the upload process in the background
      const uploadPromise = axios.post(
        'https://api.pinata.cloud/pinning/pinFileToIPFS',
        formData,
        {
          headers: {
            Authorization: `Bearer ${PinataJWT}`,
            'Content-Type': 'multipart/form-data',
          },
        },
      );

      // Navigate immediately to the next screen with a placeholder or pending status
      navigateToNextScreen({status: 'uploading'});

      // Handle the response once the upload is complete
      const res = await uploadPromise;
      const resData = res.data;

      console.log(resData);

      const url = `https://${GATEWAY}/ipfs/${resData?.IpfsHash}`;
      console.log(url, 'Response URL');

      // Pass the final data to the next screen once the upload is complete
      navigateToNextScreen(url);
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

      // Optionally, navigate to the next screen with an error status
      navigateToNextScreen({status: 'error', message: error.message});
    }
  };

  useEffect(() => {
    // Initialize image style on component mount
    const {width, height} = calculateNewDimensions(aspectRatio);
    setImageStyle({width, height});
  }, [aspectRatio]);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.top}>
        <CBar
          Arrow={IMAGE.leftArrow}
          // RightImageOne={IMAGE.cropIcon}
          navigation={() => navigation.goBack()}
          closeModal={() => navigation.navigate('Home')}
        />
      </View>
      <View style={styles.imageContainer}>
        {image?.uri && (
          <Image
            source={{uri: image.uri}}
            style={[styles.image, imageStyle]}
            resizeMode="contain"
          />
        )}
      </View>
      <View style={styles.buttons}>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.ratioSelectionColumnGap}>
          {SizeBtnData.map(({id, size}) => (
            <SizeBtn
              key={id}
              size={size}
              isActive={id === selectedId}
              onPress={() => handleSizeChange(id, size)}
            />
          ))}
        </ScrollView>
      </View>
      <Text style={styles.infoText}>
        More info minting images & casting to farcaster
      </Text>
      <View style={styles.bottomButtons}>
        <Cbutton />
        <CRbutton onPress={handleSubmission} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  top: {
    padding: 16,
  },
  imageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  buttons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 24,
    marginHorizontal: 24,
  },
  infoText: {
    textAlign: 'center',
    color: '#007AFF',
    marginVertical: 24,
  },
  bottomButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginHorizontal: 24,
    marginBottom: 16,
  },
  saveButton: {
    backgroundColor: '#E0E0E0',
    paddingVertical: 12,
    paddingHorizontal: 32,
    borderRadius: 8,
  },
  castButton: {
    backgroundColor: '#000',
    paddingVertical: 12,
    paddingHorizontal: 32,
    borderRadius: 8,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
    textAlign: 'center',
  },
  ratioSelectionColumnGap: {
    columnGap: 16,
  },
});

export default Crop;
