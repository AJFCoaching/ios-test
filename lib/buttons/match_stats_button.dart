import 'package:flutter/material.dart';
import 'package:matchday/pages/coach/match_stats.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:provider/provider.dart';

class MatchStatsButton extends StatelessWidget {
  const MatchStatsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        // Access the providers before performing actions
        final matchStatsProvider =
            Provider.of<SelectedMatchStats>(context, listen: false);
        final matchDataProvider = Provider.of<MatchAdd>(context, listen: false);

        // Get the matchCode from the MatchAdd provider
        final selectedMatchCode = matchDataProvider.matchCode;

        // Show loading indicator or disable the button if needed
        matchStatsProvider.isLoading = true;
        matchStatsProvider.notifyListeners();

        // Fetch match stats using the selected match code
        await matchStatsProvider.fetchSelectedMatchStats(selectedMatchCode);

        // After successfully fetching the stats, navigate to MatchStatsPage
        if (!matchStatsProvider.hasError) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MatchStatsPage()),
          );
        } else {
          // Handle error case
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching match stats')),
          );
        }

        // Debug: print the match code to confirm it
        // ignore: avoid_print
        print("Match code passed: $selectedMatchCode");
      },
      icon: const Icon(Icons.data_thresholding_outlined, color: Colors.white),
      label: const Text('Match Stats'),
    );
  }
}
