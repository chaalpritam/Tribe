import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Image,
  ImageProps,
} from 'react-native';
import React, {PropsWithChildren} from 'react';

type Props = PropsWithChildren<{
  imageSource: ImageProps;
  userName: string;
  description: string;
  following?: boolean;
  onFollowingChange?: () => void;
}>;

const UserChannelCard = ({
  imageSource,
  userName,
  description,
  following,
  onFollowingChange,
}: Props) => {
  return (
    <View style={styles.card}>
      <View style={styles.content}>
        <Image style={styles.img} source={{uri: imageSource}} />
        <View style={styles.nameContent}>
          <Text style={styles.name}>{userName}</Text>
          <Text style={styles.desc} numberOfLines={2}>
            {description}
          </Text>
        </View>
        <TouchableOpacity
          style={following ? styles.following : styles.follow}
          onPress={onFollowingChange}>
          <Text style={following ? styles.followingTxt : styles.followTxt}>
            {following ? 'following' : 'follow'}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default UserChannelCard;

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#FFFF',
    borderRadius: 16,
  },
  content: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    margin: 14,
  },
  img: {
    width: 40,
    height: 40,
    borderRadius: 50,
  },
  name: {
    fontWeight: '600',
    color: '#000',
    fontSize: 14,
  },
  desc: {
    // fontWeight: '600',
    color: '#8C8C8C',
    fontSize: 12,
  },
  follow: {
    backgroundColor: '#098BF8',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 4,
  },
  following: {
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#202020',
    paddingHorizontal: 16,
    paddingVertical: 4,
  },
  followingTxt: {
    color: '#202020',
    fontSize: 12,
  },
  followTxt: {
    color: '#FFF',
    fontSize: 12,
  },
  nameContent: {
    marginHorizontal: 8,
    width: '50%',
  },
});
