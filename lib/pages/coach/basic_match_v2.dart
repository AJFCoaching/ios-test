import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/select_half.dart';
import 'package:matchday/supabase.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class BasicMatchPageV2 extends StatefulWidget {
  const BasicMatchPageV2({Key? key}) : super(key: key);

  @override
  State<BasicMatchPageV2> createState() => _BasicMatchPageStateV2();
}

class _BasicMatchPageStateV2 extends State<BasicMatchPageV2> {
  Future<void> saveActionToSupabase() async {
    final updateAction = {
      'match_code': matchCode,
      'minute': matchEventTime,
      'player': selectedPlayer,
      'action': eventAction,
      'half': matchHalf,
      'assist': playerAssist,
      'team_code': teamCode,
    };
    await supabase.from('match_actions').upsert(updateAction);
  }

  final playerList = supabase.from('event_attendance').select().match({
    'match_code': matchCode,
    'player_attendance': true,
  });

  String selectedPlayer = '';
  String playerAssist = '';

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final _isMinutes = true;
  final _isSeconds = true;

  bool click = true;

  void _selecthalf(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SelectHalfModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        topRow(),
        currentScore(),
        SizedBox(height: 60),
        goalButtons(),
        SizedBox(height: 30),
        shotOnTargetButtons(),
        SizedBox(height: 30),
        shotOffTargetButtons(),
        SizedBox(height: 30),
        passButtons(),
        SizedBox(height: 30),
        tackleButtons(),
        SizedBox(height: 30),
        offsideButtons(),
        Spacer(),
        bottomButtons(),
      ]),
    );
  }

  // top row
  Widget topRow() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black),
      child: Row(
        children: [
          Spacer(),
          Text(
            matchHalf,
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
          StreamBuilder<int>(
            stream: _stopWatchTimer.rawTime,
            initialData: matcHalfLength,
            builder: (context, snapshot) {
              final value = snapshot.data!;
              final displayTime = StopWatchTimer.getDisplayTime(
                value,
                hours: false,
                minute: _isMinutes,
                minuteRightBreak: ':',
                second: _isSeconds,
                milliSecond: false,
              );
              return Text(
                displayTime,
                style: TextStyle(fontSize: 30.0, color: Colors.white),
              );
            },
          ),
          Spacer(),
          Text(
            matchType,
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
        ],
      ),
    );
  }

  // current score
  Widget currentScore() {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Spacer(),
          Column(
            children: [
              SizedBox(height: 5),
              Text(
                teamName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.red,
                    width: 5,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  '$teamcounter',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            'vs',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Column(
            children: [
              SizedBox(height: 5),
              Text(
                oppTeam,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.blue,
                    width: 5,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  '$oppcounter',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  // goal buttons
  Widget goalButtons() {
    return Row(
      children: [
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              setState(() {
                teamcounter++;
                teamXG += 0.45;
                matchEventTime =
                    _stopWatchTimer.minuteTime.value.toStringAsPrecision(1);
                _showGoalPopup(context);
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Goal')),
        Spacer(),
        ElevatedButton(
            onPressed: () {
              setState(() {
                oppcounter++;
                oppXG += 0.45;
                eventAction = 'Goal';
                selectedPlayer = 'Opposition';
                playerAssist = '';
                matchEventTime =
                    _stopWatchTimer.minuteTime.value.toStringAsPrecision(1);
                _showGoalAlert(context);
              });
              saveActionToSupabase();
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Goal')),
        SizedBox(width: 20),
      ],
    );
  }

  // pass buttons
  Widget passButtons() {
    return Row(
      children: [
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              setState(() {
                teamPass++;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Pass')),
        SizedBox(width: 30),
        Text(
          teamPass.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Text(
          oppPass.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 30),
        ElevatedButton(
            onPressed: () {
              setState(() {
                oppPass++;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Pass')),
        SizedBox(width: 20),
      ],
    );
  }

  // tackle buttons
  Widget tackleButtons() {
    return Row(
      children: [
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              setState(() {
                teamTackle++;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Tackle')),
        SizedBox(width: 30),
        Text(
          teamTackle.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Text(
          oppTackle.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 30),
        ElevatedButton(
            onPressed: () {
              setState(() {
                oppTackle++;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Tackle')),
        SizedBox(width: 20),
      ],
    );
  }

  // shot on target buttons
  Widget shotOnTargetButtons() {
    return Row(
      children: [
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              setState(() {
                teamShotOn++;
                teamXG += 0.3;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('On Target')),
        SizedBox(width: 30),
        Text(
          teamShotOn.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Text("SHOT"),
        Spacer(),
        Text(
          oppShotOn.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 30),
        ElevatedButton(
            onPressed: () {
              setState(() {
                oppShotOn++;
                oppXG += 0.3;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('On Target')),
        SizedBox(width: 20),
      ],
    );
  }

  // shot off target buttons
  Widget shotOffTargetButtons() {
    return Row(
      children: [
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              setState(() {
                teamShotOff++;
                teamXG += 0.12;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Off Target')),
        SizedBox(width: 30),
        Text(
          teamShotOff.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Text("SHOT"),
        Spacer(),
        Text(
          oppShotOff.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 30),
        ElevatedButton(
            onPressed: () {
              setState(() {
                oppShotOff++;
                oppXG += 0.12;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Off Target')),
        SizedBox(width: 20),
      ],
    );
  }

  // offside buttons
  Widget offsideButtons() {
    return Row(
      children: [
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              setState(() {
                teamOffside++;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Offisde')),
        SizedBox(width: 30),
        Text(
          teamOffside.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Text(
          oppOffside.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 30),
        ElevatedButton(
            onPressed: () {
              setState(() {
                oppOffside++;
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
            child: Text('Offside')),
        SizedBox(width: 20),
      ],
    );
  }

  // bottom buttons
  Widget bottomButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Column(
                  children: [
                    // start/stop button
                    IconButton(
                      iconSize: 45,
                      onPressed: () {
                        if (click == true) {
                          setState(() {
                            matchEventTime = _stopWatchTimer.minuteTime.value
                                .toStringAsPrecision(1);

                            eventAction = 'Start';
                          });
                          _stopWatchTimer.onResetTimer();
                          _stopWatchTimer.setPresetMinuteTime(0);

                          _stopWatchTimer.onStartTimer();
                        } else {
                          _stopWatchTimer.onStopTimer();
                          setState(() {
                            matchEventTime = _stopWatchTimer.minuteTime.value
                                .toStringAsPrecision(1);

                            eventAction = 'End';
                          });
                        }
                        setState(() {
                          click = !click;
                        });
                        // Start timer.
                      },
                      icon: Icon(
                        (click == true) ? Icons.play_circle : Icons.stop_circle,
                        color: Colors.green,
                      ),
                    ),

                    SizedBox(height: 5),

                    // select half button
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => _selecthalf(context),
                        child: Text('Select Half'))
                  ],
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(children: [
            Spacer(),
            Text('Goal By'),
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
                                  maxCrossAxisExtent: 150,
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
                                  player['player_name'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedPlayer = player['player_name'];
                                    SelectedPlayer = selectedPlayer;
                                    print(players.length);
                                  });
                                });
                          }));
                    }),
              ),
              SizedBox(height: 10),
              Text(
                SelectedPlayer,
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
                    eventAction = 'Goal';
                    savePlayerGoalstoMain();
                  }));
                  Navigator.pop(context);
                  _showAssistPopup(context);
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

  void _showAssistPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(children: [
            Spacer(),
            Text('Assist By'),
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
                                  maxCrossAxisExtent: 150,
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
                                  player['player_name'],
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
                PlayerAssist,
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
                    savePlayerAssistToMain();
                    saveActionToSupabase();
                    playerAssist = '';
                    selectedPlayer = '';
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
