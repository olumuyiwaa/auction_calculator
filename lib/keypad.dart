import 'package:flutter/material.dart';

class Keypad extends StatelessWidget {
  final Function(String) addto;

  const Keypad({super.key, required this.addto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1', '2', '3'].map((e) => keypadButton(e)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['4', '5', '6'].map((e) => keypadButton(e)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['7', '8', '9'].map((e) => keypadButton(e)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['.', '0', '←'].map((e) => keypadButton(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget keypadButton(String digit) {
    return ElevatedButton(
      onPressed: () {
        addto(digit); // Pass the digit back to addToAmount
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: Color.fromARGB(255, 145, 112, 23),
            width: 2,
          ),
        ),
      ),
      child: SizedBox(
        width: 20,
        child: Text(
          digit,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center, // Center the text
        ),
      ),
    );
  }
}
