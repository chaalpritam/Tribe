import {FlatList, SafeAreaView, StyleSheet, Text, View} from 'react-native';
import React, {useState} from 'react';
import {TopBar} from 'components/TopBar';
import {SecondaryButton} from 'components/SecondaryButton';
import {SpacesData} from 'data';
import SpaceCard from 'components/SpaceCard';
import {SpaceCardData} from 'data';

const Spaces = () => {
  const [selectedId, setSelectedId] = useState<number | null>(
    SpacesData.length > 0 ? SpacesData[0].id : null,
  );
  const [selectedTitle, setSelectedTitle] = useState<string>(
    SpacesData.length > 0 ? SpacesData[0].name : 'Photos',
  );

  const updateSelectedButton = (id: number, name: string) => {
    setSelectedId(id);
    setSelectedTitle(name);
  };
  return (
    <SafeAreaView style={styles.container}>
      <TopBar Title="Space" />
      <View style={styles.buttons}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={SpacesData}
          keyExtractor={item => item.id.toString()}
          renderItem={({item}) => (
            <SecondaryButton
              key={item.id}
              title={item.name}
              isActive={item.id === selectedId}
              onPress={() => updateSelectedButton(item.id, item.name)}
            />
          )}
        />
      </View>
      <FlatList
        data={SpaceCardData}
        keyExtractor={item => item.id.toString()}
        renderItem={({item}) => (
          <SpaceCard
            hostId={item.hostId}
            tokenGated={item.tokenGated}
            spaceTitle={item.spaceTitle}
            joiningImg={item.joinImg}
            joinName={item.joinName}
            joingCount={item.joingCount}
            eventDate={item.eventDate}
          />
        )}
        ItemSeparatorComponent={() => <View style={{height: 16}} />}
        style={styles.list}
      />
    </SafeAreaView>
  );
};

export default Spaces;

const styles = StyleSheet.create({
  container: {
    margin: 16,
  },
  buttons: {
    marginTop: 24,
  },
  list: {
    marginTop: 16,
  },
});
