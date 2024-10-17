import {StyleSheet, Text, View, SafeAreaView, FlatList} from 'react-native';
import React, {useEffect, useState} from 'react';
import {TopBar} from 'components/TopBar';
import {ExploreData, NFTData, VideoData, MusicData} from 'data'; // Different datasets
import {SecondaryButton} from 'components/SecondaryButton';
import {NftCard} from 'components/NftCard';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';

const Explore = () => {
  const [selectedId, setSelectedId] = useState<number | null>(
    ExploreData.length > 0 ? ExploreData[0].id : null,
  );
  const [selectedTitle, setSelectedTitle] = useState<string>(
    ExploreData.length > 0 ? ExploreData[0].name : 'Photos',
  );
  const [feedData, setFeedData] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const updateSelectedButton = (id: number, name: string) => {
    setSelectedId(id);
    setSelectedTitle(name);
  };
  useEffect(() => {
    fetchFeed();
  }, []);
  const options = {
    // method: 'GET',
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };
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

            if (imageUrl) {
              // Only push to feedData if imageUrl is found
              const feedItem = {
                id: cast.hash,
                imageSource: imageUrl,
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

              feedData.push(feedItem);
            }
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

  const getDataByTitle = () => {
    switch (selectedTitle) {
      case 'Photos':
        return feedData;
      case 'Videos':
        return VideoData;
      case 'Music':
        return MusicData;
      default:
        return [];
    }
  };

  const currentData = getDataByTitle();

  const renderNftCard = ({item}: any) => (
    <NftCard
      key={item.id}
      imageSource={item.imageSource}
      title={item.userName}
      follower={item.likes}
      //   created={item.token}
    />
  );

  return (
    <SafeAreaView style={styles.container}>
      <TopBar Title={selectedTitle} />
      <View style={styles.buttons}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={ExploreData}
          keyExtractor={item => item.id.toString()}
          renderItem={({item}) => (
            <SecondaryButton
              key={item.id}
              title={item.name}
              isActive={item.id === selectedId}
              onPress={() => updateSelectedButton(item.id, item.name)}
            />
          )}
        />
      </View>
      {currentData.length > 0 ? (
        <FlatList
          data={currentData}
          keyExtractor={item => item.id.toString()}
          renderItem={renderNftCard}
          numColumns={2} // Adjust number of columns
          columnWrapperStyle={styles.row} // To wrap items per row
          contentContainerStyle={styles.cardContainer}
          showsVerticalScrollIndicator={false}
        />
      ) : (
        <View style={styles.textContent}>
          <Text style={styles.developmentText}>
            {selectedTitle} section is in development, not yet live.
          </Text>
        </View>
      )}
    </SafeAreaView>
  );
};

export default Explore;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    margin: 16,
  },
  cardContainer: {
    marginTop: 24,
    paddingBottom: 16,
  },
  row: {
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  buttons: {
    marginTop: 24,
  },
  developmentText: {
    fontSize: 16,
    color: '#888',
    textAlign: 'center',
    marginTop: 24,
    justifyContent: 'center',
  },
  textContent: {
    flex: 1,
    justifyContent: 'center',
  },
});
