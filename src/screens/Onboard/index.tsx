import {StyleSheet, Text, View, SafeAreaView, Image} from 'react-native';
import React, {PropsWithChildren, useEffect, useState} from 'react';
import SplashScreen from 'react-native-splash-screen';
import {IMAGE} from 'images';
import {Colors} from 'configs';
import {PUBLIC_NEYNAR_API_KEY, PUBLIC_NEYNAR_CLIENT_ID} from '@env';
import {
  NeynarSigninButton,
  ISuccessMessage,
  Theme,
} from '@neynar/react-native-signin';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {wp} from 'utils/ScreenDimensions';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const Onboard = ({navigation}: Props) => {
  const neynarApiKey = PUBLIC_NEYNAR_API_KEY;
  const neynarClientId = PUBLIC_NEYNAR_CLIENT_ID;
  const [authUrl, setAuthUrl] = useState('');
  const [signerUuid, setSignerUuid] = useState<string | null>(null);
  const [fid, setFid] = useState<number | null>(null);

  useEffect(() => {
    const getAuthUrl = async () => {
      try {
        const res = await axios.get(
          `https://api.neynar.com/v2/farcaster/login/authorize?client_id=${neynarClientId}&response_type=code`,
          options,
        );
        console.log(res.data.authorization_url, 'Auth Response');
        setAuthUrl(res.data.authorization_url);
      } catch (error) {
        console.error('Error fetching Auth URl:', error);
      }
    };
    getAuthUrl();
  }, []);

  const handleSignin = async (data: ISuccessMessage) => {
    console.log(data, 'response');
    AsyncStorage.setItem('profileDetail', JSON.stringify(data));
    setFid(Number(data.fid));
    setSignerUuid(data.signer_uuid);
    AsyncStorage.setItem('fid', JSON.stringify(data.fid));
    AsyncStorage.setItem('signerUuid', data.signer_uuid);
    // navigation.reset({
    //   index: 0,
    //   routes: [{name: 'MainNav'}],
    // });
  };

  const options = {
    // method: 'GET',
    headers: {accept: 'application/json', api_key: neynarApiKey},
  };

  useEffect(() => {
    const getAuthUrl = async () => {
      try {
        const res = await axios.get(
          `https://api.neynar.com/v2/farcaster/login/authorize?client_id=${neynarClientId}&response_type=code`,
          options,
        );
        console.log(res.data.authorization_url, 'Auth Response');
        setAuthUrl(res.data.authorization_url);
      } catch (error) {
        console.error('Error fetching Auth URl:', error);
      }
    };
    getAuthUrl();
  }, []);

  const handleError = (err: Error) => {
    console.log(err, 'Sigin Error');
  };

  console.log(signerUuid, 'signerUuid');
  console.log(fid, 'fid');

  const handleNav = () => {
    navigation.navigate('TribePager');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.imageContainer}>
        <Image style={styles.img} source={IMAGE.Onboard} />
      </View>
      {/* <PrimaryButton
        title="Login with phone"
        style={styles.btn}
        onPress={handleNav}
      /> */}

      <NeynarSigninButton
        fetchAuthorizationUrl={async () => authUrl}
        successCallback={handleSignin}
        errorCallback={handleError}
        redirectUrl={'tribe://'}
        text="Connect With Farcaster"
        buttonStyles={styles.btn}
        textStyles={styles.text}
        theme={Theme.DARK}
      />
    </SafeAreaView>
  );
};

export default Onboard;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // justifyContent: 'center',
    // alignItems: 'center',
    marginHorizontal: 16,
  },
  imageContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    flex: 1,
  },
  img: {},
  btn: {
    // paddingHorizontal: '30%',
    width: wp(85),
  },
  text: {
    color: Colors.white,
    textAlign: 'center',
  },
});
