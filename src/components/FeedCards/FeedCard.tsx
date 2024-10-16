import React, {useRef, useState} from 'react';
import {View, Image, StyleSheet, Text, TouchableOpacity} from 'react-native';
import type {PropsWithChildren} from 'react';
import {IMAGE} from 'images';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Props = PropsWithChildren<{
  imageSource?: string | null;
  location?: string;
  name: string;
  description: string;
  token: string;
  time: string;
  onPress?: () => void;
  hash?: string;
  userName?: string;
  replies?: string;
  likes?: string;
  channel?: string;
  commentPress?: () => void;
  backgroundColor?: string;
  likePress?: () => void;
  repliesPress?: () => void;
  channelOnPress?: () => void;
  line?: boolean;
}>;

export function FeedCard({
  imageSource,
  location,
  name,
  description,
  token,
  time,
  onPress,
  hash,
  userName,
  replies,
  likes,
  channel,
  commentPress,
  backgroundColor = '#FEFEFE',
  likePress,
  repliesPress,
  line,
  channelOnPress,
}: Props): JSX.Element {
  const [isTruncated, setIsTruncated] = useState(true);
  const [isLiked, setIsLiked] = useState(false);
  const [isRecast, setRecasted] = useState(false);
  const toggleTruncation = () => {
    setIsTruncated(!isTruncated);
  };

  // console.log(hash, 'Hash');

  const toggleLike = async () => {
    // Immediately update the state to change the image
    const previousLikeState = isLiked;
    setIsLiked(!isLiked);

    const signerUuid = await AsyncStorage.getItem('signerUuid');
    const options = {
      headers: {
        accept: 'application/json',
        api_key: PUBLIC_NEYNAR_API_KEY,
        'content-type': 'application/json',
      },
      data: {
        reaction_type: 'like',
        signer_uuid: signerUuid.trim(),
        target: hash,
      },
    };

    try {
      let response;
      if (previousLikeState) {
        // User is unliking the post
        response = await axios.delete(
          'https://api.neynar.com/v2/farcaster/reaction',
          {
            data: options.data,
            headers: options.headers,
          },
        );
      } else {
        // User is liking the post
        response = await axios.post(
          'https://api.neynar.com/v2/farcaster/reaction',
          options.data,
          {headers: options.headers},
        );
      }
      console.log('API Response:', response.data);
    } catch (error) {
      // Revert the state if there was an error
      setIsLiked(previousLikeState);

      if (error.response) {
        console.error('Response error:', error.response.data);
      } else {
        console.error('Error casting:', error.message);
      }
    }
  };

  const recast = async () => {
    setRecasted(!isRecast);
    try {
      // Retrieve and log the signerUuid
      const signerUuid = await AsyncStorage.getItem('signerUuid');
      console.log('Raw signerUuid:', signerUuid, typeof signerUuid);

      const options = {
        method: 'POST',
        headers: {
          accept: 'application/json',
          api_key: PUBLIC_NEYNAR_API_KEY,
          'content-type': 'application/json',
        },
        data: {
          reaction_type: 'recast',
          signer_uuid: signerUuid.trim(),
          target: hash,
        },
      };

      const response = await axios.post(
        'https://api.neynar.com/v2/farcaster/reaction',
        options.data,
        {headers: options.headers},
      );

      const castSuccess = response.data?.success;

      console.log(castSuccess);
    } catch (error) {
      if (error.response) {
        console.error('Response error:', error.response.data);
      } else {
        console.error('Error casting:', error.message);
      }
    }
  };

  const getTimeDifference = timestamp => {
    const now = new Date();
    const postDate = new Date(timestamp);
    const diffInMilliseconds = now - postDate;
    const diffInSeconds = Math.floor(diffInMilliseconds / 1000);
    const diffInMinutes = Math.floor(diffInSeconds / 60);
    const diffInHours = Math.floor(diffInMinutes / 60);
    const diffInDays = Math.floor(diffInHours / 24);

    if (diffInDays >= 7) {
      return postDate.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
      });
    } else if (diffInDays >= 1) {
      return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago`;
    } else if (diffInHours >= 1) {
      return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago`;
    } else if (diffInMinutes >= 1) {
      return `${diffInMinutes} minute${diffInMinutes > 1 ? 's' : ''} ago`;
    } else {
      return 'Just now';
    }
  };

  return (
    // <TouchableOpacity onPress={onPress}>
    <>
      <View style={[styles.card, {backgroundColor}]}>
        <View style={styles.cardContent}>
          <TouchableOpacity style={styles.imageContent} onPress={onPress}>
            {imageSource ? (
              <Image
                source={
                  typeof imageSource === 'string' ? {uri: imageSource} : null
                }
                style={styles.image}
                resizeMode="cover"
              />
            ) : // <FastImage

            //   style={styles.image}x
            //   source={{
            //     uri: imageSource,
            //     priority: FastImage.priority.normal,
            //   }}
            //   resizeMode={FastImage.resizeMode.cover}
            //   // onError={() => {
            //   //   console.error('Failed to load image:', imageSource);
            //   // }}
            // />
            // <View style={styles.placeholder}>
            //   <Text style={styles.placeholderText}>No Image</Text>
            // </View>
            null}
            <View style={styles.locationBtn}>
              <Text style={styles.locationtxt}>{location}</Text>
            </View>
          </TouchableOpacity>
          <View style={styles.icons}>
            <View style={styles.iconsright}>
              <TouchableOpacity onPress={toggleLike}>
                <Image
                  source={isLiked ? IMAGE.disLike : IMAGE.like}
                  style={styles.icon}
                />
              </TouchableOpacity>
              <TouchableOpacity onPress={recast}>
                <Image source={IMAGE.repost} style={[styles.shareIcon]} />
              </TouchableOpacity>
              <TouchableOpacity onPress={commentPress}>
                <Image source={IMAGE.comment} style={[styles.shareIcon]} />
              </TouchableOpacity>
            </View>
            {/* <View>
              <Image source={IMAGE.save} style={styles.icon} />
            </View> */}
          </View>
          <View style={styles.textContent}>
            {/* <TouchableOpacity onPress={toggleTruncation}> */}
            <View style={styles.userNameAndTimeContent}>
              <Text style={styles.name}>
                {name}
                <Text style={styles.spacing}> </Text>
                <Text style={styles.usrName}>@{userName}</Text>
              </Text>
              <Text style={styles.txt}>{getTimeDifference(time)}</Text>
            </View>
            <Text style={styles.description}>{description}</Text>
            {/* </TouchableOpacity> */}
            {/* {isTruncated && (
      <TouchableOpacity onPress={toggleTruncation}>
        <Text style={styles.readMore}>More</Text>
      </TouchableOpacity>
    )} */}
          </View>
          <View style={styles.cardBottom}>
            {/* <Text style={styles.txt}>{token}</Text> */}
            {/* <Text style={styles.txt}>{time}</Text> */}

            <View style={styles.iconsright}>
              <Text style={styles.reply} onPress={repliesPress}>
                {replies}
                <Text style={styles.spacing}> </Text>
                <Text style={styles.replyTxt}>replies</Text>
              </Text>
              <Text style={styles.like} onPress={likePress}>
                {likes}
                <Text style={styles.spacing}> </Text>
                <Text style={styles.likeTxt}>likes</Text>
              </Text>
              <Text onPress={channelOnPress}>
                {channel ? `/${channel}` : ''}
              </Text>
            </View>
            <View>{/* <Text style={styles.mint}>Base Mint</Text> */}</View>
          </View>
        </View>
        {line ? <View style={styles.line} /> : null}
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  line: {
    borderWidth: 0.5,
    borderBottomColor: '#4A4A4A',
    width: '100%',
    marginTop: 8,
    // opacity: 0.2,
  },
  userNameAndTimeContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  shareIcon: {
    marginHorizontal: 16,
    marginTop: 4,
  },
  reply: {
    color: '#000',
    fontWeight: '600',
    fontSize: 14,
    // lineHeight: 20,
  },
  replyTxt: {
    color: '#000',
    fontWeight: '400',
    fontSize: 14,
  },
  like: {
    color: '#000',
    fontWeight: '600',
    fontSize: 14,
    marginHorizontal: 8,
    // lineHeight: 20,
  },
  likeTxt: {
    color: '#000',
    fontWeight: '400',
    fontSize: 14,
  },
  txt: {
    color: '#000',
    fontWeight: '400',
    fontSize: 10,
  },
  textContent: {
    marginTop: 16,
  },
  cardBottom: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
  },
  readMore: {
    color: 'rgba(130, 130, 130, 1)',
    fontWeight: '600',
    fontSize: 12,
  },
  name: {
    color: '#000',
    fontWeight: '700',
    fontSize: 14,
  },
  description: {
    color: '#000',
    opacity: 0.5,
    fontWeight: '600',
    fontSize: 12,
    marginTop: 8,
    // paddingLeft: 10,
  },
  card: {
    borderRadius: 32,
    padding: 16,
  },
  cardContent: {},
  imageContent: {
    borderRadius: 24,
  },
  image: {
    width: '100%',
    height: 311,
    borderRadius: 24,
  },
  locationBtn: {
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    height: 16,
    borderRadius: 16,
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
    top: 10,
    alignSelf: 'flex-end',
    right: 10,
  },
  locationtxt: {
    marginHorizontal: 8,
    fontWeight: '600',
    fontSize: 8,
    color: '#FFFF', // Correctly applied color to Text
  },
  icons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
  },
  iconsright: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    // backgroundColor: 'red',
  },
  icon: {
    // tintColor: '#000', // Use tintColor for Image components
    marginHorizontal: 8,
    marginVertical: 4,
  },
  spacing: {
    marginRight: 8, // Adjust the gap size as needed
  },
  placeholder: {
    justifyContent: 'center',
    alignItems: 'center',
    height: 311,
    borderRadius: 24,
    backgroundColor: '#f0f0f0',
  },
  usrName: {
    color: '#202020',
    fontWeight: '400',
    fontSize: 12,
    margin: 2,
  },
  placeholderText: {
    color: '#888',
    fontSize: 14,
  },
  commentHeader: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    paddingHorizontal: 10,
  },
  mint: {
    color: '#202020',
    textDecorationLine: 'underline',
    fontSize: 10,
    fontWeight: '600',
  },
});
