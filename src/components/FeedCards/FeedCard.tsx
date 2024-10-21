import React, {useEffect, useRef, useState} from 'react';
import {View, Image, StyleSheet, Text, TouchableOpacity} from 'react-native';
import type {PropsWithChildren} from 'react';
import {IMAGE} from 'images';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Icon from 'react-native-vector-icons/Ionicons';
import {wp} from 'utils/ScreenDimensions';

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
  pfpUrl?: string;
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
  pfpUrl,
}: Props): JSX.Element {
  const [isTruncated, setIsTruncated] = useState(true);
  const [isLiked, setIsLiked] = useState(false);
  const [isRecast, setRecasted] = useState(false);

  const toggleTruncation = () => {
    setIsTruncated(!isTruncated);
  };

  // useEffect(() => {
  //   const fetchProfileDetails = async () => {
  //     try {
  //       const profileDetail = await AsyncStorage.getItem('profileDetail');
  //       if (profileDetail) {
  //         const profileImg = JSON.parse(profileDetail);
  //         setPfpUrl(profileImg?.user?.pfp_url || null);
  //       }
  //     } catch (error) {
  //       console.error('Error fetching profile details:', error);
  //     }
  //   };

  //   fetchProfileDetails();
  // }, []);

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
      return `${diffInHours} hr${diffInHours > 1 ? 's' : ''} ago`;
    } else if (diffInMinutes >= 1) {
      return `${diffInMinutes} min${diffInMinutes > 1 ? 's' : ''} ago`;
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
            {imageSource && (
              <Image
                source={
                  typeof imageSource === 'string' ? {uri: imageSource} : null
                }
                style={styles.image}
                resizeMode="cover"
              />
            )}
            <View style={styles.locationBtn}>
              <Text style={styles.locationtxt}>{location}</Text>
            </View>
          </TouchableOpacity>

          <View style={styles.textContent}>
            {/* <TouchableOpacity onPress={toggleTruncation}> */}
            <View style={styles.userNameAndTimeContent}>
              <View style={styles.profileContainer}>
                {pfpUrl && (
                  <Image source={{uri: pfpUrl}} style={styles.profileImage} />
                )}
                <Text style={styles.name}>
                  {name}
                  <Text style={styles.spacing}> </Text>
                  <Text style={styles.usrName}>@{userName}</Text>
                </Text>
              </View>

              <Text style={styles.txt}>{getTimeDifference(time)}</Text>
            </View>
            <Text style={styles.description} onPress={onPress}>
              {description}
            </Text>
          </View>
          <View style={styles.icons}>
            <View style={styles.iconsright}>
              <View style={styles.iconCotent}>
                <TouchableOpacity onPress={toggleLike} style={styles.icon}>
                  {isLiked ? (
                    <Icon name="heart" size={24} color="#000" />
                  ) : (
                    <Icon name="heart-outline" size={24} color="#000" />
                  )}
                </TouchableOpacity>
                {likes !== 0 && (
                  <Text style={styles.like} onPress={likePress}>
                    {likes} {/* Display the count of likes */}
                  </Text>
                )}
              </View>

              <TouchableOpacity
                onPress={recast}
                style={[styles.icon, styles.shareIcon]}>
                <Icon name="repeat" size={24} color="#000" />
              </TouchableOpacity>
              <TouchableOpacity
                onPress={commentPress}
                style={[styles.icon, styles.shareIcon]}>
                <Icon name="chatbubbles-outline" size={24} color="#000" />
                {replies !== 0 && (
                  <Text style={styles.reply} onPress={repliesPress}>
                    {replies}
                  </Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
        {line ? <View style={styles.line} /> : null}
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  profileContainer: {
    flexDirection: 'row',
  },
  profileImage: {
    width: 16,
    height: 16,
    borderRadius: 8,
    marginRight: 12,
  },
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
    flexDirection: 'row',
  },
  reply: {
    color: '#000',
    fontWeight: '600',
    fontSize: 14,
    marginTop: 4,
    marginHorizontal: 8,
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
    marginTop: 8,
    marginHorizontal: 4,
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
    // backgroundColor: 'red',
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
    width: wp(87, true),
    aspectRatio: 1,
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
    marginRight: 8,
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
  iconCotent: {
    flexDirection: 'row',
  },
});
