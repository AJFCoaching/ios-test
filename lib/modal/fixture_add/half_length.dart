import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class HalfLengthSelector extends StatefulWidget {
  final Function(int) onHalfLengthSelected; // Callback to pass selected value

  const HalfLengthSelector({
    required this.onHalfLengthSelected,
    super.key,
  });

  @override
  _HalfLengthSelectorState createState() => _HalfLengthSelectorState();
}

class _HalfLengthSelectorState extends State<HalfLengthSelector> {
  int matchHalfLength = 30; // Initial default value

  @override
  Widget build(BuildContext context) {
    final matchInfoProvider = Provider.of<MatchAdd>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center items
      children: [
        // Text Label
        const Text(
          'Select Half Length:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20), // Space between text and picker

        // Number Picker
        NumberPicker(
          value: matchHalfLength,
          minValue: 5,
          maxValue: 45,
          step: 5, // Adjust step if needed
          onChanged: (value) {
            setState(() {
              matchHalfLength = value;
            });
            // Call the callback to send the value back
            widget.onHalfLengthSelected(value);

            matchInfoProvider.matchHalfLength = value;
          },
        ),
      ],
    );
  }
}
