import {createSlice} from '@reduxjs/toolkit';

const profileSlice = createSlice({
  name: 'profile',
  initialState: {
    profileDetail: [],
  },
  reducers: {
    setProfile: (state, actions) => {
      state.profileDetail = actions.payload;
    },
    clearProfile: state => {
      state.profileDetail = [];
    },
  },
});

export const {setProfile, clearProfile} = profileSlice.actions;
export default profileSlice.reducer;
