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
  isActive?: boolean;
  onPress?: () => void;
}>;

export function SecondaryButton({
  title,
  isActive,
  onPress,
}: Props): JSX.Element {
  const btnStyle: ViewStyle = isActive ? styles.btnActive : styles.btnNormal;
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
    backgroundColor: '#FFF',
    borderRadius: 24,
    height: hp(4),
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 8,
  },
  btnTxt: {
    color: '#202020',
    textAlign: 'center',
    fontWeight: '400',
    fontSize: 12,
    marginHorizontal: 16,
  },
  btnTxtActive: {
    color: '#F4F4F4',
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
