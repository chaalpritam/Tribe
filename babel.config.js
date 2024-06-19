module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    [
      'module-resolver',
      {
        root: ['./src'],
        extensions: ['.ios.js', '.android.js', '.js', '.ts', '.tsx', '.json'],
        alias: {
          '@components': './src/components/*',
          '@images': './src/images/*',
          '@navigation/*': './src/navigation/*',
          '@configs': './src/configs/index',
        },
      },
    ],
  ],
};
