import 'package:flutter/material.dart';

class ConversionDropdown extends StatefulWidget {
  final Function(String) updateCalculations;
  final List<DropdownMenuItem<String>> dropdownlist;
  final String dropdownvalue;

  const ConversionDropdown({
    super.key,
    required this.updateCalculations,
    required this.dropdownlist,
    required this.dropdownvalue,
  });

  @override
  State<ConversionDropdown> createState() => _ConversionDropdownState();
}

class _ConversionDropdownState extends State<ConversionDropdown> {
  late String currentDropdownValue;

  @override
  void initState() {
    super.initState();
    currentDropdownValue = widget.dropdownvalue; // Initialize with parent value
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      value: currentDropdownValue,
      items: widget.dropdownlist,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            currentDropdownValue = newValue; // Update local value
          });
          widget.updateCalculations(newValue); // Call parent callback
        }
      },
    );
  }
}
