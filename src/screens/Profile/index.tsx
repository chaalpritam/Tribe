import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
  Image,
  ScrollView,
} from 'react-native';
import {TabView, SceneMap, TabBar} from 'react-native-tab-view';
import {Colors} from 'configs'; // Ensure you have your Colors configured
import {IMAGE} from 'images';

const Profile = () => {
  const [index, setIndex] = React.useState(0);
  const [routes] = React.useState([
    {key: 'saved', title: 'Saved'},
    {key: 'posted', title: 'Posted'},
    {key: 'replied', title: 'Replied'},
    {key: 'liked', title: 'Liked'},
  ]);

  const renderScene = SceneMap({
    saved: () => (
      <View style={styles.emptyTab}>
        <Text style={styles.emptyText}>Nothing to show here</Text>
      </View>
    ),
    posted: () => <View style={styles.emptyTab} />,
    replied: () => <View style={styles.emptyTab} />,
    liked: () => <View style={styles.emptyTab} />,
  });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollView}>
        <View style={styles.header}>
          <Image source={IMAGE.Bannerimg} style={styles.headerImage} />
        </View>
        <View style={styles.img}>
          <Image
            source={IMAGE.ProfileImg} // Replace with your avatar image path
            style={styles.avatar}
          />
        </View>
        <View style={styles.profileContainer}>
          <Text style={styles.name}>Sathish Kumar</Text>
          <Text style={styles.subText}>HSR - Joined June 2024</Text>
        </View>
        <TabView
          navigationState={{index, routes}}
          renderScene={renderScene}
          onIndexChange={setIndex}
          initialLayout={{width: styles.tabView.width}}
          renderTabBar={props => (
            <TabBar
              {...props}
              indicatorStyle={styles.tabIndicator}
              style={styles.tabBar}
              labelStyle={styles.tabLabel}
            />
          )}
        />
      </ScrollView>
    </SafeAreaView>
  );
};

export default Profile;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollView: {
    flexGrow: 1,
  },
  header: {
    height: 200,
    // backgroundColor: Colors.PrimaryColor,
  },
  headerImage: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  profileContainer: {
    alignItems: 'center',
    // marginTop: -50, // Adjust based on your header height
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 2,
    borderColor: '#fff',
  },
  name: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 10,
  },
  subText: {
    color: 'gray',
    marginBottom: 20,
  },
  tabView: {
    width: '100%',
  },
  tabBar: {
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#ddd',
  },
  tabLabel: {
    color: '#000',
    fontWeight: 'bold',
  },
  tabIndicator: {
    backgroundColor: Colors.PrimaryColor,
  },
  emptyTab: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 20,
  },
  emptyText: {
    color: 'gray',
  },
  img: {
    position: 'relative',
    alignSelf: 'center',
    // marginTop: '40%',
    // bottom: 30,
  },
});
