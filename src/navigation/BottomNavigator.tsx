/* eslint-disable react/no-unstable-nested-components */
import React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {Image, View, StyleSheet, Text} from 'react-native';
import Home from 'screens/Home';
import {IMAGE} from 'images';
import {hp} from 'utils/ScreenDimensions';
import WhatyouWanndo from 'screens/WhatyouWanndo';
import Explore from 'screens/Explore';
import MyProfile from 'screens/MyProfile';
import Icon from 'react-native-vector-icons/Ionicons';

const Bottom = createBottomTabNavigator();

export const Notification = () => {
  return <Text>Notification</Text>;
};

function BottomNavigator(): JSX.Element {
  const screenOptions = ({}: any) => ({
    showIcon: true,
    showLabel: false,
    headerShown: false,
    tabBarShowLabel: false,
    tabBarStyle: {
      backgroundColor: '#121212',
      borderRadius: 20,
      height: hp(8),
      marginHorizontal: 16,
      marginBottom: 16,
    },
  });

  return (
    <Bottom.Navigator screenOptions={screenOptions}>
      <Bottom.Screen
        name="Home"
        component={Home}
        options={{
          tabBarIcon: ({focused}) => (
            // <Image
            //   source={IMAGE.home1}
            //   style={focused ? styles.activeImg : styles.normalImg}
            // />
            <Icon
              name="filter"
              size={32}
              color={focused ? '#fff' : '#8F8F8F'}
            />
          ),
        }}
      />
      <Bottom.Screen
        name="Explore"
        component={Explore}
        options={{
          tabBarIcon: ({focused}) => (
            <Icon
              name="compass-outline"
              size={32}
              color={focused ? '#fff' : '#8F8F8F'}
            />
          ),
        }}
      />
      <Bottom.Screen
        name="WhatyouWanndo"
        component={WhatyouWanndo}
        options={{
          tabBarIcon: ({focused}) => (
            <Icon
              name="add-circle"
              size={56}
              color={focused ? '#fff' : '#8F8F8F'}
            />
          ),
        }}
      />
      <Bottom.Screen
        name="Notification"
        component={Notification}
        options={{
          tabBarIcon: ({focused}) => (
            <Icon
              name="layers"
              size={32}
              color={focused ? '#fff' : '#8F8F8F'}
            />
          ),
        }}
      />

      <Bottom.Screen
        name="MyProfile"
        component={MyProfile}
        options={{
          tabBarIcon: ({focused}) => (
            <Icon
              name="person-circle-outline"
              size={32}
              color={focused ? '#fff' : '#8F8F8F'}
            />
          ),
        }}
      />
    </Bottom.Navigator>
  );
}

export default BottomNavigator;

const styles = StyleSheet.create({
  iconbg: {
    backgroundColor: '#FFFFFF',
    width: 40,
    height: 40,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cameraPreview: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  captureButtonContainer: {
    flex: 0,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  captureButton: {
    flex: 0,
    backgroundColor: '#fff',
    borderRadius: 5,
    padding: 15,
    paddingHorizontal: 20,
    alignSelf: 'center',
    margin: 20,
  },
  captureText: {
    fontSize: 14,
  },
  activeImg: {
    color: '#fff',
  },
  normalImg: {
    color: '#FFFFFF',
    opacity: 0.5,
  },
});
