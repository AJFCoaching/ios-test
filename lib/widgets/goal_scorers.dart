import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/match_scorers.dart';
import 'package:provider/provider.dart';

class Goalscorers extends StatelessWidget {
  const Goalscorers({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the MatchScorers provider
    final matchScorersProvider =
        Provider.of<MatchScorers>(context, listen: false);

    return Expanded(
      child: FutureBuilder<void>(
        // Fetch player list via the FutureBuilder
        future: matchScorersProvider.fetchMatchScorersList(context),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors if any
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get the player list from the provider
          final players = matchScorersProvider.matchPlayerList;

          // Handle empty state
          if (players.isEmpty) {
            return const Center(child: Text('No goalscorers available.'));
          }

          // Sort the players list by the 'minute' key in ascending order
          players.sort((a, b) {
            int minuteA = int.tryParse(a['minute'] ?? '0') ?? 0;
            int minuteB = int.tryParse(b['minute'] ?? '0') ?? 0;
            return minuteA.compareTo(minuteB);
          });

          // Display the sorted list of players (goalscorers)
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(player['minute'] ?? 'N/A'),
                    const SizedBox(width: 15),
                    Text(player['half'] ?? 'N/A'),
                    const SizedBox(width: 20),
                    Text(player['action'] ?? 'Goal'),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.sports_soccer,
                          size: 18,
                          color: Colors.black, // Football icon for player
                        ),
                        const SizedBox(width: 5),
                        Text(
                          player['player'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Conditionally display the assist with a handshake icon
                    if (player['assist']?.isNotEmpty ?? false) ...[
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.handshake,
                        size: 18,
                        color: Colors.black, // Handshake icon for assist
                      ),
                      const SizedBox(width: 5),
                      Text(
                        player['assist'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}