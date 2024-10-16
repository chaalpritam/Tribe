import {SafeAreaView, StyleSheet, Text, FlatList, View} from 'react-native';
import React from 'react';
import {Colors} from 'configs';
import PostCard from 'components/PostCard';
import {PostData} from 'data';
import {useNavigation} from '@react-navigation/native';

const WhatyouWanndo = () => {
  const navigation = useNavigation();
  const handleNav = () => {
    navigation.navigate('Profile');
  };

  const ItemPress = item => {
    navigation.navigate('WhatyouWann', {
      title: item.title,
    });
  };

  const renderItem = ({item}) => (
    <PostCard
      title={item.title}
      image={item.image}
      onPress={() => ItemPress(item)}
    />
  );

  const ItemSeparator = () => <View style={styles.itemSeparator} />;

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.heading}>What do you want to post?</Text>
      <FlatList
        data={PostData}
        renderItem={renderItem}
        keyExtractor={item => item.id.toString()}
        numColumns={2}
        contentContainerStyle={styles.listContent}
        ItemSeparatorComponent={ItemSeparator}
        columnWrapperStyle={styles.columnWrapper}
      />
    </SafeAreaView>
  );
};

export default WhatyouWanndo;

const styles = StyleSheet.create({
  text: {
    color: Colors.PrimaryColor,
    textAlign: 'center',
    textDecorationLine: 'underline',
    // marginVertical: 16,
  },
  listContent: {
    marginTop: '10%',
    // paddingBottom: 100, // to ensure button is not overlapped
  },
  columnWrapper: {
    justifyContent: 'space-between',
    // marginBottom: 16, // bottom margin for the row
  },
  itemSeparator: {
    // height: 8, // row gap
  },
  container: {
    flex: 1,
    margin: 16,
  },
  heading: {
    fontSize: 24,
    fontWeight: '600',
    textAlign: 'center',
    fontFamily: 'Quicksand',
    color: Colors.PrimaryColor,
  },
});
