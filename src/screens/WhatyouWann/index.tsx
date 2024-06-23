import {StyleSheet, Text, View} from 'react-native';
import React from 'react';

const WhatyouWann = ({route}) => {
  const {title} = route.params || {};
  return (
    <View>
      <Text>{title}</Text>
    </View>
  );
};

export default WhatyouWann;

const styles = StyleSheet.create({});
