import {SafeAreaView, StyleSheet, Text, View} from 'react-native';
import React, {useEffect, useState} from 'react';
import WaitingCount from 'components/WaitingCount';
import {IMAGE} from 'images';
import {Colors} from 'configs';
import PrimaryButton from 'components/Button/PrimaryButton';
import {useNavigation, useRoute} from '@react-navigation/native';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import AsyncStorage from '@react-native-async-storage/async-storage';

const TribeCount = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const {tribeId} = route.params;
  const handleNav = async () => {
    try {
      const signerUuid = await AsyncStorage.getItem('signerUuid');
      const options = {
        method: 'POST',
        headers: {
          accept: 'application/json',
          api_key: PUBLIC_NEYNAR_API_KEY,
          'content-type': 'application/json',
        },
        data: {
          channel_id: tribeId,
          signer_uuid: signerUuid.trim(),
        },
      };
      const SubscribeResponse = await axios.post(
        'https://api.neynar.com/v2/farcaster/channel/follow',
        options.data,
        {headers: options.headers},
      );
      console.log(SubscribeResponse.data, 'Subscribe Response');
      if (SubscribeResponse?.data?.success) {
        navigation.navigate('BottomNavigator');
      }
    } catch (error) {
      console.error('Response error:', error.response.data);
    }
  };
  const changeNeighbor = () => {
    navigation.goBack();
  };
  const [channelDetails, setchannelDetails] = useState<any>({});

  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };
  useEffect(() => {
    const fetchchannelDetails = async () => {
      try {
        const channelId = tribeId;
        console.log(channelId);
        if (channelId) {
          const response = await axios.get(
            `https://api.neynar.com/v2/farcaster/channel?id=${channelId}`,
            options,
          );
          setchannelDetails(response.data.channel);
          AsyncStorage.setItem('channelID', response.data.channel.id);
        } else {
          console.error('No channelId found in AsyncStorage');
        }
      } catch (error) {
        console.error('Error fetching channel members data:', error);
      }
    };
    fetchchannelDetails();
  }, []);
  console.log(channelDetails, 'channelDetails');
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.heading}>
        You’re ready to join {channelDetails.name}
      </Text>
      <View style={styles.contentContainer}>
        <WaitingCount
          image={IMAGE.diversity}
          count={channelDetails.follower_count}
        />
        <Text style={styles.txt}>people are there in your tribe</Text>
      </View>
      <PrimaryButton
        title={`Join ${channelDetails.name}`}
        style={styles.btn}
        onPress={handleNav}
      />
      <Text onPress={changeNeighbor} style={styles.text}>
        Change neighborhood
      </Text>
    </SafeAreaView>
  );
};

export default TribeCount;

const styles = StyleSheet.create({
  contentContainer: {
    flex: 1,
    justifyContent: 'center',
    alignContent: 'center',
    alignItems: 'center',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignContent: 'center',
    alignItems: 'center',
    margin: 24,
  },
  heading: {
    fontSize: 24,
    marginVertical: 20,
    fontWeight: '600',
    textAlign: 'center',
    fontFamily: 'Quicksand',
    color: Colors.PrimaryColor,
    width: '65%',
  },
  btn: {
    position: 'absolute',
    bottom: 30,
    paddingHorizontal: '30%',
    alignSelf: 'center',
  },
  text: {
    color: Colors.PrimaryColor,
    textAlign: 'center',
    textDecorationLine: 'underline',
    // marginVertical: 16,
  },
  txt: {
    color: Colors.PrimaryColor,
    textAlign: 'center',
  },
});
