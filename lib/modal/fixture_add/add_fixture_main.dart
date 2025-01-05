import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/fixture_add/event_type.dart';
import 'package:matchday/modal/fixture_add/half_length.dart';
import 'package:matchday/modal/fixture_add/select_date.dart';
import 'package:matchday/modal/fixture_add/select_time.dart';
import 'package:matchday/pages/coach/select_address.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class AddEventModel extends StatefulWidget {
  const AddEventModel({super.key});

  @override
  _AddEventModelState createState() => _AddEventModelState();
}

class _AddEventModelState extends State<AddEventModel> {
  String oppName = '';

  @override
  Widget build(BuildContext context) {
    final matchEventNotifier = Provider.of<MatchAdd>(context, listen: false);
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
              Text(matchEventNotifier.address),
              SizedBox(height: 20),
              DropdownEventBar(
                initialEventType: 'Friendly',
                onEventTypeChanged: (isTraining) {
                  print('Is training: $isTraining');
                },
              ),
              SizedBox(height: 35),
              DateSelector(),
              SizedBox(height: 25),
              TimeSelector(),
              SizedBox(height: 20),
              oppNameField(),
              SizedBox(height: 35),
              HalfLengthSelector(
                onHalfLengthSelected: (int) {},
              ),
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

  Widget oppNameField() {
    return TextFormField(
      onChanged: (value) {
        setState(() {
          oppName = value;
        });
      },
      decoration: InputDecoration(labelText: 'Opposition Name'),
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
            final matchInfoProvider =
                Provider.of<MatchAdd>(context, listen: false);
            final userInfoProvider =
                Provider.of<UserInfo>(context, listen: false);

            // update info
            matchInfoProvider.teamCode = userInfoProvider.teamCode;
            matchInfoProvider.oppName = oppName;
            matchInfoProvider.currentSeasonDate =
                userInfoProvider.currentSeasonDate;

            // Combine matchDate and matchEventTime into matchEventDate (timestampz)
            // Parse matchEventTime (e.g., "14:30") into hour and minute
            final timeParts = matchInfoProvider.matchEventTime.split(':');
            final int eventHour = int.parse(timeParts[0]);
            final int eventMinute = int.parse(timeParts[1]);

            // Combine matchDate and time into a DateTime object
            final combinedDateTime = DateTime(
              matchInfoProvider.dateTime.year,
              matchInfoProvider.dateTime.month,
              matchInfoProvider.dateTime.day,
              eventHour,
              eventMinute,
            );

            // Convert to UTC and store in matchEventDate
            matchInfoProvider.matchEventDate = combinedDateTime.toUtc();

            // Save data to Supabase
            await matchInfoProvider.saveEventToSupabaseFixture();
            await matchInfoProvider.saveEventToSupabaseFixtureStats();

            print(matchInfoProvider.teamCode);
            print(matchInfoProvider.matchType);
//            print(matchInfoProvider.matchDateTime);
            print(matchInfoProvider.matchEventTime);
            print(matchInfoProvider.oppTeam);
            print(matchInfoProvider.address);
            print(matchInfoProvider.addressLong);
            print(matchInfoProvider.addressLat);
            print(matchInfoProvider.matchHalfLength);
            print(matchInfoProvider.eventTraining);
            print(matchInfoProvider.matchCode);
            print(matchInfoProvider.season);

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
