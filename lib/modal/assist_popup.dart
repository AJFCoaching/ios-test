import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/save_match_action.dart';
import 'package:provider/provider.dart';

class AssistPopup {
  static Future<void> showAssistSelection(
      BuildContext context,
      Future<List<Map<String, dynamic>>> Function(BuildContext) fetchPlayers,
      void Function(BuildContext) showGoalAlert) async {
    final matchActionProvider =
        Provider.of<SaveActionToSupabase>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Spacer(),
              Text('Assist By'),
              Spacer(),
            ],
          ),
          content: SizedBox(
            height: 400,
            width: 300,
            child: Column(
              children: [
                const SizedBox(height: 5),
                SizedBox(
                  height: 300,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchPlayers(context), // Call fetchPlayers
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No players found.'));
                      }
                      final players = snapshot.data!;

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
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
                              player['player_name'], // Display player name
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () {
                              // Update the player assist in the provider
                              matchActionProvider
                                  .setPlayerAssist(player['player_name']);

                              // Optionally show the goal alert
                              showGoalAlert(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<SelectedMatchStats>(
                  builder: (context, matchStats, _) {
                    return Text(
                      matchActionProvider.playerAssist,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    showGoalAlert(context); // Show goal alert
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
