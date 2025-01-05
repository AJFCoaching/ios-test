import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:provider/provider.dart'; // Ensure this import is correct for MatchAdd provider.

class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime date = DateTime.now(); // Initialize date

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyy').format(date);
    String matchMonth = _getMonthName(date.month);
    return Row(
      children: [
        // Space
        const Spacer(),

        // Date button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () async {
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (newDate == null) return;

            setState(() {
              date = newDate;
              formattedDate = DateFormat('dd/MM/yyy').format(date);
              matchMonth = _getMonthName(date.month);
            });

            final eventNotifier = Provider.of<MatchAdd>(context, listen: false);

            // Set the selected date details in the notifier
            eventNotifier.matchDate = formattedDate; // Update Match Date
            eventNotifier.matchEventDate = date;
          },
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          label: const Text("SELECT DATE"),
        ),

        // Space
        const Spacer(),

        // Selected date display
        Text(
          formattedDate,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // Space
        const Spacer(),

        // Selected Month
        Text(
          matchMonth,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // Space
        const Spacer(),
      ],
    );
  }

  /// Helper function to get the month name from a number
  String _getMonthName(int monthNumber) {
    const monthsInYear = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthsInYear[monthNumber - 1];
  }
}
