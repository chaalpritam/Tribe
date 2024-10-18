import {StyleSheet, View, FlatList} from 'react-native';
import React, {PropsWithChildren, useEffect, useState} from 'react';
import UserChannelCard from 'components/UserChannelCard';
// import {FollowersData} from 'data';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import axios from 'axios';

type Props = PropsWithChildren<{
  userID?: any;
}>;

const Channels = ({userID}: Props) => {
  // const [followersData, setFollowersData] = useState(FollowersData);
  const [channelsData, setChannels] = useState([]);

  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };

  useEffect(() => {
    const fetchChannel = async () => {
      try {
        const fidString = await AsyncStorage.getItem('fid');
        if (fidString) {
          const fid = JSON.parse(fidString);
          const ID = userID ? userID : fid;
          const ChannelResponse = await axios.get(
            `https://api.neynar.com/v2/farcaster/user/channels?fid=${ID}&limit=100`,
            options,
          );

          const channels = ChannelResponse.data.channels;

          // Transform Channels data
          const updatedChannels = channels.map(channel => ({
            id: channel.id,
            name: channel.name,
            image: channel.image_url,
            description: channel.description,
          }));
          setChannels(updatedChannels);
        } else {
          console.error('No fid found in AsyncStorage');
        }
      } catch (error) {
        console.error('Error fetching feed data:', error);
      }
    };

    fetchChannel();
  }, []);
  console.log(channelsData.length, 'cheannel length');
  const ChannelUnSubscribe = async (channelId: string) => {
    try {
      console.log('====');
      const signerUuid = await AsyncStorage.getItem('signerUuid');
      if (!signerUuid) {
        throw new Error('signerUuid not found');
      }

      const body = {
        channel_id: channelId,
        signer_uuid: signerUuid,
      };

      const headers = {
        accept: 'application/json',
        api_key: PUBLIC_NEYNAR_API_KEY,
        'content-type': 'application/json',
      };
      console.log(headers, body, 'Body');
      const UnSubScribe = await axios.delete(
        'https://api.neynar.com/v2/farcaster/channel/follow',
        {
          headers: headers,
          data: body,
        },
      );
      console.log(UnSubScribe.data, 'UnSubscribe Response');
    } catch (error) {
      if (error.response) {
        console.error('Response error:', error.response.data);
      } else {
        console.error('Error:', error.message);
      }
    }
  };

  // const handleFollowing = id => {
  //   setFollowersData(prevData =>
  //     prevData.map(item =>
  //       item.id === id ? {...item, following: !item.following} : item,
  //     ),
  //   );
  // };

  const Separator = () => <View style={styles.separator} />;

  return (
    <View style={styles.container}>
      <FlatList
        data={channelsData}
        renderItem={({item}) => (
          <UserChannelCard
            imageSource={item.image}
            userName={item.name}
            description={item.description}
            following={true}
            onFollowingChange={() => ChannelUnSubscribe(item.id)}
          />
        )}
        keyExtractor={item => item.id.toString()}
        ItemSeparatorComponent={Separator}
        showsVerticalScrollIndicator={false}
      />
    </View>
  );
};

export default Channels;

const styles = StyleSheet.create({
  separator: {
    height: 8,
  },
  container: {
    marginVertical: 18,
  },
});
