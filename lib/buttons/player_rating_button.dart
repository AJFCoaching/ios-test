import 'package:flutter/material.dart';
import 'package:matchday/pages/coach/player_ratings/player_ratings.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/player_rating_notifier.dart';
import 'package:provider/provider.dart';

class PlayerRatingButton extends StatelessWidget {
  const PlayerRatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      onPressed: () async {
        // Access the providers before performing actions
        final matchDataProvider = Provider.of<MatchAdd>(context, listen: false);
        final playerRatingSave =
            Provider.of<PlayerRatingNotifier>(context, listen: false);

        // Fetch match stats using the selected match code
        playerRatingSave.matchCodeUpdate = matchDataProvider.matchCode;

        // After successfully fetching the stats, navigate to PlayerRatingPage
        if (!playerRatingSave.hasError) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlayerRatingsPage()),
          );
        } else {
          // Handle error case
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching player ratings')),
          );
        }
      },
      icon: const Icon(Icons.star, color: Colors.amber),
      label: const Text('Player Ratings'),
    );
  }
}
