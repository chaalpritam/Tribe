import {createSlice} from '@reduxjs/toolkit';

const initialState = {
  status: null, // Can be 'upToDate', 'updateInstalled', 'error'
};

export const updateCheckSlice = createSlice({
  name: 'codePush',
  initialState,
  reducers: {
    setUpdateStatus: (state, action) => {
      state.status = action.payload;
    },
    clearUpdateStatus: state => {
      state.status = null;
    },
  },
});

export const {setUpdateStatus, clearUpdateStatus} = updateCheckSlice.actions;
export default updateCheckSlice.reducer;
