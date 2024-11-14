import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:provider/provider.dart';

class MatchScorers with ChangeNotifier {
  // Property to hold the fetched player data
  List<dynamic> _matchScorersList = [];

  // Getter for the list of match scorers
  List<dynamic> get matchPlayerList => _matchScorersList;

  // Fetch match player data from Supabase based on matchCode
  Future<void> fetchMatchScorersList(BuildContext context) async {
    // Access the MatchAdd provider to get the current match code
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);

    // Check if matchCode is not null or empty
    if (matchStatsProvider.matchCode.isEmpty) {
      // ignore: avoid_print
      print('Match code is empty. Cannot fetch scorers.');
      return; // Exit early if matchCode is not valid
    }

    try {
      // Fetch data from Supabase
      final response = await supabase
          .from('match_actions')
          .select()
          .eq('match_code', matchStatsProvider.matchCode) // Filter by matchCode
          .eq('action', 'Goal'); // Only fetch goals

      // Check if the response contains data
      if (response.isNotEmpty) {
        _matchScorersList = response as List<dynamic>; // Save fetched data
      } else {
        _matchScorersList = []; // Reset if no data
        // ignore: avoid_print
        print(
            'No scorers found for match code: ${matchStatsProvider.matchCode}');
      }

      // Notify listeners about the change
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching match player list: $e');
      // Handle error if needed
    }
  }
}
