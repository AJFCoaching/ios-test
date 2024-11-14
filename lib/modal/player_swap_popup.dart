import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/player_swap_notifier.dart';
import 'package:provider/provider.dart';

class PlayerSwapPopup extends StatelessWidget {
  const PlayerSwapPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final playerSwapProvider = Provider.of<PlayerSwapProvider>(context);

    return AlertDialog(
        title: const Text(
          'Player Swap',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          height: 500,
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display selected player and sub
                Text(
                  'Selected Player: ${playerSwapProvider.selectedPlayer}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selected Player Position: ${playerSwapProvider.selectedPlayerPosition}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selected Sub: ${playerSwapProvider.selectedSub}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selected Sub Position: ${playerSwapProvider.selectedSubPosition}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Generate buttons dynamically from playerPositions map
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: playerSwapProvider.playerPositions.length,
                  itemBuilder: (context, index) {
                    final playerName =
                        playerSwapProvider.playerPositions.keys.toList()[index];
                    final playerPosition =
                        playerSwapProvider.playerPositions[playerName]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          playerSwapProvider.selectedSubPosition =
                              playerPosition;
                          // Select as player or sub
                          if (playerSwapProvider.selectedPlayer.isEmpty) {
                            playerSwapProvider.selectedPlayerName(playerName);
                          } else {
                            playerSwapProvider.selectedSubName(playerName);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: playerSwapProvider.selectedPlayer ==
                                      playerName ||
                                  playerSwapProvider.selectedSub == playerName
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: Text(
                          '$playerName ($playerPosition)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Swap button
          ElevatedButton(
            onPressed: () async {
              final playerSwapProvider =
                  Provider.of<PlayerSwapProvider>(context, listen: false);

              // Ensure both a player and sub are selected
              if (playerSwapProvider.selectedPlayer.isEmpty ||
                  playerSwapProvider.selectedSub.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please select both a player and a substitute.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Swap their positions

              playerSwapProvider.selectedPlayer = '';
              playerSwapProvider.selectedPlayerPosition = '';
              playerSwapProvider.selectedSub = '';
              playerSwapProvider.selectedSubPosition = '';

              print(playerSwapProvider.selectedPlayer);
              print(playerSwapProvider.selectedPlayerPosition);
              print(playerSwapProvider.selectedSub);
              print(playerSwapProvider.selectedSubPosition);

              await playerSwapProvider.swapPlayerPosition();

              // Close the popup after swapping
              Navigator.pop(context);

              // Optionally, show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Players swapped successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Swap Positions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ]);
  }
}
