import {SafeAreaView, StyleSheet, Text, View} from 'react-native';
import React from 'react';
import WaitingCount from 'components/WaitingCount';
import {IMAGE} from 'images';
import {Colors} from 'configs';
import PrimaryButton from 'components/Button/PrimaryButton';
import {useNavigation} from '@react-navigation/native';

const TribeWait = () => {
  const navigation = useNavigation();
  const handleNav = () => {
    navigation.navigate('TribeCount');
  };
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.heading}>After HSR opens, we’ll let you know</Text>
      <View style={styles.contentContainer}>
        <WaitingCount image={IMAGE.team} count="2,903" />
        <Text>of your neighbors have also joined</Text>
      </View>
      <Text style={styles.txt}>
        Share tribe with your neighbors to open HSR sooner
      </Text>
      <PrimaryButton
        title="Share Tribe"
        style={styles.btn}
        onPress={handleNav}
      />
    </SafeAreaView>
  );
};

export default TribeWait;

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
    bottom: 10,
    paddingHorizontal: '35%',
    alignSelf: 'center',
  },
  txt: {
    color: '#000',
    position: 'relative',
    bottom: '10%',
  },
});
