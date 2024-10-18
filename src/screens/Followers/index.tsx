import {Dimensions, SafeAreaView, StyleSheet, Text, View} from 'react-native';
import React, {PropsWithChildren, useState} from 'react';
import {TopBar} from 'components/TopBar';
import {IMAGE} from 'images';
import {TabView, SceneMap, Route, TabBar} from 'react-native-tab-view';
import Following from './Following';
import Follower from './Follower';
import Channels from './Channels';
import {useRoute} from '@react-navigation/native';

type Props = PropsWithChildren<{
  navigation: any;
}>;

type State = {index: number; routes: Route[]};

const Followers = ({navigation}: Props) => {
  const [index, setIndex] = useState<State['index']>(0);
  const [routes] = useState<State['routes']>([
    {key: 'first', title: 'Following'},
    {key: 'second', title: 'Followers'},
    {key: 'third', title: 'Channels'},
  ]);

  const route = useRoute();
  const {userId} = route.params || '';
  console.log(userId, '======');

  const renderScene = SceneMap({
    first: () => <Following userID={userId} />,
    second: () => <Follower userID={userId} />,
    third: () => <Channels userID={userId} />,
  });

  return (
    <SafeAreaView style={styles.continer}>
      <TopBar
        Title="Followers"
        Arrow={IMAGE.leftArrow}
        navBack={() => navigation.goBack()}
      />
      <View style={styles.tabViewContainer}>
        <TabView
          navigationState={{index, routes}}
          renderScene={renderScene}
          onIndexChange={setIndex}
          initialLayout={{width: Dimensions.get('window').width}}
          renderTabBar={props => (
            <TabBar
              {...props}
              style={styles.tabBar}
              pressColor="#F4F4F4"
              pressOpacity={0.1}
              renderLabel={({route, focused}) => (
                <Text
                  style={[
                    styles.label,
                    focused ? styles.activeLabel : styles.label,
                  ]}>
                  {route.title}
                </Text>
              )}
              indicatorStyle={styles.indicatorStyle}
            />
          )}
        />
      </View>
    </SafeAreaView>
  );
};

export default Followers;

const styles = StyleSheet.create({
  indicatorStyle: {
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderColor: '#2563EB',
  },
  continer: {
    flex: 1,
    margin: 16,
  },
  tabViewContainer: {
    flex: 1,
  },
  label: {
    color: '#686873',
    fontWeight: '600',
    fontSize: 14,
    bottom: 16,
    fontFamily: 'Quicksand',
  },
  activeLabel: {
    color: '#000000',
    fontWeight: '600',
    fontSize: 14,
    bottom: 16,
    fontFamily: 'Quicksand',
  },
  tabBar: {
    backgroundColor: '#F4F4F4',
    marginTop: 16,
    height: 36,
    elevation: 0,
    // borderBottomWidth: 1,
    borderColor: '#202020',
  },
  scene: {
    // flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    color: '#000',
  },
});
