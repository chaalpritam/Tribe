import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity, Image} from 'react-native';
import type {PropsWithChildren} from 'react';
import {hp, wp} from 'utils/ScreenDimensions';
import {IMAGE} from 'images';

type Props = PropsWithChildren<{
  isActive?: boolean;
  onPress?: () => void;
}>;

export function Cbutton({onPress}: Props): JSX.Element {
  return (
    <TouchableOpacity onPress={onPress}>
      <View style={styles.btnNormal}>
        <View style={styles.btnContent}>
          <Text style={styles.btnTxt}>Save</Text>
          <Image style={styles.img} source={IMAGE.download} />
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  btnContent: {
    justifyContent: 'space-between',
    alignItems: 'center',
    flexDirection: 'row',
  },
  btnNormal: {
    backgroundColor: '#FEFEFE',
    borderRadius: 16,
    height: hp(7),
    width: wp(50, true) - 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  btnTxt: {
    color: '#000000',
    fontWeight: '600',
    fontSize: 18,
    marginRight: 10,
  },
  img: {
    marginLeft: 10,
  },
});
