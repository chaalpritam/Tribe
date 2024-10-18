import {
  FlatList,
  StyleSheet,
  View,
  SafeAreaView,
  TextInput,
  Text,
  Image,
} from 'react-native';
import React, {PropsWithChildren, useEffect, useState} from 'react';
import {TopBar} from 'components/TopBar';
import {IMAGE} from 'images';
import {useRoute} from '@react-navigation/native';
import {FeedCard} from 'components/Card/FeedCard';
import {ChannelFeedCard} from 'components/Card/ChannelFeedCard';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
import axios from 'axios';
import ReplyCard from 'components/Replycard';
import BottomSheets from 'components/BottomSheet';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Props = PropsWithChildren<{
  navigation: any;
}>;

const Conversation = ({navigation}: Props) => {
  const route = useRoute();
  const {feedItem} = route.params;
  const [repliesData, setRepliesData] = useState([]);
  const [isCommentVisible, setCommentVisible] = useState(false);
  const [pfpUrl, setPfpUrl] = useState<string | null>(null);
  const [selectedFeedItem, setSelectedFeedItem] = useState(null);
  const [replyText, setReplyText] = useState('');
  console.log(feedItem, 'SelectedItem');
  const options = {
    headers: {accept: 'application/json', api_key: PUBLIC_NEYNAR_API_KEY},
  };

  useEffect(() => {
    const fetchUserImg = async () => {
      try {
        const img = await AsyncStorage.getItem('profileDetail');
        if (img) {
          const profileImg = JSON.parse(img);
          setPfpUrl(profileImg?.user?.pfp_url || null);
        }
      } catch (error) {
        console.error('Failed to load profile details:', error);
      }
    };
    fetchUserImg();
  }, []);

  useEffect(() => {
    const identifier = feedItem?.id;
    console.log(identifier, 'identifier');
    const fetchConversation = async () => {
      try {
        if (identifier) {
          const ConversationResponse = await axios.get(
            `https://api.neynar.com/v2/farcaster/cast/conversation?identifier=${identifier}&type=hash&reply_depth=5&include_chronological_parent_casts=false&limit=50`,
            options,
          );
          // console.log(
          //   ConversationResponse.data?.conversation?.cast?.direct_replies,
          //   'DirectReplies',
          // );
          const convo =
            ConversationResponse.data?.conversation?.cast?.direct_replies;
          const ConvoList = convo.map(convoItem => ({
            id: convoItem.hash,
            imageSource: convoItem.author.pfp_url,
            name: convoItem.author.display_name,
            reply: convoItem.text,
            userName: convoItem.author.username,
            replies: convoItem.replies.count,
            likes: convoItem.reactions.likes_count,
          }));
          setRepliesData(ConvoList);
        } else {
          console.error('No identifier');
        }
      } catch (error) {
        console.error('Error fetching feed data:', error);
      }
    };
    fetchConversation();
  }, []);

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

  const renderItem = ({item}) => (
    <ReplyCard
      imageSource={item.imageSource}
      name={item.name}
      userName={item.userName}
      replyTxt={item.reply}
      replyCount={item.replies}
      likesCount={item.likes}
      commentPress={() => handleCommentPress(item)}
    />
  );

  const handleCommentPress = item => {
    setSelectedFeedItem(item); // Set the selected feed item
    setCommentVisible(true); // Open BottomSheet
  };

  return (
    <SafeAreaView style={styles.container}>
      <TopBar
        Title="Conversation"
        Arrow={IMAGE.leftArrow}
        navBack={() => navigation.goBack()}
      />
      <FlatList
        data={repliesData}
        renderItem={renderItem}
        keyExtractor={item => item.id}
        ListHeaderComponent={
          feedItem?.imageSource ? (
            <FeedCard
              imageSource={feedItem?.imageSource}
              location={feedItem?.location}
              name={feedItem?.name}
              description={feedItem?.description}
              token={feedItem?.token}
              time={feedItem?.time}
              hash={feedItem?.id}
              userName={feedItem?.userName}
              replies={feedItem?.replies}
              likes={feedItem?.likes}
              channel={feedItem?.channel}
              backgroundColor="#F4F4F4"
              line={true}
            />
          ) : (
            <ChannelFeedCard
              userName={feedItem?.userName}
              location={feedItem?.location}
              name={feedItem?.name}
              description={feedItem?.description}
              tag={feedItem?.token}
              time={feedItem?.time}
              hash={feedItem?.id}
              replies={feedItem?.replies}
              likes={feedItem?.likes}
              channel={feedItem?.channel}
              backgroundColor="#F4F4F4"
              line={true}
            />
          )
        }
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.listContent}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        style={styles.FlatList}
      />

      {isCommentVisible && (
        <BottomSheets
          isVisible={isCommentVisible}
          setVisible={setCommentVisible}
          onCastPress={ReplyPost}>
          <View style={styles.replyCard}>
            <ReplyCard
              imageSource={selectedFeedItem?.imageSource}
              name={selectedFeedItem?.name}
              userName={selectedFeedItem?.userName}
              replyTxt={selectedFeedItem?.reply}
              replyCount={selectedFeedItem?.replies}
              likesCount={selectedFeedItem?.likes}
            />
          </View>

          <View style={styles.commentContent}>
            {pfpUrl && (
              <Image source={{uri: pfpUrl}} style={styles.profileImage} />
            )}
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

export default Conversation;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    margin: 16,
  },
  listContent: {
    paddingBottom: 16,
  },
  separator: {
    height: 10,
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
  replyCard: {
    // marginTop: 16,
  },
  FlatList: {
    flexGrow: 1,
    // paddingHorizontal: 16,
    marginTop: 16,
  },
});
