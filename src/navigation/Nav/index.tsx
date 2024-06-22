import React from 'react';
import {createStackNavigator} from '@react-navigation/stack';
import 'react-native-gesture-handler';
import Onboard from 'screens/Onboard';
import TribePager from 'screens/TribePager';
import Neighbourhood from 'screens/Neighbourhood';

export type StackNavigatorParamList = {
  Onboard: undefined;
  TribePager: undefined;
  Neighbourhood: undefined;
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
    </Stack.Navigator>
  );
}
export default Nav;
