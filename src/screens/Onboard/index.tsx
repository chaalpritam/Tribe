import {StyleSheet, Text, View, SafeAreaView, Image} from 'react-native';
import React, {PropsWithChildren, useEffect} from 'react';
import SplashScreen from 'react-native-splash-screen';
import {IMAGE} from 'images';
import PrimaryButton from 'components/Button/PrimaryButton';
import {Colors} from 'configs';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const Onboard = ({navigation}: Props) => {
  useEffect(() => {
    SplashScreen.show();

    const timer = setTimeout(() => {
      SplashScreen.hide();
    }, 500);

    return () => clearTimeout(timer);
  }, []);

  const handleNav = () => {
    navigation.navigate('TribePager');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.imageContainer}>
        <Image style={styles.img} source={IMAGE.Onboard} />
      </View>
      <PrimaryButton
        title="Login with phone"
        style={styles.btn}
        onPress={handleNav}
      />
      <Text style={styles.text}>Login with email</Text>
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
    paddingHorizontal: '30%',
  },
  text: {
    color: Colors.PrimaryColor,
    textAlign: 'center',
    textDecorationLine: 'underline',
    marginVertical: 16,
  },
});
