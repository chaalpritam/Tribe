import {
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  Image,
  TouchableOpacity,
  FlatList,
  Modal,
} from 'react-native';
import React, {
  useEffect,
  useState,
  PropsWithChildren,
  useCallback,
} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {IMAGE} from 'images';
import ProfileList from 'components/ProfileList';
import {hp, wp} from 'utils/ScreenDimensions';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const MyProfile = ({navigation}: Props) => {
  const [pfpUrl, setPfpUrl] = useState<string | null>(null);
  const [displayName, setdisplayName] = useState<string | null>(null);
  const [description, setDescription] = useState<string | null>(null);
  const [following, setFollowing] = useState<string | null>(null);
  const [followers, setFollowers] = useState<number | null>(null);
  const [userName, setuserName] = useState<string | null>(null);
  const [channelsData, setChannels] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const [modalVisible, setModalVisible] = useState(false);

  const handleNftCardPress = () => {
    setModalVisible(true); // Show modal when NftCard is pressed
  };

  const Separator = () => {
    return <View style={styles.seprator} />;
  };

  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };

  const fetchProfileDetails = async () => {
    try {
      const fidString = await AsyncStorage.getItem('fid');
      const fid = JSON.parse(fidString);

      const userProfile = await axios.get(
        `https://api.neynar.com/v2/farcaster/user/bulk?fids=${fid}`,
        options,
      );
      const profileDetails = userProfile.data.users[0];
      if (profileDetails) {
        setPfpUrl(profileDetails?.pfp_url || null);
        setdisplayName(profileDetails?.display_name || null);
        setDescription(profileDetails?.profile?.bio?.text || null);
        setFollowers(profileDetails?.follower_count || null);
        setFollowing(profileDetails?.following_count || null);
        setuserName(profileDetails?.username || null);
      }
    } catch (error) {
      console.error('Failed to load profile details:', error);
    }
  };

  const fetchChannel = async () => {
    try {
      const fidString = await AsyncStorage.getItem('fid');
      if (fidString) {
        const fid = JSON.parse(fidString);

        const ChannelResponse = await axios.get(
          `https://api.neynar.com/v2/farcaster/user/channels?fid=${fid}&limit=100`,
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

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    await Promise.all([fetchProfileDetails(), fetchChannel()]);
    setRefreshing(false);
  }, []);

  useEffect(() => {
    fetchProfileDetails();
    fetchChannel();
  }, []);

  const handleLogout = async () => {
    try {
      await AsyncStorage.clear();
      navigation.navigate('TribePager');
    } catch (error) {
      console.error('Error during logout:', error);
    }
  };

  const profileOptions = [
    {
      icon: IMAGE.bio,
      title: 'Casts',
      onPress: () => navigation.navigate('MyCast'),
    },
    {
      icon: IMAGE.favourits,
      title: 'Likes',
      onPress: () => navigation.navigate('MyLikes'),
    },
    {
      icon: IMAGE.favourits,
      title: 'NFTs',
      onPress: () => navigation.navigate('MyNfts'),
    },
    {
      icon: IMAGE.invite,
      title: 'Invite & Referral',
      onPress: () => handleNftCardPress(),
    },
    {
      icon: IMAGE.wallet,
      title: 'Wallet',
      // onPress: () => navigation.navigate('Wallet'),
      onPress: () => handleNftCardPress(),
    },
    {
      icon: IMAGE.wallet,
      title: 'Storage',
      // onPress: () => navigation.navigate('Storage'),
      onPress: () => handleNftCardPress(),
    },
    {
      icon: IMAGE.logout,
      title: 'Log out',
      onPress: handleLogout,
    },
  ];

  return (
    <>
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <View style={styles.imageContainer}>
            {pfpUrl ? (
              <Image style={styles.dp} source={{uri: pfpUrl}} />
            ) : (
              <Text>Loading Image...</Text>
            )}
            <TouchableOpacity style={styles.camera}>
              <Image style={styles.CameraImg} source={IMAGE.camera} />
            </TouchableOpacity>
          </View>
          <View style={styles.textContainer}>
            <Text style={styles.name}>{displayName}</Text>
            <Text style={styles.userName}>@{userName}</Text>
          </View>
          <Text style={styles.userName}>@{description}</Text>
        </View>
        <View style={styles.userFollowerCard}>
          <TouchableOpacity onPress={() => navigation.navigate('Followers')}>
            <Text style={styles.followText}>{following}</Text>
            <Text style={styles.txt}>Following</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => navigation.navigate('Followers')}>
            <Text style={styles.followText}>{followers}</Text>
            <Text style={styles.txt}>Followers</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => navigation.navigate('Followers')}>
            <Text style={styles.followText}>{channelsData.length}</Text>
            <Text style={styles.txt}>Channels</Text>
          </TouchableOpacity>
        </View>
        <FlatList
          data={profileOptions}
          keyExtractor={item => item.title}
          style={styles.flatlistContainer}
          renderItem={({item}) => (
            <ProfileList
              icon={item.icon}
              title={item.title}
              onPress={item.onPress}
            />
          )}
          contentContainerStyle={styles.ProfileListContainer}
          ItemSeparatorComponent={Separator}
          refreshing={refreshing}
          onRefresh={handleRefresh}
        />
      </SafeAreaView>
      <Modal
        animationType="slide"
        transparent={true}
        visible={modalVisible}
        onRequestClose={() => setModalVisible(false)}>
        <View style={styles.modalContainer}>
          <View style={styles.modalContent}>
            <Text style={styles.modalText}>
              This feature is under development
            </Text>
            <TouchableOpacity
              style={styles.closeButton}
              onPress={() => setModalVisible(false)}>
              <Text style={styles.closeButtonText}>Close</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </>
  );
};

export default MyProfile;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    margin: 16,
  },
  imageContainer: {
    position: 'relative',
  },
  dp: {
    width: wp(30),
    height: hp(15),
    borderRadius: 24,
  },
  camera: {
    position: 'absolute',
    // top: '75%',
    // left: '24%',
    bottom: 0,
    right: 0,
    backgroundColor: '#fff',
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  CameraImg: {},
  header: {
    alignItems: 'center',
    marginTop: hp(6),
    // flex: 1,
  },
  name: {
    fontSize: 24,
    color: '#202020',
    fontWeight: '600',
  },
  followText: {
    fontSize: 18,
    color: '#202020',
    fontWeight: '600',
    textAlign: 'center',
  },
  textContainer: {
    marginTop: 12,
  },
  userName: {
    fontSize: 16,
    color: '#202020',
    opacity: 0.5,
    fontWeight: '400',
    textAlign: 'center',
  },
  userFollowerCard: {
    backgroundColor: '#FEFEFE',
    borderRadius: 22,
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingVertical: hp(3),
    marginTop: 24,
  },
  txt: {
    fontSize: 12,
    color: '#202020',
    opacity: 0.5,
    fontWeight: '400',
    textAlign: 'center',
    marginTop: 8,
  },
  ProfileListContainer: {
    backgroundColor: '#FEFEFE',
    borderRadius: 16,
    paddingHorizontal: 16, // Keep paddingHorizontal static if needed
    paddingVertical: hp(2), // Dynamic vertical padding using hp
    marginTop: 20,
    bottom: 10,
  },
  seprator: {
    height: hp(3),
  },
  notifyIcon: {
    alignItems: 'flex-end',
  },
  flatlistContainer: {
    marginTop: 10,
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)', // Semi-transparent background
  },
  modalContent: {
    width: 300,
    padding: 20,
    backgroundColor: 'white',
    borderRadius: 10,
    alignItems: 'center',
  },
  modalText: {
    fontSize: 18,
    marginBottom: 20,
    textAlign: 'center',
    color: '#000',
  },
  closeButton: {
    backgroundColor: '#121212',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
  },
  closeButtonText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 16,
  },
});
