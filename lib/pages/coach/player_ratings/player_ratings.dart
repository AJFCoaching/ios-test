import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/player_rating_notifier.dart';
import 'package:provider/provider.dart';

import '../match_v3/basic_match_v3.dart';

class PlayerRatingsPage extends StatefulWidget {
  const PlayerRatingsPage({super.key});

  @override
  State<PlayerRatingsPage> createState() => _PlayerRatingsPageState();
}

class _PlayerRatingsPageState extends State<PlayerRatingsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerListProvider =
          Provider.of<PlayerRatingNotifier>(context, listen: false);
      final matchCode = Provider.of<MatchAdd>(context, listen: false).matchCode;

      playerListProvider.fetchplayerattendancelist(matchCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerListProvider = Provider.of<PlayerRatingNotifier>(context);
    final players = playerListProvider.selectedPlayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAYER RATINGS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: players.isEmpty
          ? const Center(
              child: Text('No players selected for this match.'),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5), // Spacing around the container
                  padding: const EdgeInsets.all(8), // Inner padding
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(
                        color: Colors.blue,
                        width: 1.5), // Border color and width
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ), // Show only the player name
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Shrink to fit content
                          children: [
                            Text(
                              player.playerRating.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                width: 10), // Space between rating and button
                            ElevatedButton(
                              onPressed: () async {
                                await playerListProvider.savePlayerRating(
                                    matchCode, player);
                                // Add your desired functionality here
                                print("Button clicked for ${player.name}");
                                print("Button clicked for $matchCode");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // Button color
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text("Add"), // Button label
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height: 5), // Spacing between name and sliders
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildScoreRow(
                              label: 'Tactical',
                              score: player.tacticalScore,
                              onChanged: (value) {
                                setState(() {
                                  player.tacticalScore = value.toInt();
                                });
                              },
                            ),
                            _buildScoreRow(
                              label: 'Technical',
                              score: player.technicalScore,
                              onChanged: (value) {
                                setState(() {
                                  player.technicalScore = value.toInt();
                                });
                              },
                            ),
                            _buildScoreRow(
                              label: 'Teamwork',
                              score: player.teamworkScore,
                              onChanged: (value) {
                                setState(() {
                                  player.teamworkScore = value.toInt();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildScoreRow({
    required String label,
    required int score,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Slider(
          value: score.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          label: score.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
