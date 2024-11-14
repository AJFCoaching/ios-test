import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/select_half.dart';
import 'package:matchday/pages/coach/match_v3/bottom_buttons.dart';
import 'package:matchday/pages/coach/match_v3/current_score_header.dart';
import 'package:matchday/supabase/notifier/player_positions_notifier.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:matchday/supabase/save_match_action.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:matchday/modal/match_event_popup.dart';

class BasicMatchPageV3 extends StatefulWidget {
  const BasicMatchPageV3({super.key});

  @override
  State<BasicMatchPageV3> createState() => _BasicMatchPageStateV3();
}

String selectedPlayer = '';
String selectedPlayerPosition = '';
String playerAssist = '';
String matchCode = '';

final StopWatchTimer stopWatchTimer = StopWatchTimer();
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

class _BasicMatchPageStateV3 extends State<BasicMatchPageV3> {
  String selectedPlayer = '';
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  // Function to get player initials from full name
  String getPlayerInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return nameParts[0][0] +
          nameParts[1][0]; // First letter of first and last name
    } else {
      return nameParts[0][0]; // If single name, return the first letter
    }
  }

  // Generic method to create rows of circular buttons for players, now showing short position names
  Widget playerRow(List<Map<String, dynamic>> players, Color color) {
    if (players.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if no players
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        ...players.map((playerData) {
          String initials = getPlayerInitials(playerData['player_name']);
          String playerName = playerData['player_name'];
          String playerPosition = playerData['position'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: GestureDetector(
              onTap: () {
                final matchEventProvider =
                    Provider.of<SelectedMatchStats>(context, listen: false);
                setState(() {
                  selectedPlayer = playerName;
                  selectedPlayerPosition = playerPosition;
                  matchEventTime =
                      _stopWatchTimer.minuteTime.value.toStringAsPrecision(1);
                  matchCode = matchEventProvider.matchCode;
                });

                // Call the popup function with necessary parameters
                showEventPopup(context, matchEventTime, selectedPlayer,
                    selectedPlayerPosition, matchCode);
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        (selectedPlayer == initials) ? Colors.black : color,
                    radius: 25,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlayerPositionsNotifier>(context, listen: false)
          .fetchPlayers(); // Replace with actual matchCode
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerPositions = Provider.of<PlayerPositionsNotifier>(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double topHeight =
        150; // Approximate height of topRow() and currentScore()
    final double bottomHeight = 200; // Approximate height of player rows
    final double imageHeight = screenHeight - topHeight - bottomHeight;

    return Scaffold(
      body: Column(children: [
        // Top of the screen: top row and current score
        topRow(context),
        CurrentScore(),
        const SizedBox(height: 5),

        // Main content: Stack with soccer pitch background image and player rows
        Expanded(
          child: Stack(
            children: [
              Positioned(
                bottom: 135,
                left: 20,
                right: 20,
                child: Image.asset(
                  'assets/Soccer_Field.png',
                  width: screenWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Forward Row
                  playerRow(playerPositions.forwards, Colors.red),
                  const Spacer(),

                  // Attacking Midfield Row
                  playerRow(playerPositions.attackingMidfielders, Colors.red),
                  const Spacer(),

                  // Midfield Row
                  playerRow(playerPositions.midfielders, Colors.red),
                  const Spacer(),

                  // Defensive Midfield Row
                  playerRow(playerPositions.defensiveMidfielders, Colors.red),
                  const Spacer(),

                  // Defense Row
                  playerRow(playerPositions.defenders, Colors.red),
                  const Spacer(),

                  // Goalkeeper Row
                  playerRow(playerPositions.goalkeepers, Colors.blue),

                  const SizedBox(height: 15),

                  // Substitutes Row with "Subs" label
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0), // Optional spacing
                        child: Text(
                          'Subs',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Change color if desired
                          ),
                        ),
                      ),
                      Expanded(
                        child: playerRow(
                            playerPositions.substitutes, Colors.amber),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // oposition row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPlayer = 'Opposition';
                            matchEventTime = _stopWatchTimer.minuteTime.value
                                .toStringAsPrecision(1);
                          });

                          // Call the popup function with necessary parameters
                          showEventPopup(
                              context,
                              matchEventTime,
                              selectedPlayer,
                              selectedPlayerPosition,
                              matchCode);
                        },
                        child: const Text(
                            'Oposition'), // Proper label instead of child: null
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),

        BottomButtons(
          stopWatchTimer: _stopWatchTimer,
          matchHalf: matchHalf,
          matchHalfLength: matchHalfLength,
          onHalfSelected: () => _selecthalf(context),
          click: click,
          toggleClick: (value) => setState(() {
            click = value;
          }),
          updateEventAction: (action) => setState(() {
            eventAction = action;
          }),
          updateMatchEventTime: (time) => setState(() {
            matchEventTime = time.toStringAsFixed(1);
          }),
        )
      ]),
    );
  }

// top row
  Widget topRow(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    return Container(
        height: 90,
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Column(children: [
          Spacer(),
          Row(
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
        ]));
  }

  void saveGoalWithAssist(BuildContext context, String assistPlayer) async {
    final saveActionProvider =
        Provider.of<SaveActionToSupabase>(context, listen: false);
    final matchEventProvider =
        Provider.of<SelectedMatchStats>(context, listen: false);
    final userInfoProvider = Provider.of<UserInfo>(context, listen: false);

    try {
      // Save details into the provider
      saveActionProvider.matchCode = matchEventProvider.matchCode;
      saveActionProvider.teamCode = userInfoProvider.teamCode;
      saveActionProvider.matchEventTime = matchEventTime;
      saveActionProvider.matchHalf = matchHalf;
      saveActionProvider.selectedPlayer = selectedPlayer;
      saveActionProvider.playerAssist = assistPlayer;
      saveActionProvider.eventAction = 'Goal with Assist';

      // Update the score and stats
      if (selectedPlayer == 'Opposition') {
        matchEventProvider.incrementOppScore();
        matchEventProvider.incrementOppGoalXG();
      } else if (selectedPlayer.isNotEmpty) {
        matchEventProvider.incrementTeamScore();
        matchEventProvider.incrementTeamGoalXG();
      }

      // Save action to Supabase
      await saveActionProvider.saveAction();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal and assist saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving action: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
