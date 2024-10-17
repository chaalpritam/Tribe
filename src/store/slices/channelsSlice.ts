import {createSlice} from '@reduxjs/toolkit';

const channelsSlice = createSlice({
  name: 'channels',
  initialState: {
    channelList: [],
  },
  reducers: {
    setChannels: (state, actions) => {
      state.channelList = actions.payload;
    },
    clearChannels: state => {
      state.channelList = [];
    },
  },
});

export const {setChannels, clearChannels} = channelsSlice.actions;
export default channelsSlice.reducer;
