import React from 'react';
import {StyleSheet, Text, TouchableOpacity, ViewStyle} from 'react-native';
import type {PropsWithChildren} from 'react';

type Props = PropsWithChildren<{
  title: string;
  onPress?: () => void;
  style?: ViewStyle;
}>;

const PrimaryButton = ({title, onPress, style}: Props) => {
  return (
    <TouchableOpacity onPress={onPress} style={[styles.btn, style]}>
      <Text style={styles.title}>{title}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  btn: {
    // height: 56,
    backgroundColor: '#121212',
    borderRadius: 16,
    alignItems: 'center',
  },
  title: {
    color: '#fff',
    fontSize: 16,
    marginVertical: 16,
  },
});

export default PrimaryButton;
