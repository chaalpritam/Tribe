import {StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import React, {PropsWithChildren} from 'react';
import {Colors} from 'configs';

type Props = PropsWithChildren<{
  questions: string;
}>;

const Card = ({questions}: Props) => {
  return (
    <View style={styles.card}>
      <View style={styles.txtContainer}>
        <Text style={styles.qtxt}>{questions}</Text>
      </View>
      <TouchableOpacity style={styles.btn}>
        <Text style={styles.text}>Answer</Text>
      </TouchableOpacity>
    </View>
  );
};

export default Card;

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#4C606A',
    borderRadius: 16,
  },
  btn: {
    backgroundColor: Colors.PrimaryColor,
    borderBottomEndRadius: 16,
    borderBottomStartRadius: 16,
  },
  text: {
    color: '#fff',
    textAlign: 'center',
    marginVertical: 16,
  },
  txtContainer: {
    padding: 24,
  },
  qtxt: {
    color: '#fff',
    fontFamily: 'Quicksand',
    fontWeight: '400',
    fontSize: 44,
    lineHeight: 55,
  },
});
