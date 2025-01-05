import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/select_half.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class BasicMatchPageV2 extends StatefulWidget {
  const BasicMatchPageV2({super.key});

  @override
  State<BasicMatchPageV2> createState() => _BasicMatchPageStateV2();
}

class _BasicMatchPageStateV2 extends State<BasicMatchPageV2> {
  Future<void> saveActionToSupabase() async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);

    final updateAction = {
      'match_code': matchStatsProvider.matchCode,
      'minute': matchEventTime,
      'player': selectedPlayer,
      'action': eventAction,
      'half': matchHalf,
      'assist': playerAssist,
      'team_code': userInfo.teamCode,
    };
    await supabase.from('match_actions').upsert(updateAction);
  }

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
        return const SelectHalfModal();
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
        topRow(context),
        currentScore(context),
//        SizedBox(height: 60),
        const Spacer(),
        goalButtons(context),
        const SizedBox(height: 30),
        shotOnTargetButtons(context),
        const SizedBox(height: 30),
        shotOffTargetButtons(context),
        const SizedBox(height: 60),
        bottomButtons(),
      ]),
    );
  }

  // top row
  Widget topRow(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    return Container(
      height: 40,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.black),
      child: Row(
        children: [
          const Spacer(),
          Text(
            matchHalf,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          StreamBuilder<int>(
            stream: _stopWatchTimer.rawTime,
            initialData: matchHalfLength,
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
                style: const TextStyle(fontSize: 30.0, color: Colors.white),
              );
            },
          ),
          const Spacer(),
          Text(
            matchData.matchType,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // current score
  Widget currentScore(BuildContext context) {
    final matchStats = Provider.of<SelectedMatchStats>(context);
    final matchData = Provider.of<MatchAdd>(context);
    final userInfo = Provider.of<UserInfo>(context);

    return Container(
      height: 110,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userInfo.teamName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // To handle overflow
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.red,
                      width: 5,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    '${matchStats.teamScore}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
//          SizedBox(width: 20), // Spacing between the two teams
          const Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'vs',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
//          SizedBox(width: 20), // Spacing between the two teams
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  matchData.oppTeam,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // To handle overflow
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.blue,
                      width: 5,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    '${matchStats.oppScore}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // goal buttons
  Widget goalButtons(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        ElevatedButton(
            onPressed: () {
              // Access the MatchStats provider
              final matchStats =
                  Provider.of<SelectedMatchStats>(context, listen: false);

              matchStats.teamScore++;
              matchStats.teamShotOn++;
              matchStats.teamXG += 0.45;

              // Notify listeners about the changes
              matchStats.notifyListeners();

              setState(() {
                matchEventTime =
                    _stopWatchTimer.minuteTime.value.toStringAsPrecision(1);
//                _showGoalPopup(context);
              });
            },
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white)),
            child: const Text('Goal')),
        const Spacer(),
        ElevatedButton(
            onPressed: () {
              // Access the MatchStats provider
              final matchStats =
                  Provider.of<SelectedMatchStats>(context, listen: false);

              matchStats.oppScore++;
              matchStats.oppShotOn++;
              matchStats.oppXG += 0.45;

              // Notify listeners about the changes
              matchStats.notifyListeners();

              setState(() {
                eventAction = 'Goal';
                selectedPlayer = 'Opposition';
                playerAssist = '';
                matchEventTime =
                    _stopWatchTimer.minuteTime.value.toStringAsPrecision(1);
                _showGoalAlert(context);
              });
              saveActionToSupabase();
            },
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.white)),
            child: const Text('Goal')),
        const SizedBox(width: 20),
      ],
    );
  }

  // shot on target buttons
  Widget shotOnTargetButtons(BuildContext context) {
    final matchStats = Provider.of<SelectedMatchStats>(
        context); // Access the MatchStats provider

    return Row(
      children: [
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            matchStats.incrementTeamShotOn(); // Increment team shot on
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.red),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          child: const Text('On Target'),
        ),
        const SizedBox(width: 30),
        Text(
          matchStats.teamShotOn.toString(), // Display team shots on
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const Text("SHOT"),
        const Spacer(),
        Text(
          matchStats.oppShotOn.toString(), // Display opponent shots on
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            matchStats.incrementOppShotOn(); // Increment opponent shot on
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          child: const Text('On Target'),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  // shot off target buttons
  Widget shotOffTargetButtons(BuildContext context) {
    final matchStats = Provider.of<SelectedMatchStats>(
        context); // Access the MatchStats provider

    return Row(
      children: [
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            matchStats.incrementTeamShotOff(); // Increment team shot off
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.red),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          child: const Text('Off Target'),
        ),
        const SizedBox(width: 30),
        Text(
          matchStats.teamShotOff.toString(), // Display team shots off
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const Text("SHOT"),
        const Spacer(),
        Text(
          matchStats.oppShotOff.toString(), // Display opponent shots off
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            matchStats.incrementOppShotOff(); // Increment opponent shot off
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          child: const Text('Off Target'),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  // bottom buttons
  Widget bottomButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 120,
        decoration: const BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
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

                    const SizedBox(height: 5),

                    // select half button
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => _selecthalf(context),
                        child: const Text('Select Half'))
                  ],
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

//  void _showGoalPopup(BuildContext context) {
//    showDialog(
//      context: context,
//      builder: (context) => StatefulBuilder(
//        builder: (context, setState) => AlertDialog(
//          title: const Row(children: [
//            Spacer(),
//            Text('Goal By'),
//            Spacer(),
//          ]),
//          content: SizedBox(
//            height: 400,
//            width: 300,
//            child: Column(children: [
//              const SizedBox(height: 5),
//              SizedBox(
//                height: 300,
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                    future: playerList,
//                    builder: (context, snapshot) {
//                      if (!snapshot.hasData) {
//                        return const Center(child: CircularProgressIndicator());
//                      }
//                      final players = snapshot.data!;
//                      return GridView.builder(
//                          gridDelegate:
//                              const SliverGridDelegateWithMaxCrossAxisExtent(
//                                  maxCrossAxisExtent: 150,
//                                  childAspectRatio: 1,
//                                  crossAxisSpacing: 10,
//                                  mainAxisSpacing: 10),
//                         itemCount: players.length,
//                          itemBuilder: ((context, index) {
//                            final player = players[index];
//                            return ElevatedButton(
//                                style: ElevatedButton.styleFrom(
//                                  shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(40),
//                                  ),
//                                  backgroundColor: Colors.red,
//                                  foregroundColor: Colors.white,
//                                ),
//                                child: Text(
//                                  player['player_name'],
//                                  style: const TextStyle(fontSize: 16),
//                                ),
//                               onPressed: () {
//                                  setState(() {
//                                    selectedPlayer = player['player_name'];
//                                    selectedPlayerMain = selectedPlayer;
//                                  });
//                                });
//                          }));
//                    }),
//              ),
//              const SizedBox(height: 10),
//              Text(
//                selectedPlayerMain,
//                style:
//                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//              ),
//              const Spacer(),
//              ElevatedButton(
//                style: ElevatedButton.styleFrom(
//                  backgroundColor: Colors.black,
//                  foregroundColor: Colors.white,
//                ),
//                onPressed: () {
//                  setState((() {
//                    eventAction = 'Goal';
//                    savePlayerGoalstoMain();
//                  }));
//                  Navigator.pop(context);
//                  _showAssistPopup(context);
//                },
//                child: const Text(
//                  'Confirm',
//                  style: TextStyle(fontWeight: FontWeight.bold),
//                ),
//              ),
//            ]),
//          ),
//        ),
//      ),
//    );
//  }

//  void _showAssistPopup(BuildContext context) {
//    showDialog(
//      context: context,
//      builder: (context) => StatefulBuilder(
//        builder: (context, setState) => AlertDialog(
//          title: const Row(children: [
//            Spacer(),
//            Text('Assist By'),
//            Spacer(),
//          ]),
//          content: SizedBox(
//            height: 400,
//            width: 300,
//            child: Column(children: [
//              const SizedBox(height: 5),
//              SizedBox(
//                height: 300,
//                child: FutureBuilder<List<Map<String, dynamic>>>(
//                    future: playerList,
//                    builder: (context, snapshot) {
//                      if (!snapshot.hasData) {
//                        return const Center(child: CircularProgressIndicator());
//                      }
//                      final players = snapshot.data!;
//                      return GridView.builder(
//                          gridDelegate:
//                              const SliverGridDelegateWithMaxCrossAxisExtent(
//                                  maxCrossAxisExtent: 150,
//                                  childAspectRatio: 1,
//                                 crossAxisSpacing: 10,
//                                  mainAxisSpacing: 10),
//                          itemCount: players.length,
//                          itemBuilder: ((context, index) {
//                            final player = players[index];
//                            return ElevatedButton(
//                                style: ElevatedButton.styleFrom(
//                                  shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(40),
//                                  ),
//                                  backgroundColor: Colors.red,
//                                  foregroundColor: Colors.white,
//                                ),
//                                child: Text(
//                                  player['player_name'],
//                                  style: const TextStyle(fontSize: 12),
//                                ),
//                                onPressed: () {
//                                  setState(() {
//                                    playerAssist = player['player_name'];
//                                    playerAssistMain = playerAssist;
//                                  });
//                                });
//                          }));
//                    }),
//              ),
//              const SizedBox(height: 10),
//              Text(
//                playerAssistMain,
//                style:
//                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//              ),
//              const Spacer(),
//             ElevatedButton(
//                style: ElevatedButton.styleFrom(
//                  backgroundColor: Colors.black,
//                  foregroundColor: Colors.white,
//                ),
//                onPressed: () {
//                  setState((() {
//                    savePlayerAssistToMain();
//                    saveActionToSupabase();
//                    playerAssist = '';
//                    selectedPlayer = '';
//                  }));
//                  Navigator.pop(context);
//                  _showGoalAlert(context);
//                },
//                child: const Text(
//                  'Confirm',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                ),
//              ),
//            ]),
//          ),
//        ),
//      ),
//    );
//  }

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
