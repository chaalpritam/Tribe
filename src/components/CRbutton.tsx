import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity, Image} from 'react-native';
import type {PropsWithChildren} from 'react';
import {hp, wp} from 'utils/ScreenDimensions';
import {IMAGE} from 'images';

type Props = PropsWithChildren<{
  isActive?: boolean;
  onPress?: () => void;
}>;

export function CRbutton({onPress}: Props): JSX.Element {
  return (
    <TouchableOpacity onPress={onPress}>
      <View style={styles.btnActive}>
        <View style={styles.btnContent}>
          <Text style={styles.btnTxtActive}>Cast</Text>
          <Image style={styles.img} source={IMAGE.castArrow} />
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
  img: {
    marginLeft: 10,
  },
  btnTxtActive: {
    color: '#FFFFFF',
    fontWeight: '600',
    fontSize: 18,
    marginRight: 10,
  },
  btnActive: {
    backgroundColor: '#121212',
    borderRadius: 16,
    height: hp(7),
    width: wp(50, true) - 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
