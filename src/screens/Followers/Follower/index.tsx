import {StyleSheet, View, FlatList} from 'react-native';
import React, {PropsWithChildren, useEffect, useState} from 'react';
import FollowingCard from 'components/FollowingCard';
// import {FollowersData} from 'data';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import axios from 'axios';

type Props = PropsWithChildren<{
  userID?: any;
}>;

const Follower = ({userID}: Props) => {
  // const [followersData, setFollowersData] = useState(FollowersData);
  const [followingData, setFollowing] = useState([]);

  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };
  useEffect(() => {
    const FetchFollowing = async () => {
      try {
        const fidString = await AsyncStorage.getItem('fid');
        const fid = JSON.parse(fidString);
        const ID = userID ? userID : fid;
        const url = `https://api.neynar.com/v2/farcaster/followers?fid=${ID}&limit=100`;
        const response = await axios.get(url, options);

        const followersData = response.data.users.map(user => {
          return {
            id: user?.user.fid,
            img: user?.user.pfp_url,
            title: user?.user.display_name,
            userName: user?.user.username,
            description: user?.user?.profile?.bio?.text,
            follower: user?.user?.follower_count,
            following: user?.user?.following_count,
          };
        });
        setFollowing(followersData);
      } catch (error) {
        console.error('Error fetching user data:', error);
      }
    };
    FetchFollowing();
  }, []);

  const handleFollowing = async (id: string) => {
    try {
      const signerUuid = await AsyncStorage.getItem('signerUuid');
      const data = {
        signer_uuid: signerUuid,
        target_fids: [id],
      };

      const unFollow = await axios.delete(
        'https://api.neynar.com/v2/farcaster/user/follow',
        {
          headers: options.headers,
          data: data,
        },
      );
      console.log(unFollow.data, 'follow###');
      console.log(unFollow.status, 'follow****');
      const status = unFollow.data.success;

      if (status) {
        setFollowing(prevFollowing =>
          prevFollowing.map(user =>
            user.id === id ? {...user, isFollowing: true} : user,
          ),
        );
      }

      // Optionally update UI by removing the unfollowed user from the list
      setFollowing(prev => prev.filter(user => user.id !== id));
    } catch (error) {
      console.error('Error during unfollowing:', error);
    }
  };

  const Separator = () => <View style={styles.separator} />;

  console.log(followingData);

  return (
    <View style={styles.container}>
      <FlatList
        data={followingData}
        renderItem={({item}) => (
          <FollowingCard
            imageSource={item.img}
            userName={item.userName}
            description={item.description}
            following={item.isFollowing}
            onFollowingChange={() => handleFollowing(item.id)}
            viewingProfile={!!userID}
          />
        )}
        // keyExtractor={item => item.id.toString()}
        ItemSeparatorComponent={Separator}
      />
    </View>
  );
};

export default Follower;

const styles = StyleSheet.create({
  separator: {
    height: 8,
  },
  container: {
    marginVertical: 18,
  },
});
