import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/select_half.dart';
import 'package:matchday/pages/coach/match_v3/bottom_buttons.dart';
import 'package:matchday/pages/coach/match_v3/current_score_header.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/player_positions_notifier.dart';
import 'package:matchday/supabase/notifier/player_swap_notifier.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
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

  Future<void> _refreshPlayerPositions() async {
    await Provider.of<PlayerPositionsNotifier>(context, listen: false)
        .fetchPlayers();
  }

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
                final playerSwapProvider =
                    Provider.of<PlayerSwapProvider>(context, listen: false);
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

                playerSwapProvider.updatePlayerPositionToSub(
                  playerSwapProvider.selectedPlayer,
                );
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
    return Scaffold(
      body: Column(children: [
        // Top of the screen: top row and current score
        topRow(context),
        CurrentScore(),
        const SizedBox(height: 5),

        // Refreshable Stack with soccer pitch background image and player rows
        SizedBox(
          height: 530, // Fixed height for pitchArea
          child: RefreshIndicator(
            onRefresh: _refreshPlayerPositions,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: pitchArea(context),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Opposition row
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
                  matchEventTime =
                      _stopWatchTimer.minuteTime.value.toStringAsPrecision(1);
                });

                // Call the popup function with necessary parameters
                showEventPopup(context, matchEventTime, selectedPlayer,
                    selectedPlayerPosition, matchCode);
              },
              child: const Text(
                  'Opposition'), // Proper label instead of child: null
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 18),
        const Spacer(),

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
          const Spacer(),
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

  Widget pitchArea(BuildContext context) {
    final playerPositions = Provider.of<PlayerPositionsNotifier>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double topHeight =
        150; // Approximate height of topRow() and currentScore()
    final double bottomHeight = 200; // Approximate height of player rows
    final double imageHeight = screenHeight - topHeight - bottomHeight;

    return

        // Main content: Stack with soccer pitch background image and player rows
        Container(
      height: 500,
      margin: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 10), // Margin around the container
      decoration: BoxDecoration(
        color: Colors.green, // Background color
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(
          color: Colors.grey.shade400, // Border color
          width: 2, // Border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8, // Shadow blur
            offset: const Offset(4, 4), // Shadow offset
          ),
        ],
      ),
      child: Stack(
        children: [
          Image.asset(
            'assets/Soccer_Field.png',
            width: screenWidth,
            height: imageHeight,
            fit: BoxFit.fill,
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
            ],
          ),
        ],
      ),
    );
  }
}
