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
  imageSource?: ImageProps;
  userName?: string;
  description?: string;
  following?: boolean;
  onFollowingChange?: () => void;
  viewingProfile?: boolean;
}>;

const FollowingCard = ({
  imageSource,
  userName,
  description,
  following,
  onFollowingChange,
  viewingProfile,
}: Props) => {
  return (
    <View style={styles.card}>
      <View
        style={viewingProfile ? styles.viewingProfileContent : styles.content}>
        <Image style={styles.img} source={{uri: imageSource}} />
        <View style={styles.nameContent}>
          <Text style={styles.name}>{userName}</Text>
          <Text style={styles.desc} numberOfLines={2}>
            {description}
          </Text>
        </View>
        {viewingProfile ? null : (
          <TouchableOpacity
            style={following ? styles.following : styles.follow}
            onPress={onFollowingChange}>
            <Text style={following ? styles.followingTxt : styles.followTxt}>
              {following ? 'UnFollow' : 'follow'}
            </Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
};

export default FollowingCard;

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
  viewingProfileContent: {
    flexDirection: 'row',
    // justifyContent: 'space-evenly',
    // alignItems: 'center',
    margin: 14, // When viewingProfile is true, disable space-between
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
