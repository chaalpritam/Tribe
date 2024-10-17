import React from 'react';
import {
  View,
  Image,
  StyleSheet,
  ImageSourcePropType,
  Text,
  TouchableOpacity,
} from 'react-native';
import type {PropsWithChildren} from 'react';

type Props = PropsWithChildren<{
  Arrow?: ImageSourcePropType;
  RightImageOne?: ImageSourcePropType;
  navigation?: any;
  closeModal?: any;
}>;

export function CBar({
  Arrow,
  RightImageOne,
  navigation,
  closeModal,
}: Props): JSX.Element {
  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.left} onPress={navigation}>
        {Arrow && <Image source={Arrow} />}
      </TouchableOpacity>

      <View style={styles.right}>
        {RightImageOne && <Image source={RightImageOne} />}
        <TouchableOpacity onPress={closeModal}>
          <Text style={styles.txt}>X</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  txt: {
    color: '#000000',
    fontSize: 22,
    marginLeft: 16,
    textAlign: 'center',
    fontWeight: '400',
    lineHeight: 24,
  },
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  right: {
    flexDirection: 'row',
    alignSelf: 'center',
  },
  left: {
    marginVertical: 8,
  },
});
