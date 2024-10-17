import {Image, StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import React, {PropsWithChildren} from 'react';
import {Colors} from 'configs';

type Props = PropsWithChildren<{
  image: any;
  title: string;
  onPress?: () => void;
  isDisabled?: boolean;
}>;

const PostCard = ({title, image, onPress, isDisabled = false}: Props) => {
  return (
    <TouchableOpacity
      style={[styles.card, isDisabled && styles.disabledCard]} // Apply disabled style
      onPress={onPress}
      disabled={isDisabled} // Disable interaction
    >
      <Text style={[styles.txt, isDisabled && styles.disabledText]}>
        {title}
      </Text>
      <Image style={styles.img} source={image} />
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
  disabledCard: {
    backgroundColor: '#f0f0f0',
    opacity: 0.6,
    borderColor: '#BFBFBF',
  },
  txt: {
    color: Colors.PrimaryColor,
  },
  disabledText: {
    color: '#a0a0a0',
  },
  img: {
    marginVertical: 16,
  },
});
