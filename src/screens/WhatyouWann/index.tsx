import {
  SafeAreaView,
  StyleSheet,
  Text,
  FlatList,
  View,
  Image,
  TouchableOpacity,
} from 'react-native';
import React from 'react';
import Card from 'components/Card';
import PrimaryButton from 'components/Button/PrimaryButton';
import ProfileButton from 'components/ProfileButton';
import {IMAGE} from 'images';

const WhatyouWann = ({route}) => {
  const {title} = route.params || {};

  const renderItem = ({item}) => <Card questions={item.questions} />;

  const data = [
    {
      id: 1,
      questions:
        'Can you recommend which is the best Broadband connection in HSR?',
    },
    {
      id: 2,
      questions:
        'Can you recommend which is the best Broadband connection in HSR?',
    },
  ];

  const ItemSeparator = () => <View style={styles.itemSeparator} />;

  return (
    <SafeAreaView style={styles.container}>
      {/* <Text>{title}</Text> */}
      <View style={styles.btns}>
        <ProfileButton name="Sathish kumar" Wallet="0x2666473628478762" />
        <TouchableOpacity style={styles.menu}>
          <Image source={IMAGE.Menu} />
        </TouchableOpacity>
      </View>
      <Text style={styles.txt}>3 new answers</Text>
      <FlatList
        data={data}
        showsVerticalScrollIndicator={false}
        renderItem={renderItem}
        keyExtractor={item => item.id.toString()}
        numColumns={1}
        ItemSeparatorComponent={ItemSeparator}
      />
      <PrimaryButton
        title="Ask a Question"
        style={styles.btn}
        // onPress={handleNav}
      />
    </SafeAreaView>
  );
};

export default WhatyouWann;

const styles = StyleSheet.create({
  txt: {
    marginVertical: 24,
    textAlign: 'center',
    textDecorationLine: 'underline',
    fontWeight: '400',
    fontSize: 24,
    fontFamily: 'Quicksand',
  },
  container: {
    flex: 1,
    margin: 16,
  },
  itemSeparator: {
    height: 16,
  },
  btn: {
    // position: 'absolute',
    bottom: 8,
    top: 8,
    paddingHorizontal: '30%',
    alignSelf: 'center',
  },
  btns: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  menu: {
    backgroundColor: '#4C606A1A',
    borderRadius: 50,
    padding: 12,
  },
});
