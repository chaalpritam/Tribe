import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TextInput,
  Image,
  Modal,
  TouchableOpacity,
} from 'react-native';
import {TopBar} from 'components/TopBar';
import type {PropsWithChildren} from 'react';
import {MintImg} from 'components/MintImg';
import {OptionButton} from 'components/Button/OptionButton';
import {ActivCard} from 'components/ActiveCard';
import PrimaryButton from 'components/Button/PrimaryButton';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import {PUBLIC_NEYNAR_API_KEY} from '@env';
// import {useDispatch} from 'react-redux';
// import {setCastStatus} from 'store/slices/castStatusSlice';
import {IMAGE} from 'images';
// import {useSelector} from 'react-redux';
// import {RootState} from 'store/store';
// import {FlatList, TouchableWithoutFeedback} from 'react-native-gesture-handler';

type Props = PropsWithChildren<{
  route: any;
  navigation: any;
}>;

function Mint({route, navigation}: Props): JSX.Element {
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const {image, rawImage} = route.params;
  const [title, setTitle] = useState('');
  const [modalVisible, setModalVisible] = useState(false); // Modal visibility state
  const [searchText, setSearchText] = useState(''); // Search input state
  // const dispatch = useDispatch();
  // const channels = useSelector(
  //   (state: RootState) => state.channels.channelList,
  // );
  // const updatedChannelsData = channels.slice(1);

  // const filteredChannels = updatedChannelsData.filter(({name}) =>
  //   name.toLowerCase().includes(searchText.toLowerCase()),
  // );
  // const Separator = () => {
  //   return <View style={styles.seprator} />;
  // };

  // const toggleSelection = (id: string) => {
  //   setSelectedIds(prevSelectedIds =>
  //     prevSelectedIds.includes(id)
  //       ? prevSelectedIds.filter(channelId => channelId !== id)
  //       : [...prevSelectedIds, id],
  //   );
  // };

  // console.log(selectedIds, 'ChannelId');

  const Cast = async () => {
    try {
      const signerUuid = await AsyncStorage.getItem('signerUuid');
      const channelId = await AsyncStorage.getItem('channelID');
      if (!signerUuid) {
        throw new Error('signerUuid is missing');
      }

      if (!image) {
        throw new Error('imageURL is missing');
      }

      const options = {
        method: 'POST',
        headers: {
          accept: 'application/json',
          api_key: PUBLIC_NEYNAR_API_KEY,
          'content-type': 'application/json',
        },
        data: {
          embeds: [
            {
              url: image,
            },
          ],
          text: title,
          channel_id: channelId,
          signer_uuid: signerUuid.trim(),
        },
      };

      const response = await axios.post(
        'https://api.neynar.com/v2/farcaster/cast',
        options.data,
        {headers: options.headers},
      );

      const castSuccess = response.data?.success;

      if (castSuccess) {
        // dispatch(setCastStatus(true));
        navigation.navigate('Home');
      } else {
        console.error('Failed to cast');
      }
    } catch (error: any) {
      if (error.response) {
        console.error('Response error:', error.response.data);
      } else {
        console.error('Error casting:', error.message);
      }
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.topnavbar}>
        <TopBar
          Arrow={IMAGE.leftArrow}
          Title="Cast Photo"
          navBack={() => navigation.goBack()}
        />
      </View>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.imageContainer}>
          <MintImg imageSource={{uri: rawImage.uri}} />
        </View>
        <TextInput
          style={styles.Inputtxt}
          placeholder="Description"
          placeholderTextColor="#8F8F8F"
          value={title}
          onChangeText={setTitle}
        />
        <View style={styles.line} />
        {/*
        <View style={styles.tag}>
          <View style={styles.channelTitle}>
            <Text style={styles.title}>Channels</Text>
            <TouchableOpacity
              onPress={() => setModalVisible(true)}
              style={styles.searchIcon}>
              <Image source={IMAGE.search} />
            </TouchableOpacity>
          </View>
          <View style={styles.buttons}>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              {updatedChannelsData.map(({id, name}) => (
                <OptionButton
                  key={id}
                  title={name}
                  isActive={selectedIds.includes(id)}
                  onPress={() => toggleSelection(id)}
                />
              ))}
            </ScrollView>
          </View>
          <View style={styles.line} />
        </View> */}
        <View style={styles.tag}>
          <Text style={styles.title}>Mint</Text>
          <View style={styles.cardContent}>
            <ActivCard content="Base" />
          </View>
          <View style={styles.cardContent}>
            <ActivCard content="Solana" />
          </View>
        </View>
        <View style={styles.btn}>
          <PrimaryButton title="Cast & Mint" onPress={Cast} />
        </View>
      </ScrollView>
      {/* <Modal visible={modalVisible} animationType="slide" transparent>
        <TouchableOpacity
          style={styles.modalContainer}
          activeOpacity={1}
          onPressOut={() => setModalVisible(false)}>
          <View>
            <View style={styles.modalContent}>
              <Text style={styles.channelTxt}>Choose Channels</Text>
              <TextInput
                style={styles.modalInput}
                placeholder="Search Channels"
                placeholderTextColor="#8F8F8F"
                value={searchText}
                onChangeText={setSearchText}
              />
              <FlatList
                data={searchText ? filteredChannels : []}
                keyExtractor={item => item.id.toString()}
                renderItem={({item}) => (
                  <OptionButton
                    title={item.name}
                    isActive={selectedIds.includes(item.id)}
                    onPress={() => toggleSelection(item.id)}
                    backgroundColor="#F4F4F4"
                  />
                )}
                ItemSeparatorComponent={Separator}
                numColumns={2}
              />
              <PrimaryButton
                title="Continue"
                onPress={() => setModalVisible(false)}
                style={styles.btnPrimary}
              />
            </View>
          </View>
        </TouchableOpacity>
      </Modal> */}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  btn: {
    marginHorizontal: 24,
    marginVertical: 24,
  },
  topnavbar: {
    marginHorizontal: 24,
    marginVertical: 24,
  },
  imageContainer: {
    marginHorizontal: 24,
  },
  Inputtxt: {
    marginHorizontal: 24,
    color: '#000',
  },
  line: {
    marginTop: 24,
    borderBottomWidth: 1,
    color: 'rgba(0, 0, 0, 0.1)',
    opacity: 0.2,
  },
  tag: {
    marginTop: 24,
  },
  title: {
    fontWeight: '700',
    fontSize: 16,
    color: '#000',
    marginLeft: 24,
  },
  channelTitle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  buttons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 16,
    marginLeft: 24,
  },
  cardContent: {
    marginHorizontal: 24,
    marginTop: 16,
  },
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    // alignItems: 'center',
  },
  modalContent: {
    // width: '80%',
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 24,
    marginHorizontal: 24,
  },
  modalInput: {
    marginVertical: 16,
    color: '#000',
    backgroundColor: '#F4F4F4',
    borderRadius: 16,
  },
  searchIcon: {
    marginHorizontal: 16,
  },
  seprator: {
    height: 16,
  },
  channelTxt: {
    textAlign: 'center',
    fontWeight: '700',
    fontSize: 16,
    color: '#000',
  },
  btnPrimary: {
    marginTop: 16,
  },
});

export default Mint;
