import React, {PropsWithChildren, useEffect, useState} from 'react';
import {SafeAreaView, StyleSheet, View, FlatList, Text} from 'react-native';
import {TopBar} from 'components/TopBar';
import {IMAGE} from 'images';
import MyCastCard from 'components/MyCastCard';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import {FeedCard} from 'components/FeedCards/FeedCard';
import {ChannelFeedCard} from 'components/FeedCards/ChannelFeedCard';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const MyCast = ({navigation}: Props) => {
  const [isHidden, setIsHidden] = useState(false);
  const [feedData, setFeedData] = useState([]);
  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };

  useEffect(() => {
    const fetchFeed = async () => {
      try {
        const fidString = await AsyncStorage.getItem('fid');
        console.log(fidString);

        if (fidString) {
          const fid = JSON.parse(fidString);
          const url = `https://api.neynar.com/v2/farcaster/feed/user/casts?fid=${fid}&limit=100&include_replies=false&channel_id=chennai`;
          const response = await axios.get(url, options);
          // console.log(response.data, 'API Response');

          const reCastResponse = await axios.get(
            `https://api.neynar.com/v2/farcaster/reactions/user?fid=${fid}&type=recasts&limit=100`,
            options,
          );

          const casts = response.data.casts || []; // Ensure casts is an array
          const reCasts = reCastResponse.data?.cast || []; // Ensure reCasts is an array
          const reactionType = reCastResponse.data?.reaction_type;
          const feedData = [];

          // Process casts
          casts.forEach(cast => {
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

            const feedItem = {
              id: cast.hash,
              imageSource: imageUrl || '',
              location: cast.author.username,
              name: cast.author.display_name,
              description: cast.text,
              token: cast.token,
              time: cast.timestamp,
            };

            feedData.push(feedItem);
          });

          // Process reCasts
          reCasts.forEach(reCast => {
            let ImgUrl = null;
            if (reCast.embeds && reCast.embeds.length > 0) {
              const Image = reCast.embeds.find(
                embed =>
                  embed.url &&
                  embed.metadata &&
                  embed.metadata.content_type === 'image/jpeg',
              );
              ImgUrl = Image ? Image.url : '';
            }

            const ReCastItem = {
              id: reCast.hash,
              imageSource: ImgUrl || '',
              location: reCast.author.username,
              name: reCast.author.display_name,
              description: reCast.text,
              token: reCast.token,
              time: new Date(reCast.timestamp).toLocaleTimeString(),
              reaction_type: reactionType,
            };
            feedData.push(ReCastItem);
          });

          setFeedData(feedData);
        } else {
          console.error('No fid found in AsyncStorage');
        }
      } catch (error) {
        console.error('Error fetching feed data:', error);
      }
    };

    fetchFeed();
  }, []);

  const data = [
    {id: '1', imageSource: IMAGE.plainImg},
    {id: '2', imageSource: IMAGE.plainImg},
    {id: '3', imageSource: IMAGE.plainImg},
    {id: '4', imageSource: IMAGE.plainImg},
    {id: '5', imageSource: IMAGE.plainImg},
    {id: '6', imageSource: IMAGE.plainImg},
    {id: '7', imageSource: IMAGE.plainImg},
    {id: '8', imageSource: IMAGE.plainImg},
    {id: '9', imageSource: IMAGE.plainImg},
    {id: '10', imageSource: IMAGE.plainImg},
    {id: '11', imageSource: IMAGE.plainImg},
    {id: '12', imageSource: IMAGE.plainImg},
    {id: '13', imageSource: IMAGE.plainImg},
    {id: '14', imageSource: IMAGE.plainImg},
    {id: '15', imageSource: IMAGE.plainImg},
    {id: '16', imageSource: IMAGE.plainImg},
    {id: '17', imageSource: IMAGE.plainImg},
    {id: '18', imageSource: IMAGE.plainImg},
    {id: '19', imageSource: IMAGE.plainImg},
    {id: '20', imageSource: IMAGE.plainImg},
    {id: '21', imageSource: IMAGE.plainImg},
  ];

  // Toggle function to update isHidden state
  const handleToggle = () => {
    setIsHidden(!isHidden);
  };

  const renderSeparator = () => {
    return <View style={styles.separator} />;
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
          userName={item.location}
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

  return (
    <SafeAreaView style={styles.container}>
      <TopBar
        Title="Casts"
        Arrow={IMAGE.leftArrow}
        switchBtn
        isHidden={isHidden}
        onToggle={handleToggle}
        navBack={() => navigation.goBack()}
      />
      {/* <View style={styles.listContainer}> */}
      {isHidden ? (
        <View style={styles.waringContent}>
          <Text style={styles.waringTxt}>
            We don’t have any Tribe cast to show
          </Text>
        </View>
      ) : (
        //    <View style={styles.listContainer}>
        //    <FlatList
        //         key={isHidden ? 'castList' : 'castGrid'}
        //         data={data}
        //         renderItem={({item, index}) => (
        //           <MyCastCard
        //             imageSource={item.imageSource}
        //             style={{}}
        //             index={index}
        //           />
        //         )}
        //         keyExtractor={item => item.id}
        //         numColumns={3}
        //         ItemSeparatorComponent={renderSeparator}
        //         style={styles.FlatList}
        //       />
        //  </View>
        <FlatList
          key={isHidden ? 'feedGrid' : 'feedList'}
          // contentContainerStyle={styles.FlatList}
          data={feedData}
          renderItem={renderItem}
          keyExtractor={item => item.id}
          ItemSeparatorComponent={Separator}
          showsVerticalScrollIndicator={false}
          style={styles.FlatList}
        />
      )}
      {/* </View> */}
    </SafeAreaView>
  );
};

export default MyCast;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    margin: 16,
  },
  waringContent: {
    flex: 1,
    justifyContent: 'center',
  },
  waringTxt: {
    color: '#000',
    textAlign: 'center',
  },
  listContainer: {
    backgroundColor: '#fff',
    borderTopStartRadius: 16,
    borderTopEndRadius: 16,
    padding: 3,
    marginTop: 16,
  },
  separator: {
    height: 2,
  },
  seprator: {
    height: 16,
    // backgroundColor: 'red',
  },
  FlatList: {
    marginTop: 16,
  },
});
