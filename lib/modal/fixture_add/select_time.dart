import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:provider/provider.dart';

class TimeSelector extends StatefulWidget {
  const TimeSelector({super.key});

  @override
  _TimeSelectorState createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  TimeOfDay selectedTime = TimeOfDay.now();

  /// Format the time as HH:mm
  String _formatTime(TimeOfDay time) {
    final String formattedHour =
        time.hour.toString().padLeft(2, '0'); // Ensure two digits for hours
    final String formattedMinute =
        time.minute.toString().padLeft(2, '0'); // Ensure two digits for minutes
    return '$formattedHour:$formattedMinute';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.av_timer_sharp),
          label: const Text("SELECT START TIME"),
          onPressed: () async {
            final TimeOfDay? timeOfDay = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              initialEntryMode: TimePickerEntryMode.dial,
            );
            if (timeOfDay != null) {
              setState(() {
                selectedTime = timeOfDay;
              });
            }
            final eventNotifier = Provider.of<MatchAdd>(context, listen: false);

            // Set the selected time details in the notifier
            eventNotifier.matchEventTime =
                _formatTime(selectedTime); // Update KO time
          },
        ),
        const Spacer(),
        Text(
          _formatTime(selectedTime), // Display formatted time
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
      ],
    );
  }
}
