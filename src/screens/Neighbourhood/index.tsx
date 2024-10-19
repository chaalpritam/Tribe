import {Colors} from 'configs';
import React, {useState} from 'react';
import {FlatList, StyleSheet, SafeAreaView, View} from 'react-native';
import PrimaryButton from 'components/Button/PrimaryButton';
import {useNavigation} from '@react-navigation/native';
import {neighborhoods} from 'data';
import TribeCard from 'components/TribeCard';

const Neighbourhood = () => {
  const [selectedNeighborhood, setSelectedNeighborhood] = useState(null);
  const navigation = useNavigation();

  const handleNav = () => {
    navigation.navigate('TribeCount', {tribeId: selectedNeighborhood});
  };

  const handleSelectNeighborhood = id => {
    setSelectedNeighborhood(id);
    console.log(`Selected Neighborhood ID: ${id}`);
  };

  const renderItem = ({item}) => (
    <TribeCard
      image={item.img}
      title={item.name}
      onPress={() => handleSelectNeighborhood(item.id)}
      isSelected={item.id === selectedNeighborhood}
    />
  );
  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        numColumns={2}
        data={neighborhoods}
        renderItem={renderItem}
        keyExtractor={item => item.id.toString()}
        ItemSeparatorComponent={() => <View style={{height: 16}} />}
        columnWrapperStyle={styles.flatlistWrapper}
        showsVerticalScrollIndicator={false}
      />

      <PrimaryButton
        title={
          selectedNeighborhood
            ? `Explore ${selectedNeighborhood}`
            : 'Choose the Tribe'
        }
        style={styles.btn}
        onPress={handleNav}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    margin: 24,
  },
  title: {
    fontSize: 24,
    marginVertical: 20,
    fontWeight: '600',
    textAlign: 'center',
    fontFamily: 'Quicksand',
    color: Colors.PrimaryColor,
  },
  listContainer: {
    width: '100%',
    borderWidth: 1,
    borderRadius: 16,
    overflow: 'hidden',
    marginTop: '10%',
  },
  item: {
    padding: 20,
    borderBottomWidth: 1,
    borderColor: Colors.PrimaryColor,
  },
  itemText: {
    fontSize: 24,
    fontWeight: '600',
    fontFamily: 'Quicksand',
    color: Colors.PrimaryColor,
  },
  selectedItem: {
    backgroundColor: '#f0f0f0',
  },
  btn: {
    position: 'absolute',
    bottom: 30,
    paddingHorizontal: '30%',
    alignSelf: 'center',
  },
  flatlistWrapper: {
    justifyContent: 'space-between',
  },
});

export default Neighbourhood;
