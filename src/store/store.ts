// store.js
import {configureStore} from '@reduxjs/toolkit';
import castStatusReducer from './slices/castStatusSlice';
import authReducer from './slices/authSlice';
import selectedChannelIdReducer from './slices/selectChannelIdSlice';
import channelsReducer from './slices/channelsSlice';
import profileReducer from './slices/profilrSlice';
import updateReducer from './slices/updateCheckSlice';

export const store = configureStore({
  reducer: {
    castStatus: castStatusReducer,
    auth: authReducer,
    selectedChannelId: selectedChannelIdReducer,
    channels: channelsReducer,
    profile: profileReducer,
    update: updateReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
