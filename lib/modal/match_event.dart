import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/pages/coach/basic_match.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectEventModal extends StatefulWidget {
  const SelectEventModal({Key? key}) : super(key: key);

  @override
  State<SelectEventModal> createState() => _SelectEventModalState();
}

class _SelectEventModalState extends State<SelectEventModal> {
  final playerList = Supabase.instance.client
      .from('event_attendance')
      .select()
      .eq('match_code', matchCode)
      .isFilter('player_attendance', true);

  String selectedPlayer = '';
  String playerAssist = '';

  Future<void> saveActionToSupabase() async {
    final updateAction = {
      'match_code': matchCode,
      'minute': matchEventTime,
      'player': selectedPlayer,
      'action': eventAction,
      'half': matchHalf,
      'assist': playerAssist,
    };
    await supabase.from('match_actions').upsert(updateAction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Column(
        children: [
          SizedBox(height: 10),

          // Match minute
          Text(
            matchEventTime,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 5),

          Row(children: [
            SizedBox(width: 10),
            Text(
              'Select Player',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
          ]),

          SizedBox(height: 2),

          // Player Select
          Container(
            height: 50,
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: playerList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final players = snapshot.data!;
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: players.length,
                      itemBuilder: ((context, index) {
                        final player = players[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    player['player_short'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedPlayer = player['player_name'];
                                      SelectedPlayer = selectedPlayer;
                                      print(SelectedPlayer);
                                    });
                                  }),
                            ],
                          ),
                        );
                      }));
                }),
          ),

          // gap
          SizedBox(height: 5),

          //gap
          SizedBox(height: 5),

          Row(
            children: [
              Spacer(),
              // player selected
              Text(
                selectedPlayer,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
            ],
          ),

          SizedBox(height: 5),

          // 1st button row

          GridView.count(
            padding: EdgeInsets.all(5),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 4,
            shrinkWrap: true,
            children: [
              // button 1
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text(
                  'SHOT off TARGET',
                  textAlign: TextAlign.center,
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

              // button 2
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                child: Text(
                  'SHOT on TARGET',
                  textAlign: TextAlign.center,
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

              // button 3
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black),
                child: Text(
                  'PEN SCORED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Penalty Scored';
                    teamcounter++;
                    print(matchEventTime);

                    saveActionToSupabase();
                    BasicMatchPage();
                  });
                },
              ),

              // button 4
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text(
                  'PEN MISSED',
                  textAlign: TextAlign.center,
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

              // button 5
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: Text(
                  'PEN SAVED',
                  textAlign: TextAlign.center,
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

              // button 6
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black),
                child: Text(
                  'GOAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Goal';
                    teamcounter++;
                    print(matchEventTime);
                    print(teamcounter);
                  });
                  Navigator.pop(context);
                  _showAssistPopup(context);
                },
              ),

              // button 7
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: Text(
                  'OWN GOAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
                onPressed: () {
                  setState(() {
                    eventAction = 'Own Goal';
                    oppcounter++;
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

  void _showAssistPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(children: [
            Spacer(),
            Text('Assisted By'),
            Spacer(),
          ]),
          content: Container(
            height: 400,
            width: 300,
            child: Column(children: [
              SizedBox(height: 5),
              Container(
                height: 300,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: playerList,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final players = snapshot.data!;
                      return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          itemCount: players.length,
                          itemBuilder: ((context, index) {
                            final player = players[index];
                            return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  player['player_short'],
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    playerAssist = player['player_name'];
                                    PlayerAssist = playerAssist;
                                    print(players.length);
                                  });
                                });
                          }));
                    }),
              ),
              SizedBox(height: 10),
              Text(
                playerAssist,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState((() {
                    saveActionToSupabase();
                    savePlayerGoalstoMain();
                    savePlayerAssistToMain();
                  }));
                  Navigator.pop(context);
                  _showGoalAlert(context);
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]),
          ),
        ),
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
