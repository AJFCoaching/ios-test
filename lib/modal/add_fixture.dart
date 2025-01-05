import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/coach/select_address.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class AddEventModel extends StatefulWidget {
  @override
  _AddEventModelState createState() => _AddEventModelState();
}

class _AddEventModelState extends State<AddEventModel> {
  String _selectedEventType = 'Training';

  // ignore: unused_field
  final String _postcode = '';
  // ignore: unused_field
  String _oppositionName = '';

  int _currentTimeValue = 30;

  TimeOfDay selectedTime = TimeOfDay.now();

  DateTime date = DateTime.now();

  static const Map<int, String> monthsInYear = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "June",
    7: "July",
    8: "Aug",
    9: "Sept",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };

  Future<void> saveEventDataToSupabase() async {
    final String matchCode = _generateMatchCode();

    final updates = {
      'team_code': teamCode,
      'Type': _selectedEventType,
      'event_date': matchDate,
      'Opp': _oppositionName,
      'location': address,
      'time': matchEventTime,
      'address_long': addresslong,
      'address_lat': addresslat,
      'match_half_length': _currentTimeValue,
      'date': listDate,
      'match_training': EventTraining,
      'day': date.day,
      'month': matchMonth,
      'fixture_ref': matchCode,
      'season': currentSeasonDate,
    };

    try {
      await supabase.from('fixtures').upsert(updates);

      // Fetch the list of players for the given teamCode
      final response = await supabase
          .from('squad')
          .select('player_name')
          .eq('team_code', teamCode);

      // Prepare attendance data
      List<Map<String, dynamic>> attendanceData = [];
      for (var player in response) {
        attendanceData.add({
          'player_name': player['player_name'],
          'player_attendance': null, // Default attendance status
          'match_code': matchCode,
        });
      }

      // Insert attendance data into event_attendance table
      final attendanceResponse =
          await supabase.from('event_attendance').insert(attendanceData);

      if (attendanceResponse != null) {
        throw attendanceResponse.error!;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fixture Added'),
          ),
        );
      }
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _generateMatchCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              currentSeason(),
              SizedBox(height: 20),
              getAddressButton(),
              SizedBox(height: 16),
              Text(address),
              SizedBox(height: 20),
              dropdownEventType(),
              SizedBox(height: 35),
              rowOneDate(),
              SizedBox(height: 25),
              rowTwoTime(),
              SizedBox(height: 20),
              oppNameField(),
              SizedBox(height: 35),
              rowThreeHalfLength(),
              SizedBox(height: 35),
              rowFourButtons(),
            ],
          ),
        ));
  }

  Widget currentSeason() {
    return Row(
      children: [
        Spacer(),
        Text(
          currentSeasonDate,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Spacer(),
      ],
    );
  }

  Widget getAddressButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, foregroundColor: Colors.white),
      child: Text("Get Address"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) => SelectAddress()),
        );
      },
    );
  }

  Widget dropdownEventType() {
    return DropdownButtonFormField(
      value: _selectedEventType,
      onChanged: (value) {
        setState(() {
          _selectedEventType = value.toString();
          if (_selectedEventType == 'Training') {
            EventTraining = true;
          } else {
            EventTraining = false;
          }
        });
      },
      items: ['Training', 'Friendly', 'League', 'Cup'].map((eventType) {
        return DropdownMenuItem(
          value: eventType,
          child: Text(eventType),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Event Type'),
    );
  }

  Widget rowOneDate() {
    return Row(
      children: [
        // space
        Spacer(),

        // date button
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
            setState(() => date = newDate);
            setState(() {
              matchDate = "${date.day}/${date.month}/${date.year}";
              listDate = "${date.year}-${date.month}-${date.day}";
              matchMonth = "${monthsInYear[date.month]}";
            });
          },
          icon: Icon(Icons.calendar_month),
          label: const Text("SELECT DATE"),
        ),

        // space
        Spacer(),

        // date selected
        Text(
          "${date.day}/${date.month}/${date.year}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        //space
        Spacer(),
      ],
    );
  }

  Widget rowTwoTime() {
    return Row(
      children: [
        Spacer(),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          icon: Icon(Icons.av_timer_sharp),
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
                matchEventTime = "${selectedTime.hour}:${selectedTime.minute}";
              });
            }
          },
        ),
        Spacer(),
        Text(
          "${selectedTime.hour}:${selectedTime.minute}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Spacer(),
      ],
    );
  }

  Widget oppNameField() {
    return TextFormField(
      onChanged: (value) {
        setState(() {
          _oppositionName = value;
        });
      },
      decoration: InputDecoration(labelText: 'Opposition Name'),
    );
  }

  Widget rowThreeHalfLength() {
    return Row(
      children: [
        // space
        Spacer(),

        // text
        Text('SELECT HALF LENGTH'),

        // space
        Spacer(),

        // dropdown
        NumberPicker(
          value: _currentTimeValue,
          minValue: 5,
          maxValue: 45,
          onChanged: (value) => setState(() => _currentTimeValue = value),
        ),

        // space
        Spacer(),
      ],
    );
  }

  Widget rowFourButtons() {
    return Row(
      children: [
        Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, foregroundColor: Colors.black),
          onPressed: () async {
            // Save data to Supabase
            await saveEventDataToSupabase();

            // Return to the previous page
            Navigator.pop(context);
          },
          child: Text('Submit'),
        ),
        Spacer(),
      ],
    );
  }
}
