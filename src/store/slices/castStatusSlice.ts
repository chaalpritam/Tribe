// slices/castStatusSlice.js
import {createSlice} from '@reduxjs/toolkit';

const castStatusSlice = createSlice({
  name: 'castStatus',
  initialState: null,
  reducers: {
    setCastStatus: (state, action) => action.payload,
    resetCastStatus: () => null,
  },
});

export const {setCastStatus, resetCastStatus} = castStatusSlice.actions;
export default castStatusSlice.reducer;
