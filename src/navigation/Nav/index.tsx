import React from 'react';
import {createStackNavigator} from '@react-navigation/stack';
import 'react-native-gesture-handler';
import Onboard from 'screens/Onboard';

export type StackNavigatorParamList = {
  Onboard: undefined;
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
    </Stack.Navigator>
  );
}
export default Nav;
