// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/pages/coach/match_v3/basic_match_v3.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/selected_players.dart';
import 'package:matchday/supabase/save_match_action.dart';
import 'package:matchday/supabase/supabase.dart';
import 'package:provider/provider.dart';

class SelectEventModal extends StatefulWidget {
  const SelectEventModal({super.key});

  @override
  State<SelectEventModal> createState() => _SelectEventModalState();
}

class _SelectEventModalState extends State<SelectEventModal> {
  late final Future<List<Map<String, dynamic>>> playerList;

  String selectedPlayer = '';
  String playerAssist = '';

  @override
  Widget build(BuildContext context) {
    final selectedPlayerProvider = Provider.of<SelectedPlayers>(context);
    final saveActionProvider = Provider.of<SaveActionToSupabase>(context);
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);

    return SizedBox(
      height: 600,
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Match minute
          Text(
            matchEventTime,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          const Row(children: [
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

          const SizedBox(height: 2),

          // Player Select
          SizedBox(
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
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () {
                                    // Update the selected player in the ChangeNotifier
                                    selectedPlayerProvider.setSelectedPlayer(
                                        player['player_name']);
                                  }),
                            ],
                          ),
                        );
                      }),
                    );
                  })),

          // gap
          const SizedBox(height: 5),

          //gap
          const SizedBox(height: 5),

          Row(
            children: [
              const Spacer(),
              // player selected
              Text(
                selectedPlayer,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 5),

          // 1st button row

          GridView.count(
            padding: const EdgeInsets.all(5),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 4,
            shrinkWrap: true,
            children: [
              // button 1
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text(
                  'SHOT off TARGET',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () async {
                  setState(() {
                    eventAction = 'Shot off Target'; // Update the event action
                  });

                  // Set the properties in the ChangeNotifier
                  saveActionProvider.setEventAction(eventAction);
                  saveActionProvider.setMatchCode(
                      matchStatsProvider.matchCode); // Set match code
                  saveActionProvider.setTeamCode(
                      matchStatsProvider.teamCode); // Set team code
                  saveActionProvider
                      .setMatchEventTime(matchEventTime); // Set event time
                  saveActionProvider
                      .setSelectedPlayer(selectedPlayer); // Set selected player
                  saveActionProvider
                      .setMatchHalf(matchHalf); // or 'second_half', as needed

                  // Call saveAction to save the action to Supabase
                  await saveActionProvider.saveAction();

                  const BasicMatchPageV3();
                },
              ),

              // button 2
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                child: const Text(
                  'SHOT on TARGET',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () async {
                  setState(() {
                    eventAction = 'Shot on Target'; // Update the event action
                  });

                  // Set the properties in the ChangeNotifier
                  saveActionProvider.setEventAction(eventAction);
                  saveActionProvider.setMatchCode(
                      matchStatsProvider.matchCode); // Set match code
                  saveActionProvider.setTeamCode(
                      matchStatsProvider.teamCode); // Set team code
                  saveActionProvider
                      .setMatchEventTime(matchEventTime); // Set event time
                  saveActionProvider
                      .setSelectedPlayer(selectedPlayer); // Set selected player
                  saveActionProvider
                      .setMatchHalf(matchHalf); // or 'second_half', as needed

                  // Call saveAction to save the action to Supabase
                  await saveActionProvider.saveAction();

                  const BasicMatchPageV3();
                },
              ),

              // button 3
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black),
                child: const Text(
                  'PEN SCORED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () async {
                  // Access the MatchStats provider
                  final matchStats =
                      Provider.of<SelectedMatchStats>(context, listen: false);

                  // Update team score and set event action
                  matchStats.teamScore++;
                  eventAction = 'Penalty Scored';

                  // Set the properties in the ChangeNotifier
                  saveActionProvider.setEventAction(eventAction);
                  saveActionProvider.setMatchCode(
                      matchStatsProvider.matchCode); // Set match code
                  saveActionProvider.setTeamCode(
                      matchStatsProvider.teamCode); // Set team code
                  saveActionProvider
                      .setMatchEventTime(matchEventTime); // Set event time
                  saveActionProvider
                      .setSelectedPlayer(selectedPlayer); // Set selected player
                  saveActionProvider
                      .setMatchHalf(matchHalf); // or 'second_half', as needed

                  // Save the action to Supabase and ensure it's done before proceeding
                  await saveActionProvider.saveAction().then((_) {
                    Navigator.pop(context); // Close the dialog
                    _showGoalAlert(
                        context); // Show the goal alert after closing the dialog
                  }).catchError((error) {
                    // Handle error if saving to Supabase fail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving action: $error')),
                    );

                    const BasicMatchPageV3();
                  });
                },
              ),

              // button 4
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text(
                  'PEN MISSED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () async {
                  setState(() {
                    eventAction = 'Penalty Missed';
                  });

                  // Set the properties in the ChangeNotifier
                  saveActionProvider.setEventAction(eventAction);
                  saveActionProvider.setMatchCode(
                      matchStatsProvider.matchCode); // Set match code
                  saveActionProvider.setTeamCode(
                      matchStatsProvider.teamCode); // Set team code
                  saveActionProvider
                      .setMatchEventTime(matchEventTime); // Set event time
                  saveActionProvider
                      .setSelectedPlayer(selectedPlayer); // Set selected player
                  saveActionProvider
                      .setMatchHalf(matchHalf); // or 'second_half', as needed

                  // Call saveAction to save the action to Supabase
                  await saveActionProvider.saveAction();

                  const BasicMatchPageV3();
                },
              ),

              // button 5
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: const Text(
                  'PEN SAVED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                onPressed: () async {
                  setState(() {
                    eventAction = 'Penalty Saved';
                  });

                  // Set the properties in the ChangeNotifier
                  saveActionProvider.setEventAction(eventAction);
                  saveActionProvider.setMatchCode(
                      matchStatsProvider.matchCode); // Set match code
                  saveActionProvider.setTeamCode(
                      matchStatsProvider.teamCode); // Set team code
                  saveActionProvider
                      .setMatchEventTime(matchEventTime); // Set event time
                  saveActionProvider
                      .setSelectedPlayer(selectedPlayer); // Set selected player
                  saveActionProvider
                      .setMatchHalf(matchHalf); // or 'second_half', as needed

                  // Call saveAction to save the action to Supabase
                  await saveActionProvider.saveAction();

                  const BasicMatchPageV3();
                },
              ),

              // button 6
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black),
                  child: const Text(
                    'GOAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                  onPressed: () async {
                    // Access the MatchStats provider
                    final matchStats =
                        Provider.of<SelectedMatchStats>(context, listen: false);

                    // Update opponent score and set event action
                    matchStats.teamScore++;
                    eventAction = 'Goal';

                    // Set the properties in the ChangeNotifier
                    saveActionProvider.setEventAction(eventAction);
                    saveActionProvider.setMatchCode(
                        matchStatsProvider.matchCode); // Set match code
                    saveActionProvider.setTeamCode(
                        matchStatsProvider.teamCode); // Set team code
                    saveActionProvider
                        .setMatchEventTime(matchEventTime); // Set event time
                    saveActionProvider.setSelectedPlayer(
                        selectedPlayer); // Set selected player
                    saveActionProvider
                        .setMatchHalf(matchHalf); // or 'second_half', as needed

                    // Call saveAction to save the action to Supabase
                    await saveActionProvider.saveAction().then((_) {
                      Navigator.pop(context); // Close the dialog
                      _showAssistPopup(
                          context); // Show the goal alert after closing the dialog
                    }).catchError(
                      (error) {
                        // Handle error if saving to Supabase fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error saving action: $error')),
                        );
                      },
                    );
                  }),

              // button 7
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                  child: const Text(
                    'OWN GOAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                  onPressed: () async {
                    // Access the MatchStats provider
                    final matchStats =
                        Provider.of<SelectedMatchStats>(context, listen: false);

                    // Update opponent score and set event action
                    matchStats.oppScore++;
                    eventAction = 'Own Goal';

                    // Notify listeners about the changes
                    // Set the properties in the ChangeNotifier
                    saveActionProvider.setEventAction(eventAction);
                    saveActionProvider.setMatchCode(
                        matchStatsProvider.matchCode); // Set match code
                    saveActionProvider.setTeamCode(
                        matchStatsProvider.teamCode); // Set team code
                    saveActionProvider
                        .setMatchEventTime(matchEventTime); // Set event time
                    saveActionProvider.setSelectedPlayer(
                        selectedPlayer); // Set selected player
                    saveActionProvider
                        .setMatchHalf(matchHalf); // or 'second_half', as needed

                    // Call saveAction to save the action to Supabase
                    await saveActionProvider.saveAction().then((_) {
                      Navigator.pop(context); // Close the dialog
                      _showAssistPopup(
                          context); // Show the goal alert after closing the dialog
                    }).catchError(
                      (error) {
                        // Handle error if saving to Supabase fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error saving action: $error')),
                        );
                      },
                    );
                  }),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  void _showAssistPopup(BuildContext context) {
    final saveActionProvider = Provider.of<SaveActionToSupabase>(context);
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(children: [
            Spacer(),
            Text('Assisted By'),
            Spacer(),
          ]),
          content: SizedBox(
            height: 400,
            width: 300,
            child: Column(children: [
              const SizedBox(height: 5),
              SizedBox(
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
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    playerAssist = player['player_name'];
                                    playerAssistMain = playerAssist;
                                  });
                                });
                          }));
                    }),
              ),
              const SizedBox(height: 10),
              Text(
                playerAssist,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  setState((() {
                    savePlayerGoalstoMain(context);
                    savePlayerAssistToMain(context);
                  }));

                  // Set the properties in the ChangeNotifier
                  saveActionProvider.setEventAction(eventAction);
                  saveActionProvider.setMatchCode(
                      matchStatsProvider.matchCode); // Set match code
                  saveActionProvider.setTeamCode(
                      matchStatsProvider.teamCode); // Set team code
                  saveActionProvider
                      .setMatchEventTime(matchEventTime); // Set event time
                  saveActionProvider
                      .setSelectedPlayer(selectedPlayer); // Set selected player
                  saveActionProvider
                      .setMatchHalf(matchHalf); // or 'second_half', as needed

                  // Call saveAction to save the action to Supabase
                  await saveActionProvider.saveAction();

                  Navigator.pop(context);
                  _showGoalAlert(context);
                },
                child: const Text(
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
