/* eslint-disable react/no-unstable-nested-components */
import React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {Image, View, StyleSheet, Text} from 'react-native';
import Home from 'screens/Home';
import {IMAGE} from 'images';
import {hp} from 'utils/ScreenDimensions';
import WhatyouWanndo from 'screens/WhatyouWanndo';

const Bottom = createBottomTabNavigator();

export const Explore = () => {
  return <Text>Explore</Text>;
};

export const Notification = () => {
  return <Text>Notification</Text>;
};
export const MyProfile = () => {
  return <Text>MyProfile</Text>;
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
            <Image
              source={IMAGE.home1}
              style={focused ? styles.activeImg : styles.normalImg}
            />
          ),
        }}
      />
      <Bottom.Screen
        name="Explore"
        component={Explore}
        options={{
          tabBarIcon: ({focused}) => (
            <Image
              source={IMAGE.explore}
              style={focused ? styles.activeImg : styles.normalImg}
            />
          ),
        }}
      />
      <Bottom.Screen
        name="WhatyouWanndo"
        component={WhatyouWanndo}
        options={{
          tabBarIcon: ({focused}) => (
            <View style={styles.iconbg}>
              <Image source={focused ? IMAGE.plusIcon : IMAGE.plusIcon} />
            </View>
          ),
        }}
      />
      <Bottom.Screen
        name="Notification"
        component={Notification}
        options={{
          tabBarIcon: ({focused}) => (
            <Image
              source={focused ? IMAGE.marketplace1 : IMAGE.marketplace1}
              style={focused ? styles.activeImg : styles.normalImg}
            />
          ),
        }}
      />
      {/* <Bottom.Screen
        name="DirectCast"
        component={DirectCast}
        options={{
          tabBarIcon: ({focused}) => (
            <Image
              source={focused ? IMAGE.marketplace1 : IMAGE.marketplace1}
              style={focused ? styles.activeImg : styles.normalImg}
            />
          ),
        }}
      /> */}

      <Bottom.Screen
        name="MyProfile"
        component={MyProfile}
        options={{
          tabBarIcon: ({focused}) => (
            <Image
              source={IMAGE.profile1}
              style={focused ? styles.activeImg : styles.normalImg}
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
    tintColor: '#fff',
  },
  normalImg: {
    tintColor: '#FFFFFF',
    opacity: 0.5,
  },
});
