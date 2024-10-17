// slices/selectChannelIdSlice.js
import {createSlice} from '@reduxjs/toolkit';

const selectChannelIdSlice = createSlice({
  name: 'selectedChannelId',
  initialState: null,
  reducers: {
    setSelectedChannelId: (state, action) => action.payload,
    clearSelectedChannelId: () => null,
  },
});

export const {setSelectedChannelId, clearSelectedChannelId} =
  selectChannelIdSlice.actions;
export default selectChannelIdSlice.reducer;
