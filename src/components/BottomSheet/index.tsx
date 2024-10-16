import React, {PropsWithChildren, ReactNode, useEffect, useRef} from 'react';
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import BottomSheet, {BottomSheetScrollView} from '@gorhom/bottom-sheet';

type Props = PropsWithChildren<{
  children: ReactNode;
  isVisible: boolean;
  setVisible: (visible: boolean) => void;
  onCastPress?: () => void; // Optional prop for handling Cast button press
}>;

const BottomSheets = ({
  children,
  isVisible,
  setVisible,
  onCastPress,
}: Props) => {
  const bottomSheetRef = useRef<BottomSheet>(null);

  // Handle BottomSheet visibility
  useEffect(() => {
    if (isVisible) {
      bottomSheetRef.current?.snapToIndex(0); // Open the sheet when isVisible is true
    } else {
      bottomSheetRef.current?.close(); // Close the sheet when isVisible is false
    }
  }, [isVisible]);

  const handleCastPress = () => {
    if (onCastPress) {
      onCastPress(); // Call the provided onCastPress function
    }
    setVisible(false); // Close the bottom sheet
  };

  return (
    <BottomSheet
      ref={bottomSheetRef}
      index={isVisible ? 0 : -1}
      snapPoints={['100%']}
      backgroundStyle={styles.bg}
      style={styles.content}
      handleComponent={null}
      onClose={() => setVisible(false)}>
      <View style={styles.header}>
        <TouchableOpacity
          onPress={() => setVisible(false)}
          style={styles.button}>
          <Text style={styles.buttonText}>Cancel</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={handleCastPress} style={styles.button}>
          <Text style={styles.buttonText}>Cast</Text>
        </TouchableOpacity>
      </View>
      <BottomSheetScrollView style={styles.child}>
        {children}
      </BottomSheetScrollView>
    </BottomSheet>
  );
};

export default BottomSheets;

const styles = StyleSheet.create({
  bg: {
    backgroundColor: '#F4F4F4',
  },
  content: {
    // padding: 16,
  },
  child: {
    margin: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    margin: 16,
  },
  button: {
    // padding: 8,
  },
  buttonText: {
    fontSize: 16,
    color: '#202020',
    fontWeight: '600',
  },
});
