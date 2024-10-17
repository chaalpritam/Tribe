import React from 'react';
import {View, Image, StyleSheet} from 'react-native';
import type {PropsWithChildren} from 'react';
import {wp} from 'utils/ScreenDimensions';

type Props = PropsWithChildren<{
  imageSource: any;
}>;

export function MintImg({imageSource}: Props): JSX.Element {
  return (
    <View style={styles.card}>
      <Image style={styles.card} source={imageSource} />
    </View>
  );
}
const styles = StyleSheet.create({
  card: {
    width: wp(100, true) - 48,
    height: wp(100, true) - 48,
    // backgroundColor: 'red',
    borderRadius: 20,
  },
});
