import {
  ImageProps,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Image,
} from 'react-native';
import React, {PropsWithChildren} from 'react';
import {Colors} from 'configs';
import {hp, wp} from 'utils/ScreenDimensions';

type Props = PropsWithChildren<{
  image?: ImageProps;
  title?: string;
  onPress?: () => void;
  isSelected?: boolean;
}>;

const TribeCard = ({image, title, onPress, isSelected}: Props) => {
  return (
    <View>
      <TouchableOpacity onPress={onPress}>
        <Image
          source={image}
          style={[styles.card, isSelected && styles.selectedCard]}
        />
      </TouchableOpacity>
      <Text style={styles.title}>{title}</Text>
    </View>
  );
};

export default TribeCard;

const styles = StyleSheet.create({
  selectedCard: {
    borderRadius: 16,
    borderWidth: 2,
    borderColor: '#000000',
  },
  card: {
    borderRadius: 16,
    width: wp(43, true),
    height: hp(22),
  },
  title: {
    color: Colors.PrimaryColor,
    textAlign: 'center',
  },
});
