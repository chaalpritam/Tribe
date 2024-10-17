import {createSlice, PayloadAction} from '@reduxjs/toolkit';

interface AuthState {
  fid: number | null;
  signerUuid: string | null;
}

const initialState: AuthState = {
  fid: null,
  signerUuid: null,
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setAuthData: (state, action: PayloadAction<AuthState>) => {
      state.fid = action.payload.fid;
      state.signerUuid = action.payload.signerUuid;
    },
    clearAuthData: state => {
      state.fid = null;
      state.signerUuid = null;
    },
  },
});

export const {setAuthData, clearAuthData} = authSlice.actions;

export default authSlice.reducer;
