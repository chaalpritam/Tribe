import React, {memo} from 'react';
import {View, StyleSheet, Image, ImageSourcePropType, Text} from 'react-native';

interface OnboardingPageProps {
  imageSource?: ImageSourcePropType;
  title: string;
  description: string;
  isFirstItem?: boolean;
  isLastItem?: boolean;
}

const OnboardPage = memo(
  ({
    imageSource,
    description,
    isFirstItem,
    isLastItem,
    title,
  }: OnboardingPageProps) => {
    return (
      <View style={styles.page}>
        <View
          style={[
            styles.container,
            isFirstItem && styles.isFirstItem,
            isLastItem && styles.isLastItem,
          ]}>
          <Image
            source={imageSource}
            style={styles.image}
            // resizeMode="stretch"
          />
        </View>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.desc}>{description}</Text>
      </View>
    );
  },
);

export default OnboardPage;

const styles = StyleSheet.create({
  page: {
    // flex: 1,
    // justifyContent: 'center',
    // alignItems: 'center',
  },
  container: {
    // flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: '50%',
    // alignSelf: 'center',
    // You can add image specific styles here if needed
  },
  title: {
    color: '#1C2253',
    fontFamily: 'Mulish',
    fontSize: 26,
    fontWeight: '700',
    // textAlign: 'center',
    // marginTop: 16,
  },
  desc: {
    color: '#8F98B3',
    fontFamily: 'Mulish',
    fontSize: 16,
    fontWeight: '400',
    // textAlign: 'center',
    marginTop: 4,
    lineHeight: 22,
  },
  isFirstItem: {},
  isLastItem: {},
});
