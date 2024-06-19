import {StyleSheet, Text, View} from 'react-native';
import React, {useEffect} from 'react';
import SplashScreen from 'react-native-splash-screen';

const Onboard = () => {
  useEffect(() => {
    SplashScreen.show();

    const timer = setTimeout(() => {
      SplashScreen.hide();
    }, 500);

    return () => clearTimeout(timer);
  }, []);
  return (
    <View>
      <Text style={{color: '#000'}}>Onboard</Text>
    </View>
  );
};

export default Onboard;

const styles = StyleSheet.create({});
