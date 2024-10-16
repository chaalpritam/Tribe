import React from 'react';
import {View, StyleSheet} from 'react-native';
import ShimmerPlaceHolder from 'react-native-shimmer-placeholder';
import LinearGradient from 'react-native-linear-gradient';
// import {Colors} from 'configs';

const UserLoader = () => {
  return (
    <View style={styles.card}>
      <ShimmerPlaceHolder
        style={styles.doctorImage}
        LinearGradient={LinearGradient}
      />
      <View style={styles.row}>
        <ShimmerPlaceHolder
          style={styles.dateTime}
          LinearGradient={LinearGradient}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 12,
  },

  dateTime: {
    width: 50,
    height: 12,
    borderRadius: 4,
    marginTop: 4,
  },
  doctorImage: {
    width: 96,
    height: 96,
    borderRadius: 8,
  },
  row: {
    marginTop: 8,
    borderRadius: 8,
    height: 36,
  },
});

export default UserLoader;
