import React, {useEffect, useState} from 'react';
import {createStackNavigator} from '@react-navigation/stack';
import 'react-native-gesture-handler';
import Onboard from 'screens/Onboard';
import TribePager from 'screens/TribePager';
import Neighbourhood from 'screens/Neighbourhood';
import TribeWait from 'screens/TribeWait';
import TribeCount from 'screens/TribeCount';
import Profile from 'screens/Profile';
import WhatyouWann from 'screens/WhatyouWann';
import BottomNavigator from 'navigation/BottomNavigator';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {ActivityIndicator, StyleSheet, View} from 'react-native';
import CameraScreen from 'components/Camera';
import Crop from 'screens/Crop';
import Mint from 'screens/Mint';

export type StackNavigatorParamList = {
  Onboard: undefined;
  TribePager: undefined;
  Neighbourhood: undefined;
  TribeWait: undefined;
  TribeCount: undefined;
  WhatyouWanndo: undefined;
  Profile: undefined;
  WhatyouWann: undefined;
  BottomNavigator: undefined;
  CameraScreen: undefined;
  CropCamera: undefined;
  Mint: undefined;
};

const Stack = createStackNavigator<StackNavigatorParamList>();

function Nav(): JSX.Element {
  const [initialRoute, setInitialRoute] = useState<
    keyof StackNavigatorParamList | undefined
  >(undefined);
  useEffect(() => {
    const checkFid = async () => {
      const fidString = await AsyncStorage.getItem('fid');
      setInitialRoute(fidString ? 'BottomNavigator' : 'TribePager');
    };

    checkFid();
  }, []);

  if (initialRoute === undefined) {
    // Display a loading indicator while checking AsyncStorage
    return (
      <View style={styles.loading}>
        <ActivityIndicator size="large" color="#0000ff" />
      </View>
    );
  }

  return (
    <Stack.Navigator
      initialRouteName={initialRoute}
      screenOptions={{gestureEnabled: false, headerShown: true}}>
      <Stack.Screen
        name="Onboard"
        component={Onboard}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="TribePager"
        component={TribePager}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="Neighbourhood"
        component={Neighbourhood}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="TribeWait"
        component={TribeWait}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="TribeCount"
        component={TribeCount}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="BottomNavigator"
        component={BottomNavigator}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="Profile"
        component={Profile}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="WhatyouWann"
        component={WhatyouWann}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="CameraScreen"
        component={CameraScreen}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="CropCamera"
        component={Crop}
        options={{headerShown: false}}
      />
      <Stack.Screen
        name="Mint"
        component={Mint}
        options={{headerShown: false}}
      />
    </Stack.Navigator>
  );
}
export default Nav;

const styles = StyleSheet.create({
  loading: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
