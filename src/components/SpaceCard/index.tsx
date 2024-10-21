import {Image, StyleSheet, Text, View} from 'react-native';
import React, {PropsWithChildren} from 'react';

type Props = PropsWithChildren<{
  hostId: string;
  tokenGated?: string;
  spaceTitle: string;
  joiningImg?: any[];
  joinName?: string;
  joingCount?: string;
  eventDate?: string;
}>;

const SpaceCard = ({
  hostId,
  tokenGated,
  spaceTitle,
  joiningImg,
  joinName,
  joingCount,
  eventDate,
}: Props) => {
  return (
    <View style={styles.cardContainer}>
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.hostedByText}>
            hosted by <Text style={styles.hostId}>@{hostId}</Text>
          </Text>
          {tokenGated && (
            <View style={styles.tokenGatedContainer}>
              <Text style={styles.tokenGatedText}>{tokenGated}</Text>
            </View>
          )}
        </View>

        <Text style={styles.spaceTitle}>{spaceTitle}</Text>

        <View style={styles.joiningInfo}>
          <View style={styles.imageStack}>
            {joiningImg?.map((img, index) => (
              <Image
                key={index}
                source={img}
                style={[styles.joiningImg, {marginLeft: index !== 0 ? -10 : 0}]}
              />
            ))}
          </View>
          <Text style={styles.joiningText}>
            {joinName} & {joingCount} listening
          </Text>
        </View>
      </View>
    </View>
  );
};

export default SpaceCard;

const styles = StyleSheet.create({
  cardContainer: {
    padding: 10,
    borderRadius: 16,
    backgroundColor: '#fff',
  },
  imageStack: {
    flexDirection: 'row',
    marginRight: 5,
  },
  content: {
    margin: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  hostedByText: {
    fontSize: 14,
    color: '#666',
  },
  hostId: {
    fontWeight: '600',
    color: '#098BF880',
  },
  tokenGatedContainer: {
    backgroundColor: '#098BF8',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  tokenGatedText: {
    fontSize: 8,
    color: '#fff',
    textAlign: 'center',
  },
  spaceTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginVertical: 5,
    color: '#18171E',
  },
  joiningInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 10,
  },
  joiningImg: {
    width: 16,
    height: 16,
    borderRadius: 12.5,
    marginRight: 5,
  },
  joiningText: {
    fontSize: 14,
    color: '#666',
  },
});
