import {FlatList, SafeAreaView, StyleSheet, Text, View} from 'react-native';
import React, {PropsWithChildren, useEffect, useState} from 'react';
import {TopBar} from 'components/TopBar';
import {IMAGE} from 'images';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import {FeedCard} from 'components/Card/FeedCard';
import {ChannelFeedCard} from 'components/Card/ChannelFeedCard';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const MyLikes = ({navigation}: Props) => {
  const [isHidden, setIsHidden] = useState(false);
  const [likes, setLikes] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };

  useEffect(() => {
    fetchFeed();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchFeed(); // Refresh feed data
    setRefreshing(false);
  };

  const fetchFeed = async () => {
    try {
      const fidString = await AsyncStorage.getItem('fid');
      console.log(fidString);

      if (fidString) {
        const fid = JSON.parse(fidString);
        const url = `https://api.neynar.com/v2/farcaster/reactions/user?fid=${fid}&type=likes&limit=100`;
        const response = await axios.get(url, options);

        // Logging the full response to see its structure
        console.log('Response from API:', response);

        // Check if response data contains the 'reactions' field
        const Likes = response?.data?.reactions;
        if (Likes) {
          const feedData = [];

          Likes.forEach(like => {
            let imageUrl = null;

            if (like.cast.embeds && like.cast.embeds.length > 0) {
              const imageEmbed = like.cast.embeds.find(
                embed =>
                  embed.url &&
                  embed.metadata &&
                  embed.metadata.content_type === 'image/jpeg',
              );
              imageUrl = imageEmbed ? imageEmbed.url : '';
            }

            const feedItem = {
              id: like.cast.hash,
              imageSource: imageUrl || '',
              location: like.cast.author.username,
              name: like.cast.author.display_name,
              description: like.cast.text,
              token: like.cast.token,
              time: new Date(like.cast.timestamp).toLocaleTimeString(),
              reaction_type: like?.reaction_type,
            };

            feedData.push(feedItem);
          });
          setLikes(feedData);
        } else {
          console.error('No likes found in the response');
        }
      } else {
        console.error('No fid found in AsyncStorage');
      }
    } catch (error) {
      console.error('Error fetching likes data:', error);
    }
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
        />
      );
    }
  };

  const Separator = () => {
    return <View style={styles.seprator} />;
  };
  const handleToggle = () => {
    setIsHidden(!isHidden);
  };
  return (
    <SafeAreaView style={styles.container}>
      <TopBar
        Title="Likes"
        Arrow={IMAGE.leftArrow}
        switchBtn
        isHidden={isHidden}
        onToggle={handleToggle}
        navBack={() => navigation.goBack()}
      />
      {isHidden ? (
        <View style={styles.waringContent}>
          <Text style={styles.waringTxt}>
            We don’t have any filter cast to show
          </Text>
        </View>
      ) : (
        <FlatList
          key={isHidden ? 'feedGrid' : 'feedList'}
          // contentContainerStyle={styles.FlatList}
          data={likes}
          renderItem={renderItem}
          keyExtractor={(item, index) => `${item.id}-${index}`}
          ItemSeparatorComponent={Separator}
          showsVerticalScrollIndicator={false}
          style={styles.FlatList}
          refreshing={refreshing}
          onRefresh={onRefresh}
        />
      )}
    </SafeAreaView>
  );
};

export default MyLikes;

const styles = StyleSheet.create({
  waringContent: {
    flex: 1,
    justifyContent: 'center',
  },
  waringTxt: {
    color: '#000',
    textAlign: 'center',
  },
  seprator: {
    height: 16,
    // backgroundColor: 'red',
  },
  FlatList: {
    marginTop: 16,
  },
  container: {
    margin: 16,
    flex: 1,
  },
});
