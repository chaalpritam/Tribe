import {StyleSheet, Text, View, SafeAreaView, ScrollView} from 'react-native';
import React, {useState} from 'react';
import {TopBar} from 'components/TopBar';
import {ExploreData} from 'data';
import {SecondaryButton} from 'components/SecondaryButton';

const Explore = () => {
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const updateSelectedButton = (id: number, name: string) => {
    setSelectedId(id);
  };
  return (
    <SafeAreaView style={styles.container}>
      <TopBar Title="Photos" />
      <View style={styles.buttons}>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{rowGap: 8}}>
          {ExploreData.map(({id, name}) => (
            <SecondaryButton
              key={id}
              title={name}
              isActive={id === selectedId}
              onPress={() => updateSelectedButton(id, name)}
            />
          ))}
        </ScrollView>
      </View>
    </SafeAreaView>
  );
};

export default Explore;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    margin: 16,
  },
});
