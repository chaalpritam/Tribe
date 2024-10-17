import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  ImageSourcePropType,
  TouchableOpacity,
} from 'react-native';
import type {PropsWithChildren} from 'react';
import {IMAGE} from 'images';

type Props = PropsWithChildren<{
  Arrow?: ImageSourcePropType;
  Title?: string;
  RightImageOne?: ImageSourcePropType;
  RightImageTwo?: ImageSourcePropType;
  onPress?: () => void;
  navBack?: () => void;
  switchBtn?: boolean;
  onToggle?: () => void;
  isHidden?: boolean;
}>;

export function TopBar({
  Arrow,
  Title,
  RightImageOne,
  RightImageTwo,
  onPress,
  navBack,
  switchBtn,
  onToggle,
  isHidden,
}: Props): JSX.Element {
  return (
    <View style={styles.container}>
      <View style={styles.left}>
        {Arrow && (
          <TouchableOpacity onPress={navBack}>
            <Image source={Arrow} style={styles.arrow} />
          </TouchableOpacity>
        )}
        <Text style={[styles.title, Arrow && styles.txt]}>{Title}</Text>
      </View>
      <View style={styles.right}>
        {RightImageOne && <Image source={RightImageOne} />}
        {RightImageTwo && (
          <TouchableOpacity onPress={onPress}>
            <Image source={RightImageTwo} />
          </TouchableOpacity>
        )}
        {switchBtn && (
          <View style={styles.feedChange}>
            <TouchableOpacity onPress={onToggle}>
              <Image
                style={[
                  styles.imgs,
                  isHidden ? styles.inactive : styles.active,
                ]}
                source={IMAGE.feesicon}
              />
            </TouchableOpacity>
            <View style={styles.line} />
            <TouchableOpacity onPress={onToggle}>
              <Image
                style={[
                  styles.imgs,
                  isHidden ? styles.active : styles.inactive,
                ]}
                source={IMAGE.feesicon2}
              />
            </TouchableOpacity>
          </View>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  imgs: {
    marginHorizontal: 8,
    marginVertical: 4,
    tintColor: '#000',
  },
  line: {
    borderLeftColor: '#202020',
    borderLeftWidth: 1,
    height: '100%',
    opacity: 0.1,
  },
  feedChange: {
    backgroundColor: '#FEFEFE',
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderRadius: 16,
    alignItems: 'center',
  },
  active: {
    tintColor: '#098BF8',
  },
  inactive: {
    tintColor: '#000',
  },
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  left: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  right: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  title: {
    fontWeight: '700',
    fontSize: 16,
    color: '#000000',
  },
  arrow: {
    marginRight: 16,
  },
  txt: {
    marginHorizontal: 16,
  },
});
