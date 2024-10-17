/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {StatusBar, useColorScheme} from 'react-native';
import {Colors} from 'react-native/Libraries/NewAppScreen';
import Nav from 'navigation/Nav';
import {DefaultTheme, NavigationContainer} from '@react-navigation/native';

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };
  const MyTheme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      background: '#F4F4F4',
    },
  };

  return (
    <React.Fragment>
      <StatusBar />
      <NavigationContainer theme={MyTheme}>
        <Nav />
      </NavigationContainer>
    </React.Fragment>
  );
}

export default App;
