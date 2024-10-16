import React from 'react';
import {View, StyleSheet} from 'react-native';
import ShimmerPlaceHolder from 'react-native-shimmer-placeholder';
import LinearGradient from 'react-native-linear-gradient';
// import {Colors} from 'configs';

const FeedLoader = () => {
  return (
    <View style={styles.card}>
      <View style={styles.cardContent}>
        <ShimmerPlaceHolder
          style={styles.doctorImage}
          LinearGradient={LinearGradient}
        />
      </View>
      <View style={styles.row}>
        <View style={styles.time}>
          <ShimmerPlaceHolder
            style={styles.dateTime}
            LinearGradient={LinearGradient}
          />
          <ShimmerPlaceHolder
            style={styles.dateTime}
            LinearGradient={LinearGradient}
          />
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    // marginHorizontal: 16,
    padding: 12,
    // borderColor: Colors.BlueGenie,
    // borderWidth: 0.5,
  },
  cardContent: {
    // flexDirection: 'row',
    // alignItems: 'center',
    // justifyContent: 'space-between',
  },

  dateTime: {
    width: '100%',
    height: 12,
    borderRadius: 4,
    marginTop: 4,
  },
  doctorImage: {
    width: '100%',
    height: 200,
    borderRadius: 8,
  },
  row: {
    marginTop: 8,
    borderRadius: 8,
    height: 36,
  },
  time: {},
});

export default FeedLoader;
