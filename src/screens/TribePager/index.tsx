import React, {memo, useEffect, useRef, useState} from 'react';
import {
  View,
  StyleSheet,
  TouchableOpacity,
  Animated,
  BackHandler,
  Text,
  Platform,
  Image,
} from 'react-native';
import SplashScreen from 'react-native-splash-screen';
import PagerView from 'react-native-pager-view';
import {useNavigation} from '@react-navigation/native';
import {SafeAreaView} from 'react-native-safe-area-context';
import OnboardPage from 'components/OnBoard';
import {ONBOARD} from 'data';
import {Colors} from 'configs';
import {IMAGE} from 'images';

interface OnBoardProps {}

const TribePager = memo((_props: OnBoardProps) => {
  const pagerRef = useRef(null);
  const [currentPage, setCurrentPage] = useState(0);
  const buttonAnimation = useRef(new Animated.Value(0)).current;
  const {navigate} = useNavigation();

  useEffect(() => {
    const hideSplashScreen = () => {
      SplashScreen.hide();
    };

    const timeoutId = setTimeout(hideSplashScreen, 1000);

    return () => clearTimeout(timeoutId);
  }, []);

  const totalPages = ONBOARD.length;

  const setPage = (index: number) => {
    if (pagerRef.current) {
      pagerRef.current.setPage(index);
    }
  };

  const handlePageChange = (event: any) => {
    const {position} = event.nativeEvent;
    const pageIndex = Math.round(position);
    setCurrentPage(pageIndex);
    animateButtons();
  };

  useEffect(() => {
    const backAction = () => {
      BackHandler.exitApp();
      return true;
    };
    BackHandler.addEventListener('hardwareBackPress', backAction);

    return () =>
      BackHandler.removeEventListener('hardwareBackPress', backAction);
  }, []);

  const animateButtons = () => {
    Animated.timing(buttonAnimation, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start();
  };

  const RenderButtons = ({pages}: {pages: number}) => {
    const buttons = [];

    for (let i = 0; i < pages; i++) {
      const buttonOpacity = buttonAnimation.interpolate({
        inputRange: [i - 1, i, i + 1],
        outputRange: [0.5, 0.5, 0.5],
        extrapolate: 'clamp',
      });

      buttons.push(
        <Animated.View
          key={i.toString()}
          style={[
            styles.buttonContainer,
            {
              opacity: buttonOpacity,
            },
          ]}>
          <TouchableOpacity
            onPress={() => setPage(i)}
            style={[styles.button, i === currentPage && styles.activeButton]}
          />
        </Animated.View>,
      );
    }

    return <View style={styles.buttonGroup}>{buttons}</View>;
  };

  return (
    <SafeAreaView style={styles.container}>
      <PagerView
        style={styles.pagerView}
        initialPage={0}
        ref={pagerRef}
        onPageScroll={handlePageChange}
        scrollEnabled={false} // Disable swipe gestures
        useNext={false}>
        {ONBOARD.map((item, index) => (
          <View key={item.id.toString()}>
            <OnboardPage
              imageSource={item.image}
              {...item}
              isFirstItem={index === 0}
              isLastItem={index === ONBOARD.length - 1}
            />
          </View>
        ))}
      </PagerView>
      <View
        style={{
          justifyContent: 'space-between',
          flexDirection: 'row',
          //   backgroundColor: 'red',
        }}>
        <RenderButtons pages={totalPages} />
        <TouchableOpacity
          style={styles.arrowButton}
          onPress={() => setPage(currentPage + 1)}
          disabled={currentPage === totalPages - 1}>
          <Image source={IMAGE.ArrowRight} />
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
});

export default TribePager;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    // alignItems: 'center',
    marginHorizontal: 16,
  },
  pagerView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonGroup: {
    flexDirection: 'row',
    justifyContent: 'center',
    paddingBottom: 20,
    // backgroundColor: 'green',
  },
  buttonContainer: {
    marginHorizontal: 5,
  },
  button: {
    width: 8,
    height: 4,
    borderRadius: 5,
    backgroundColor: '#4F4F4F',
  },
  activeButton: {
    backgroundColor: Colors.PrimaryColor,
    width: 15,
    height: 4,
  },
  arrowButton: {
    // position: 'absolute',
    bottom: 30,
    right: 30,
    width: 60,
    height: 60,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 30,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.8,
        shadowRadius: 2,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  arrowText: {
    fontSize: 24,
    color: Colors.PrimaryColor,
  },
});
