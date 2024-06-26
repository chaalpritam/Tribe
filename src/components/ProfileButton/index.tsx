import {StyleSheet, Text, View, Image, TouchableOpacity} from 'react-native';
import React, {PropsWithChildren} from 'react';
import {IMAGE} from 'images';
import {Colors} from 'configs';

type Props = PropsWithChildren<{
  name: string;
  Wallet: string;
}>;

const formatString = (str: string) => {
  if (str.length <= 9) {
    return str; // Return the string as is if it's too short to format
  }
  const firstFive = str.substring(0, 5);
  const lastFour = str.substring(str.length - 4);
  return `${firstFive}.....${lastFour}`;
};

const ProfileButton = ({name, Wallet}: Props) => {
  return (
    <TouchableOpacity style={styles.btn}>
      <View>
        <Image source={IMAGE.Vector} style={styles.img} />
      </View>
      <View style={styles.Content}>
        <Text>{name}</Text>
        <Text>{formatString(Wallet)}</Text>
      </View>
    </TouchableOpacity>
  );
};

export default ProfileButton;

const styles = StyleSheet.create({
  Content: {
    marginHorizontal: 6,
  },
  img: {
    borderRadius: 50,
    borderWidth: 0.5,
    borderColor: Colors.PrimaryColor,
    width: 50,
    height: 50,
  },
  btn: {
    flexDirection: 'row',
    backgroundColor: '#4C606A1A',
    borderRadius: 30,
    padding: 5,
  },
});
