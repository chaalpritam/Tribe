import React from 'react';
import {createStackNavigator} from '@react-navigation/stack';
import 'react-native-gesture-handler';
import Onboard from 'screens/Onboard';
import TribePager from 'screens/TribePager';
import Neighbourhood from 'screens/Neighbourhood';
import TribeWait from 'screens/TribeWait';
import TribeCount from 'screens/TribeCount';
import WhatyouWanndo from 'screens/WhatyouWanndo';

export type StackNavigatorParamList = {
  Onboard: undefined;
  TribePager: undefined;
  Neighbourhood: undefined;
  TribeWait: undefined;
  TribeCount: undefined;
  WhatyouWanndo: undefined;
};

const Stack = createStackNavigator<StackNavigatorParamList>();

function Nav(): JSX.Element {
  return (
    <Stack.Navigator
      initialRouteName="Onboard"
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
        name="WhatyouWanndo"
        component={WhatyouWanndo}
        options={{headerShown: false}}
      />
    </Stack.Navigator>
  );
}
export default Nav;
