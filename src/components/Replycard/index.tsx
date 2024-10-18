import React from 'react';
import {View, Image, StyleSheet, Text, TouchableOpacity} from 'react-native';
import type {PropsWithChildren} from 'react';
import {IMAGE} from 'images';
import {wp} from 'utils/ScreenDimensions';

type Props = PropsWithChildren<{
  imageSource?: string;
  name?: String;
  userName?: String;
  replyTxt?: String;
  replyCount?: String;
  likesCount?: String;
  commentPress?: () => void;
}>;

const ReplyCard = ({
  imageSource,
  name,
  userName,
  replyTxt,
  replyCount,
  likesCount,
  commentPress,
}: Props) => {
  return (
    <View style={styles.card}>
      <View style={styles.content}>
        <Image style={styles.img} source={{uri: imageSource}} />
        <View style={styles.replyContent}>
          <View style={styles.namecontent}>
            <Text style={styles.name}>{name}</Text>
            <Text style={styles.userName}>@{userName}</Text>
          </View>
          <Text style={styles.replyTxt}>{replyTxt}</Text>
          <View style={styles.icons}>
            <View style={styles.iconsright}>
              <TouchableOpacity>
                <Image source={IMAGE.like} style={styles.icon} />
              </TouchableOpacity>
              <TouchableOpacity>
                <Image source={IMAGE.repost} style={[styles.shareIcon]} />
              </TouchableOpacity>
              <TouchableOpacity onPress={commentPress}>
                <Image source={IMAGE.comment} style={[styles.shareIcon]} />
              </TouchableOpacity>
            </View>
            {/* <View>
              <Image source={IMAGE.save} style={styles.icon} />
            </View> */}
          </View>
          <View style={styles.iconsright}>
            <Text style={styles.reply}>
              {replyCount}
              <Text style={styles.spacing}> </Text>
              <Text style={styles.replyTxt}>replies</Text>
            </Text>
            <Text style={styles.like}>
              {likesCount}
              <Text style={styles.spacing}> </Text>
              <Text style={styles.likeTxt}>likes</Text>
            </Text>
          </View>
        </View>
      </View>
      <View style={styles.line} />
    </View>
  );
};

export default ReplyCard;

const styles = StyleSheet.create({
  content: {
    flexDirection: 'row',
    margin: 8,
  },
  card: {
    // backgroundColor: 'red',
    // borderBottomWidth: 0.25,
    // borderBottomColor: '#4A4A4A',
  },
  namecontent: {
    flexDirection: 'row',
  },
  name: {
    color: '#202020',
    fontSize: 12,
    fontWeight: '500',
  },
  userName: {
    color: '#202020',
    fontSize: 12,
    fontWeight: '400',
    opacity: 0.5,
    marginHorizontal: 8,
  },
  replyTxt: {
    color: '#202020',
    fontSize: 12,
  },
  img: {
    width: 32,
    height: 32,
    borderRadius: 50,
  },
  replyContent: {
    marginHorizontal: 8,
  },
  line: {
    width: wp(87),
    borderBottomWidth: wp(0.1),
    marginHorizontal: 16,
    borderBottomColor: '#4A4A4A',
    marginTop: 4,
  },
  icons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
  },
  iconsright: {
    flexDirection: 'row',
    // justifyContent: 'space-between',
    // backgroundColor: 'red',
  },
  icon: {
    // tintColor: '#000',
    marginHorizontal: 8,
    marginVertical: 4,
  },
  shareIcon: {
    marginHorizontal: 16,
    marginTop: 4,
  },
  reply: {
    color: '#000',
    fontWeight: '600',
    fontSize: 14,
    // lineHeight: 20,
  },
  replyTxt: {
    color: '#000',
    fontWeight: '400',
    fontSize: 14,
  },
  like: {
    color: '#000',
    fontWeight: '600',
    fontSize: 14,
    marginHorizontal: 8,
  },
  likeTxt: {
    color: '#000',
    fontWeight: '400',
    fontSize: 14,
  },
  spacing: {
    marginRight: 8,
  },
});
