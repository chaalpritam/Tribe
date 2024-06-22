import {Colors} from 'configs';
import React, {useState} from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
} from 'react-native';
import PrimaryButton from 'components/Button/PrimaryButton';

const neighborhoods = [
  'HSR',
  'Indira nagar',
  'Koramangala',
  'Madiwala',
  'Brookfield',
  'Electronic city',
  'Marathali',
];

const Neighbourhood = () => {
  const [selectedNeighborhood, setSelectedNeighborhood] = useState(null);

  const renderItem = ({item}) => (
    <TouchableOpacity
      style={[
        styles.item,
        selectedNeighborhood === item && styles.selectedItem,
      ]}
      onPress={() => setSelectedNeighborhood(item)}>
      <Text style={styles.itemText}>{item}</Text>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Select neighborhood</Text>
      <View style={styles.listContainer}>
        <FlatList
          data={neighborhoods}
          renderItem={renderItem}
          keyExtractor={item => item}
        />
      </View>
      <PrimaryButton title="Select Tribe" style={styles.btn} />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // padding: 20,
    margin: 16,
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
    paddingHorizontal: '35%',
    alignSelf: 'center',
  },
});

export default Neighbourhood;
