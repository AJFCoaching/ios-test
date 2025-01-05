import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/pages/coach/basic_match.dart';
import 'package:matchday/main.dart';

class SelectOppEventModal extends StatefulWidget {
  const SelectOppEventModal({Key? key}) : super(key: key);

  @override
  State<SelectOppEventModal> createState() => _SelectOppEventModalState();
}

class _SelectOppEventModalState extends State<SelectOppEventModal> {
  String selectedPlayer = 'Opposition';

  Future<void> saveActionToSupabase() async {
    final updateAction = {
      'match_code': matchCode,
      'minute': matchEventTime,
      'player': selectedPlayer,
      'action': eventAction,
      'half': matchHalf,
    };
    await supabase.from('match_actions').upsert(updateAction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(height: 10),

          // Match minute
          Text(
            matchEventTime,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          // Player Select
          Text(
            selectedPlayer,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          // 1st button row

          Row(
            children: [
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text(
                  'SHOT off TARGET',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Shot off Target';

                    print(matchEventTime);

                    saveActionToSupabase();
                    BasicMatchPage();
                  });
                },
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                child: Text(
                  'SHOT on TARGET',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Shot on Target';

                    print(matchEventTime);

                    saveActionToSupabase();
                    BasicMatchPage();
                  });
                },
              ),
              Spacer(),
            ],
          ),

          SizedBox(height: 30),

          //2nd button row

          Row(
            children: [
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black),
                child: Text(
                  'PEN SCORED',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Penalty Scored';

                    print(matchEventTime);

                    saveActionToSupabase();
                    BasicMatchPage();
                  });
                },
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text(
                  'PEN MISSED',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Penalty Missed';

                    print(matchEventTime);

                    saveActionToSupabase();
                    BasicMatchPage();
                  });
                },
              ),
              Spacer(),
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: Text(
                  'PEN SAVED',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Penalty Saved';

                    print(matchEventTime);

                    saveActionToSupabase();
                    BasicMatchPage();
                  });
                },
              ),
              Spacer(),
            ],
          ),

          SizedBox(height: 30),

          Row(
            children: [
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black),
                child: Text(
                  'GOAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Goal';
                    oppcounter++;
                    print(matchEventTime);
                    print(oppcounter);

                    saveActionToSupabase();
                  });
                  Navigator.pop(context);
                  _showGoalAlert(context);
                },
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: Text(
                  'OWN GOAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Own Goal';
                    teamcounter++;
                    print(matchEventTime);

                    saveActionToSupabase();
                  });
                },
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  void _showGoalAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Lottie.network(
            'https://lottie.host/d54d9150-ac67-4459-97ef-b1fe425588e8/tbWIw0RMUe.json',
            width: 300,
            height: 300,
          ),
        );
      },
    );
  }
}
