import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/match_event_popup.dart';
import 'package:matchday/modal/select_half.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class BasicMatchPage extends StatefulWidget {
  const BasicMatchPage({Key? key}) : super(key: key);

  @override
  State<BasicMatchPage> createState() => _BasicMatchPageState();
}

class _BasicMatchPageState extends State<BasicMatchPage> {
  Future<void> addActionToSupabase() async {
    final matchStatsProvider =
        Provider.of<SelectedMatchStats>(context, listen: false);
    final matchAction = {
      'match_code': matchStatsProvider.matchCode,
      'minute': matchEventTime,
      'action': eventAction,
      'half': matchHalf,
    };
    await supabase.from('match_actions').upsert(matchAction);
  }

  Stream<List<Map<String, dynamic>>> getMatchActions() {
    final matchStatsProvider =
        Provider.of<SelectedMatchStats>(context, listen: false);
    return supabase
        .from('match_actions')
        .stream(primaryKey: ['id'])
        .eq('match_code', matchStatsProvider.matchCode)
        .order('id', ascending: false);
  }

  final playerList = supabase.from('squad').select('player_name');

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final _isMinutes = true;
  final _isSeconds = true;

  bool click = true;

  int teamcounter = 0;
  int oppcounter = 0;

  String teamScore = '';
  String oppScore = '';

  void _selecthalf(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SelectHalfModal();
      },
    );
  }

  void _selectAction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return EventPopup(
          matchEventTime: '',
          selectedPlayer: '',
          selectedPlayerPosition: '',
        );
      },
    );
  }

  void _selectOppaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return EventPopup(
          matchEventTime: '',
          selectedPlayer: '',
          selectedPlayerPosition: '',
        );
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
        mainBody(),
        bottomButtons(),
      ]),
    );
  }

  // top row
  Widget topRow() {
    final matchInfoProvider = Provider.of<MatchAdd>(context, listen: false);
    return Container(
      height: 80,
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
            initialData: matchInfoProvider.matchHalfLength,
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
            matchInfoProvider.matchType,
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
        ],
      ),
    );
  }

  // current score
  Widget currentScore() {
    final userInfoProvider = Provider.of<UserInfo>(context, listen: false);
    final matchInfoProvider = Provider.of<MatchAdd>(context, listen: false);
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
                userInfoProvider.teamName,
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
                matchInfoProvider.oppTeam,
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

  // main body container
  Widget mainBody() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.green),
        padding: EdgeInsets.all(10),
        child: Expanded(
          child: SingleChildScrollView(child: _getMatchActions()),
        ),
      ),
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
                IconButton(
                  onPressed: () {
                    _selectAction(context);

                    setState(
                      () {
                        matchEventTime = _stopWatchTimer.minuteTime.value
                            .toStringAsPrecision(1);
                        print(matchEventTime);
                      },
                    );
                  },
                  icon: Icon(
                    Icons.sports_soccer,
                    color: Colors.red,
                    size: 70,
                  ),
                ),
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
                          addActionToSupabase();
                        } else {
                          _stopWatchTimer.onStopTimer();
                          setState(() {
                            matchEventTime = _stopWatchTimer.minuteTime.value
                                .toStringAsPrecision(1);

                            eventAction = 'End';
                          });
                          addActionToSupabase();
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
                IconButton(
                  onPressed: () {
                    _selectOppaction(context);

                    setState(
                      () {
                        matchEventTime = _stopWatchTimer.minuteTime.value
                            .toStringAsPrecision(1);
                        print(matchEventTime);
                      },
                    );
                  },
                  icon: Icon(
                    Icons.sports_soccer,
                    color: Colors.blue,
                    size: 70,
                  ),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void increaseTeamValue() {
    setState(() {
      // Convert the string to an integer, increment it, and then convert it back to a string
      int currentValue = int.parse(teamScore);
      teamScore = (currentValue + 1).toString();
    });
  }

  void increaseOppValue() {
    setState(() {
      // Convert the string to an integer, increment it, and then convert it back to a string
      int currentValue = int.parse(oppScore);
      oppScore = (currentValue + 1).toString();
    });
  }

  _getMatchActions() {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: getMatchActions(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            var data = snapshot.data ?? [];
            return ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(20)),
                    leading: Wrap(spacing: 2, children: [
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          data[index]['minute'].toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (data[index]['action'] == 'Start' &&
                          matchHalf == '1st Half')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/kick-off.png")),
                      if (data[index]['action'] == 'Start' &&
                          matchHalf == '2nd Half')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/kick-off.png")),
                      if (data[index]['action'] == 'End' &&
                          matchHalf == '1st Half')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/half-time.png")),
                      if (data[index]['action'] == 'End' &&
                          matchHalf == '2nd Half')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/full-time.png")),
                      if (data[index]['action'] == 'Goal')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/goal.png")),
                      if (data[index]['action'] == 'Shot on Target')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/target.png")),
                      if (data[index]['action'] == 'Shot off Target')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/off-target.png")),
                      if (data[index]['action'] == 'Penalty Saved')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/goalkeeper.png")),
                      if (data[index]['action'] == 'Penalty Missed')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/off-target.png")),
                      if (data[index]['action'] == 'Penalty Scored')
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/goal.png")),
                    ]),
                    title: Row(children: [
                      Text(
                        data[index]['player'].toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      if (data[index]['assist'] == '')
                        SizedBox.shrink()
                      else
                        SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("assets/friendship.png")),
                      SizedBox(width: 10),
                      if (data[index]['assist'] == '')
                        SizedBox.shrink()
                      else
                        Text(
                          data[index]['assist'].toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                    ]),
                  );
                },
                itemCount: data.length);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
