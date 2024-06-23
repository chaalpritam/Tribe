import {SafeAreaView, StyleSheet, Text, View} from 'react-native';
import React from 'react';
import WaitingCount from 'components/WaitingCount';
import {IMAGE} from 'images';
import {Colors} from 'configs';
import PrimaryButton from 'components/Button/PrimaryButton';
import {useNavigation} from '@react-navigation/native';

const TribeCount = () => {
  const navigation = useNavigation();
  const handleNav = () => {
    navigation.navigate('WhatyouWanndo');
  };
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.heading}>You’re ready to join HSR</Text>
      <View style={styles.contentContainer}>
        <WaitingCount image={IMAGE.diversity} count="3,000" />
        <Text>neighbors are there in your locality</Text>
      </View>
      <PrimaryButton title="Join HSR" style={styles.btn} onPress={handleNav} />
      <Text style={styles.text}>Change neighborhood</Text>
    </SafeAreaView>
  );
};

export default TribeCount;

const styles = StyleSheet.create({
  contentContainer: {
    flex: 1,
    justifyContent: 'center',
    alignContent: 'center',
    alignItems: 'center',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignContent: 'center',
    alignItems: 'center',
    margin: 16,
  },
  heading: {
    fontSize: 24,
    marginVertical: 20,
    fontWeight: '600',
    textAlign: 'center',
    fontFamily: 'Quicksand',
    color: Colors.PrimaryColor,
    width: '65%',
  },
  btn: {
    position: 'absolute',
    bottom: 30,
    paddingHorizontal: '35%',
    alignSelf: 'center',
  },
  text: {
    color: Colors.PrimaryColor,
    textAlign: 'center',
    textDecorationLine: 'underline',
    // marginVertical: 16,
  },
});
