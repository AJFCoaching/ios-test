// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchday/pages/coach/select_address.dart';
import 'package:matchday/supabase/notifier/save_event.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class AddEventModel extends StatefulWidget {
  const AddEventModel({super.key});

  @override
  _AddEventModelState createState() => _AddEventModelState();
}

class _AddEventModelState extends State<AddEventModel> {
  late final EventNotifier _eventNotifier;

  @override
  void initState() {
    super.initState();
    _eventNotifier = Provider.of<EventNotifier>(context, listen: false);
  }

  DateTime date = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            currentSeason(),
            const SizedBox(height: 20),
            getAddressButton(),
            const SizedBox(height: 16),
            Text(_eventNotifier.address), // Use notifier's address
            const SizedBox(height: 20),
            dropdownEventType(), // Event type dropdown
            const SizedBox(height: 35),
            rowOneDate(), // Date picker
            const SizedBox(height: 25),
            rowTwoTime(), // Time picker
            const SizedBox(height: 20),
            oppNameField(), // Opposition name field
            const SizedBox(height: 35),
            rowThreeHalfLength(), // Match half length picker
            const SizedBox(height: 35),
            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget currentSeason() {
    return Row(
      children: [
        const Spacer(),
        Text(
          _eventNotifier.currentSeasonDate,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
      ],
    );
  }

  Widget getAddressButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, foregroundColor: Colors.white),
      child: const Text("Get Address"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const SelectAddress()),
        );
      },
    );
  }

  Widget dropdownEventType() {
    return DropdownButton<String>(
      value: _eventNotifier.selectedEventType,
      items: <String>['Training', 'Friendly', 'League', 'Cup']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _eventNotifier.selectedEventType = newValue; // Use notifier's setter
        }
      },
    );
  }

  Widget rowOneDate() {
    return Row(
      children: [
        const Spacer(),
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
            if (newDate != null) {
              setState(() {
                date = newDate;

                // Format the date as dd/mm/yyyy
                String formattedDate = DateFormat('dd/MM/yyyy').format(date);

                // Set the formatted string in _eventNotifier
                _eventNotifier.matchDate = formattedDate;
                _eventNotifier.selectedDate = date;
              });
            }
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text("SELECT DATE"),
        ),
        const Spacer(),
        Text(
          "${date.day}/${date.month}/${date.year}", // This shows selected date on screen
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
      ],
    );
  }

  Widget rowTwoTime() {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
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
                _eventNotifier.matchEventTime =
                    "${selectedTime.hour}:${selectedTime.minute}"; // Use notifier's setter
              });
            }
          },
        ),
        const Spacer(),
        Text(
          "${selectedTime.hour}:${selectedTime.minute}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
      ],
    );
  }

  Widget oppNameField() {
    return TextFormField(
      onChanged: (value) {
        _eventNotifier.oppositionName = value; // Use notifier's setter
      },
      decoration: const InputDecoration(labelText: 'Opposition Name'),
    );
  }

  Widget rowThreeHalfLength() {
    return Row(
      children: [
        const Spacer(),
        const Text('SELECT HALF LENGTH'),
        const Spacer(),
        NumberPicker(
          value: _eventNotifier.currentTimeValue,
          minValue: 5,
          maxValue: 45,
          onChanged: (value) =>
              _eventNotifier.currentTimeValue = value, // Use notifier's setter
        ),
        const Spacer(),
      ],
    );
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: () {
        // Combine the selected date and time into a DateTime object
        DateTime onlyDateTimeString = DateTime(
          _eventNotifier.selectedDate.year,
          _eventNotifier.selectedDate.month,
          _eventNotifier.selectedDate.day,
          selectedTime.hour, // Use hour from TimeOfDay
          selectedTime.minute, // Use minute from TimeOfDay
        );

        // Print the matchDate for debugging
        print('Selected Date: ${_eventNotifier.matchDate}');
        print(
            'Combined DateTime: $onlyDateTimeString'); // Full DateTime with time

        // Call the function to save the event, passing the DateTime object
        saveEventDataToSupabase(context,
            onlyDateTimeString.toIso8601String()); // Convert to ISO string
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text(
        'Save Event',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> saveEventDataToSupabase(
      BuildContext context, String onlyDateTimeString) async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    try {
      // Call saveEventToSupabase with the DateTime object (no conversion to string here)
      await _eventNotifier.saveEventToSupabase(
        teamCode: userInfo.teamCode,
        matchType: _eventNotifier.selectedEventType,
        matchDate: _eventNotifier.matchDate, // Pass DateTime object here
        eventDate: onlyDateTimeString,
        oppTeam: _eventNotifier.oppositionName,
        address: _eventNotifier.address,
        addressLat: _eventNotifier.addressLat,
        addressLong: _eventNotifier.addressLong,
        matchEventTime: _eventNotifier.matchEventTime,
        matchHalfLength: _eventNotifier.currentTimeValue,
        eventTraining: _eventNotifier.eventTraining,
        season: _eventNotifier.currentSeasonDate,
      );

      // Optionally, show success message or handle post-save logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event data saved successfully')),
      );
    } catch (error) {
      // Handle any errors that occur during the save process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event: $error')),
      );
    }
  }
}
