import {Image, StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import React, {PropsWithChildren} from 'react';

type Props = PropsWithChildren<{
  image: any;
  title: string;
  onPress?: () => void;
}>;

const PostCard = ({title, image, onPress}: Props) => {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <Text>{title}</Text>
      <Image source={image} />
    </TouchableOpacity>
  );
};

export default PostCard;

const styles = StyleSheet.create({
  card: {
    flex: 1,
    justifyContent: 'center',
    alignContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#000',
    borderRadius: 16,
    margin: 8,
    padding: 14,
  },
});
