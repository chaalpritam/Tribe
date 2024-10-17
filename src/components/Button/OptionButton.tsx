import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ViewStyle,
} from 'react-native';
import type {PropsWithChildren} from 'react';
import {hp} from 'utils/ScreenDimensions';

type Props = PropsWithChildren<{
  title: string;
  isActive: boolean;
  onPress: () => void;
  style?: string;
  backgroundColor?: string;
}>;

export function OptionButton({
  title,
  isActive,
  onPress,
  backgroundColor,
}: Props): JSX.Element {
  const btnStyle: ViewStyle = isActive
    ? styles.btnActive
    : [styles.btnNormal, {backgroundColor: backgroundColor || '#FEFEFE'}];
  return (
    <TouchableOpacity onPress={onPress}>
      <View style={[btnStyle]}>
        <Text style={[isActive ? styles.btnTxtActive : styles.btnTxt]}>
          {title}
        </Text>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  btnNormal: {
    borderRadius: 24,
    height: hp(4),
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 8,
  },
  btnTxt: {
    color: '#000000',
    textAlign: 'center',
    fontWeight: '400',
    fontSize: 12,
    marginHorizontal: 16,
  },
  btnTxtActive: {
    color: '#FBF9FF',
    textAlign: 'center',
    fontWeight: '400',
    fontSize: 12,
    marginHorizontal: 16,
  },
  btnActive: {
    backgroundColor: '#098BF8',
    borderRadius: 24,
    height: hp(4),
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 8,
  },
});
