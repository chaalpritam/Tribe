import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ViewStyle,
} from 'react-native';
import type {PropsWithChildren} from 'react';
import {hp, wp} from 'utils/ScreenDimensions';

type Props = PropsWithChildren<{
  size: string;
  isActive: boolean;
  onPress: () => void;
}>;

export function SizeBtn({size, isActive, onPress}: Props): JSX.Element {
  const btnStyle: ViewStyle = isActive ? styles.btnActive : styles.btnNormal;
  return (
    <TouchableOpacity onPress={onPress}>
      <View style={[btnStyle]}>
        <Text style={[isActive ? styles.btnTxtActive : styles.btnTxt]}>
          {size}
        </Text>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  btnNormal: {
    backgroundColor: '#FEFEFE',
    borderRadius: 8,
    height: hp(8),
    width: wp(18, true),
    alignItems: 'center',
    justifyContent: 'center',
  },
  btnTxt: {
    color: '#000000',
    textAlign: 'center',
    fontWeight: '600',
    fontSize: 18,
    marginHorizontal: 12,
  },
  btnTxtActive: {
    color: '#FFFFFF',
    textAlign: 'center',
    fontWeight: '600',
    fontSize: 18,
    marginHorizontal: 12,
  },
  btnActive: {
    backgroundColor: '#098BF8',
    borderRadius: 8,
    height: hp(8),
    width: wp(18, true),
    alignItems: 'center',
    justifyContent: 'center',
  },
});
