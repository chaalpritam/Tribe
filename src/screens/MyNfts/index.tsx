import React from 'react';
import {SafeAreaView, StyleSheet, View, FlatList, Text} from 'react-native';
import {TopBar} from 'components/TopBar'; // Ensure that this is correctly imported
import {IMAGE} from 'images'; // Ensure IMAGE is correctly imported and defined
import NftsCard from 'components/NftsCard';

type Props = {
  navigation: any;
};

const MyNfts = ({navigation}: Props) => {
  const data = [
    {id: '1', imageSource: IMAGE.plainImg},
    {id: '2', imageSource: IMAGE.plainImg},
    {id: '3', imageSource: IMAGE.plainImg},
    {id: '4', imageSource: IMAGE.plainImg},
    {id: '5', imageSource: IMAGE.plainImg},
    {id: '6', imageSource: IMAGE.plainImg},
    {id: '7', imageSource: IMAGE.plainImg},
    {id: '8', imageSource: IMAGE.plainImg},
    {id: '9', imageSource: IMAGE.plainImg},
    {id: '10', imageSource: IMAGE.plainImg},
  ];

  const renderSeparator = () => {
    return <View style={styles.separator} />;
  };

  return (
    <SafeAreaView style={styles.container}>
      <TopBar
        Title="NFTs"
        Arrow={IMAGE.leftArrow}
        navBack={() => navigation.goBack()}
      />
      {/* <View style={styles.listContainer}>
        <FlatList
          data={data}
          renderItem={({item}) => <NftsCard imageSource={item.imageSource} />}
          keyExtractor={item => item.id}
          numColumns={2}
          ItemSeparatorComponent={renderSeparator}
          showsVerticalScrollIndicator={false}
        />
      </View> */}
      <View style={styles.waringContent}>
        <Text style={styles.waringTxt}>
          We don’t have any filter cast to show
        </Text>
      </View>
    </SafeAreaView>
  );
};

export default MyNfts;

const styles = StyleSheet.create({
  waringContent: {
    flex: 1,
    justifyContent: 'center',
  },
  waringTxt: {
    color: '#000',
    textAlign: 'center',
  },
  container: {
    flex: 1,
    margin: 16,
  },
  listContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    backgroundColor: '#fff',
    borderTopStartRadius: 16,
    borderTopEndRadius: 16,
    padding: 3,
    marginTop: 24,
  },
  separator: {
    height: 2,
  },
});
