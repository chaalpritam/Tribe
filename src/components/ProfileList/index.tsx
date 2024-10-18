import {Image, StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import React, {PropsWithChildren} from 'react';
import {IMAGE} from 'images';

type Props = PropsWithChildren<{
  icon: any;
  title: any;
  onPress?: () => void;
}>;

const ProfileList = ({icon, title, onPress}: Props) => {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <View style={styles.cardLeft}>
        <Image source={icon} />
        <Text style={styles.title}>{title}</Text>
      </View>

      {title !== 'Log out' && <Image source={IMAGE.rightArrow} />}
    </TouchableOpacity>
  );
};

export default ProfileList;

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  title: {
    color: '#18171E',
    fontSize: 14,
    marginHorizontal: 16,
  },
  cardLeft: {
    flexDirection: 'row',
    // paddingVertical: 8,
  },
});
