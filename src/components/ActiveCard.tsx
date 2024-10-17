import React from 'react';
import {View, Text, StyleSheet} from 'react-native';
import type {PropsWithChildren} from 'react';
// import {SwitchBtn} from './SwitchBtn';

type Props = PropsWithChildren<{
  content: String;
}>;

export function ActivCard({content}: Props): JSX.Element {
  return (
    <View style={styles.card}>
      <Text style={styles.content}>{content}</Text>
      {/* <SwitchBtn /> */}
    </View>
  );
}

const styles = StyleSheet.create({
  content: {
    fontWeight: '400',
    fontSize: 16,
    color: 'rgba(0, 0, 0, 0.5)',
  },
  card: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
});
