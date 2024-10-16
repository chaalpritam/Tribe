import {Image, StyleSheet, Text, View} from 'react-native';
import React, {PropsWithChildren} from 'react';
import {Colors} from 'configs';

type Props = PropsWithChildren<{
  image: any;
  count: string;
}>;

const WaitingCount = ({image, count}: Props) => {
  return (
    <View>
      <Image source={image} />
      <Text style={styles.text}>{count}+</Text>
    </View>
  );
};

export default WaitingCount;

const styles = StyleSheet.create({
  text: {
    fontFamily: 'Quicksand',
    fontWeight: '700',
    fontSize: 44,
    textAlign: 'center',
    color: Colors.PrimaryColor,
  },
});
