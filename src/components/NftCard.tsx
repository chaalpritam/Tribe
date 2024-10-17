import React, {useState} from 'react';
import {StyleSheet, Text, TouchableOpacity, Image, View} from 'react-native';
import type {PropsWithChildren} from 'react';
import {wp} from 'utils/ScreenDimensions';
import {IMAGE} from 'images';

type Props = PropsWithChildren<{
  imageSource?: string | number;
  title?: string;
  follower?: string;
  created?: string;
  onPress?: () => void;
  subscribe?: () => void;
  following?: boolean;
}>;

export function NftCard({
  imageSource,
  title,
  follower,
  created,
  onPress,
  subscribe,
  following,
}: Props): JSX.Element {
  const [isLiked, setIsLiked] = useState(false);
  const toggleLike = () => {
    setIsLiked(prevState => !prevState); // Toggle the like state
  };
  return (
    <View>
      <View style={styles.card}>
        <View style={styles.cardContent}>
          <TouchableOpacity style={styles.imageContent} onPress={onPress}>
            {imageSource ? (
              <Image
                style={styles.image}
                source={
                  typeof imageSource === 'string'
                    ? {uri: imageSource} // Handle URI string
                    : imageSource // Handle local image source
                }
              />
            ) : (
              <View style={styles.imagePlaceholder} /> // Handle null images
            )}
          </TouchableOpacity>
          <View style={styles.middle}>
            <Text style={styles.title}>{title}</Text>
            <TouchableOpacity onPress={toggleLike}>
              <Image
                source={isLiked ? IMAGE.disLike : IMAGE.like}
                // style={styles.save}
              />
            </TouchableOpacity>
          </View>
          <View style={styles.bottom}>
            <Text style={styles.subTitle}>{follower}</Text>
            <Text style={styles.subTitle}>{created}</Text>
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  save: {
    width: 13,
    height: 13,
  },
  middle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
    marginBottom: 4,
  },
  title: {
    color: '#18171E',
    fontWeight: '400',
    fontSize: 14,
    width: wp(35),
  },
  image: {
    width: '100%',
    borderRadius: 16,
    overflow: 'hidden',
    height: 147, // Ensure consistent height for the image
  },
  imagePlaceholder: {
    width: '100%',
    borderRadius: 16,
    overflow: 'hidden',
    height: 147,
    backgroundColor: '#E0E0E0', // Placeholder color
  },
  imageContent: {
    minHeight: 147,
    width: '100%',
    borderRadius: 16,
  },
  cardContent: {
    margin: 4,
    padding: 4,
  },
  card: {
    width: wp(50, true) - 24,
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    // elevation: 1,
    // opacity: 1,
    shadowColor: '#000',
  },
  bottom: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  subTitle: {
    color: '#9B9EBB',
    fontWeight: '400',
    fontSize: 12,
  },
});
