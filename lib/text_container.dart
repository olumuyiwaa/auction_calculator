import 'package:flutter/material.dart';

class Myoutputfield extends StatelessWidget {
  final String display;
  const Myoutputfield({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: display,
          hintStyle: const TextStyle(color: Colors.black87),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 145, 112, 23), width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
