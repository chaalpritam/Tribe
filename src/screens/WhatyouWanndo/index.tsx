import {SafeAreaView, StyleSheet, Text, FlatList, View} from 'react-native';
import React from 'react';
import {Colors} from 'configs';
import PostCard from 'components/PostCard';
import {PostData} from 'data';
import {useNavigation} from '@react-navigation/native';

const WhatyouWanndo = () => {
  const navigation = useNavigation();

  const ItemPress = item => {
    navigation.navigate('WhatyouWann', {
      title: item.title,
    });
  };

  const renderItem = ({item, index}) => (
    <PostCard
      title={item.title}
      image={item.image}
      onPress={index < 2 ? () => ItemPress(item) : null} // Only first two items are active
      isDisabled={index >= 2} // Pass a prop to disable later cards
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
  },
  listContent: {
    marginVertical: '10%',
  },
  columnWrapper: {
    justifyContent: 'space-between',
    marginBottom: 16, // bottom margin for the row
  },
  itemSeparator: {},
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
