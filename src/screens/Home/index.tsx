import React, {useEffect, useState} from 'react';
import {
  FlatList,
  StyleSheet,
  Text,
  View,
  Image,
  TextInput,
  SafeAreaView,
} from 'react-native';
import type {PropsWithChildren} from 'react';
import {FeedCard} from 'components/FeedCards/FeedCard';
import {ChannelFeedCard} from 'components/FeedCards/ChannelFeedCard';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import FeedLoader from 'components/Loader/FeedLoader';
import {useNavigation} from '@react-navigation/native';

import BottomSheets from 'components/BottomSheet';

const Home = () => {
  const navigation = useNavigation();
  const [isLoading, setIsLoading] = useState(true);
  const [feedData, setFeedData] = useState([]);
  const [isCommentVisible, setCommentVisible] = useState(false);
  const [selectedFeedItem, setSelectedFeedItem] = useState(null);
  const [replyText, setReplyText] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  // const [feedDataWithMedia, setFeedDataWithMedia] = useState([]);
  // const [feedDataWithoutMedia, setFeedDataWithoutMedia] = useState([]);

  const renderSkeletonItem = () => <FeedLoader />;
  const Separator = () => <View style={styles.seprator} />;
  // console.log(castStatus, 'status');
  const options = {
    // method: 'GET',
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };
  useEffect(() => {
    fetchFeed();
  }, []);

  const fetchFeed = async () => {
    try {
      setIsLoading(true);
      const channelId = await AsyncStorage.getItem('channelID');
      console.log(channelId);

      if (channelId) {
        const Cid = channelId;
        // console.log(selectedChannelId, 'selectedChannelId====');
        const url = `https://api.neynar.com/v2/farcaster/feed/channels?channel_ids=${Cid}&with_recasts=true&with_replies=false&members_only=true&limit=100&should_moderate=false`;

        // console.log(url, 'API URL');
        const response = await axios.get(url, options);
        // console.log(response.data, 'API Response');

        const casts = response.data.casts;
        const feedData = [];

        casts.forEach(
          (cast: {
            embeds: any[];
            hash: any;
            author: {username: any; display_name: any};
            text: any;
            token: any;
            timestamp: string | number | Date;
            replies: {count: any};
            reactions: {likes_count: any};
            channel: {id: any};
          }) => {
            let imageUrl = null;

            if (cast.embeds && cast.embeds.length > 0) {
              const imageEmbed = cast.embeds.find(
                embed =>
                  embed.url &&
                  embed.metadata &&
                  embed.metadata.content_type === 'image/jpeg',
              );
              imageUrl = imageEmbed ? imageEmbed.url : '';
            }

            // console.log(imageUrl, 'ImageURLs');

            const feedItem = {
              id: cast.hash,
              imageSource: imageUrl || '',
              location: cast.author.username,
              name: cast.author.display_name,
              description: cast.text,
              token: cast.token,
              time: cast.timestamp,
              userName: cast.author.username,
              replies: cast.replies.count,
              likes: cast.reactions.likes_count,
              channel: cast.channel ? cast.channel.id : null,
            };

            // if (imageUrl) {
            //   dataWithMedia.push(feedItem);
            // } else {
            //   dataWithoutMedia.push(feedItem);
            // }
            feedData.push(feedItem);
          },
        );
        setFeedData(feedData);
        // setFeedDataWithMedia(dataWithMedia);
        // setFeedDataWithoutMedia(dataWithoutMedia);
      } else {
        console.error('No fid found in AsyncStorage');
      }
    } catch (error) {
      console.error('Error fetching feed data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // console.log(feedData[0], 'feeds');
  // console.log(selectedChannelId, 'selectedChannelId');

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchFeed(); // Refresh feed data
    setRefreshing(false);
  };
  const handleCommentPress = item => {
    setSelectedFeedItem(item); // Set the selected feed item
    setCommentVisible(true); // Open BottomSheet
  };

  const handleNav = (item: any) => {
    return () => {
      navigation.navigate('Conversation', {feedItem: item});
    };
  };
  const handleChannelNav = (channelId: string) => {
    return () => {
      navigation.navigate('ChannelDetails', {item: channelId});
    };
  };
  const handleNavtoLikes = (item: any) => {
    return () => {
      console.log(item.likes, 'likes');
      const like = item.likes;
      if (like > 0) {
        // Ensure item.likes exists and has length > 0
        navigation.navigate('Likedlist', {feedHash: item.id});
      }
    };
  };
  const renderItem = ({item}) => {
    if (item.imageSource) {
      return (
        <FeedCard
          imageSource={item.imageSource ? item.imageSource : ''}
          location={item.location}
          name={item.name}
          description={item.description}
          token={item.token}
          time={item.time}
          hash={item.id}
          userName={item.userName}
          replies={item.replies}
          likes={item.likes}
          channel={item.channel}
          commentPress={() => handleCommentPress(item)}
          onPress={handleNav(item)}
          likePress={handleNavtoLikes(item)}
          repliesPress={handleNav(item)}
          channelOnPress={handleChannelNav(item.channel)}
        />
      );
    } else {
      return (
        <ChannelFeedCard
          userName={item.location}
          location={item.location}
          name={item.name}
          description={item.description}
          tag={item.token}
          time={item.time}
          hash={item.id}
          replies={item.replies}
          likes={item.likes}
          channel={item.channel}
          commentPress={() => handleCommentPress(item)}
          onPress={handleNav(item)}
          likePress={handleNavtoLikes(item)}
          repliesPress={handleNav(item)}
          channelOnPress={handleChannelNav(item.channel)}
        />
      );
    }
  };

  const ReplyPost = async () => {
    try {
      const signerUuid = await AsyncStorage.getItem('signerUuid');

      const optionss = {
        method: 'POST',
        headers: {
          accept: 'application/json',
          api_key: PUBLIC_NEYNAR_API_KEY,
          'content-type': 'application/json',
        },
        data: {
          // embeds: [
          //   {
          //     url: image,
          //   },
          // ],
          parent: selectedFeedItem?.id,
          text: replyText,
          signer_uuid: signerUuid,
        },
      };
      const replyResponse = await axios.post(
        'https://api.neynar.com/v2/farcaster/cast',
        optionss.data,
        {headers: optionss.headers},
      );

      const replyStatus = replyResponse.data?.success;
      if (replyStatus === true) {
        setReplyText('');
      } else {
        console.error('Failed to cast');
      }
      console.log(replyResponse.data, 'ReplyResponse');
    } catch (error: any) {
      if (error.response) {
        console.error('Response error:', error.response.data);
      } else {
        console.error('Error casting:', error.message);
      }
    }
  };

  return (
    <SafeAreaView>
      {isLoading ? (
        <FlatList
          style={{flexGrow: 1}}
          data={Array(5).fill(0)}
          contentContainerStyle={styles.FlatList}
          renderItem={renderSkeletonItem}
          ItemSeparatorComponent={Separator}
          showsVerticalScrollIndicator={false}
        />
      ) : (
        <FlatList
          // contentContainerStyle={styles.FlatList}
          data={feedData}
          renderItem={renderItem}
          keyExtractor={item => item.id}
          ItemSeparatorComponent={Separator}
          showsVerticalScrollIndicator={false}
          style={styles.FlatList}
          refreshing={refreshing}
          onRefresh={onRefresh}
        />
      )}
      {isCommentVisible && (
        <BottomSheets
          isVisible={isCommentVisible}
          setVisible={setCommentVisible}
          onCastPress={ReplyPost}>
          {selectedFeedItem?.imageSource ? (
            <FeedCard
              imageSource={selectedFeedItem?.imageSource}
              location={selectedFeedItem?.location}
              name={selectedFeedItem?.name}
              description={selectedFeedItem?.description}
              token={selectedFeedItem?.token}
              time={selectedFeedItem?.time}
              hash={selectedFeedItem?.id}
              userName={selectedFeedItem?.userName}
              replies={selectedFeedItem?.replies}
              likes={selectedFeedItem?.likes}
              channel={selectedFeedItem?.channel}
              backgroundColor="#F4F4F4"
            />
          ) : (
            <ChannelFeedCard
              userName={selectedFeedItem?.userName}
              location={selectedFeedItem?.location}
              name={selectedFeedItem?.name}
              description={selectedFeedItem?.description}
              tag={selectedFeedItem?.token}
              time={selectedFeedItem?.time}
              hash={selectedFeedItem?.id}
              replies={selectedFeedItem?.replies}
              likes={selectedFeedItem?.likes}
              channel={selectedFeedItem?.channel}
              backgroundColor="#F4F4F4"
            />
          )}
          <View style={styles.commentContent}>
            {/* {pfpUrl && (
              <Image source={{uri: pfpUrl}} style={styles.profileImage} />
            )} */}
            <Text style={styles.userTxt}>
              Replying to @{selectedFeedItem?.userName}
            </Text>
          </View>
          <TextInput
            placeholder="What’s happening ??"
            placeholderTextColor="#8F8F8F"
            value={replyText}
            onChangeText={setReplyText}
            style={styles.txtInput}
          />
        </BottomSheets>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  seprator: {
    height: 16,
  },
  FlatList: {
    marginTop: 16,
    // bottom: 10,
  },
  profileImage: {
    width: 32,
    height: 32,
    borderRadius: 50,
    marginVertical: 10,
  },
  commentContent: {
    flexDirection: 'row',
    marginHorizontal: 8,
  },
  userTxt: {
    color: '#202020',
    opacity: 0.5,
    fontSize: 12,
    textAlign: 'center',
    alignSelf: 'center',
    marginHorizontal: 8,
  },
  txtInput: {
    marginHorizontal: 8,
    marginBottom: 30,
    color: '#000',
  },
  waringTxt: {
    color: '#000',
    textAlign: 'center',
  },
  waringContent: {
    flex: 1,
    justifyContent: 'center',
  },
});

export default Home;
function useSelector(arg0: (state: RootState) => any) {
  throw new Error('Function not implemented.');
}
