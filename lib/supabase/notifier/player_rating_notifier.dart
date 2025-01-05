import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/coach/match_v3/basic_match_v3.dart';

class Player {
  final String name;
  int tacticalScore;
  int technicalScore;
  int teamworkScore;

  Player({
    required this.name,
    this.tacticalScore = 0,
    this.technicalScore = 0,
    this.teamworkScore = 0,
  });

  // Computed property for player rating
  double get playerRating =>
      ((tacticalScore + technicalScore + teamworkScore) / 3).toDouble();
}

class PlayerRatingNotifier with ChangeNotifier {
  List<Player> selectedPlayers = [];

  bool get hasError => false;

  void setPlayerRatings({required String matchCode}) {
    matchCode = matchCode;
    notifyListeners();
  }

  set matchCodeUpdate(String code) {
    matchCode = code;
    notifyListeners(); // Notify listeners of the change
  }

  // Method to fetch selected players for a match
  Future<void> fetchplayerattendancelist(String matchCode) async {
    try {
      // Simulating fetching data; replace this with your actual database call
      // For example, use Supabase or any other backend service
      final response = await supabase
          .from('event_attendance')
          .select('player_name')
          .eq('match_code', matchCode)
          .isFilter('player_attendance', true);

      selectedPlayers =
          response.map((data) => Player(name: data['player_name'])).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching players: $e');
    }
  }

  // Method to save a specific player's rating
  Future<void> savePlayerRating(String matchCode, Player player) async {
    try {
      // Prepare the data for upsert
      final playerData = {
        'tactical_score': player.tacticalScore,
        'technical_score': player.technicalScore,
        'teamwork_score': player.teamworkScore,
        'player_rating': player.playerRating.toStringAsFixed(2),
      };

      // Perform upsert operation (update if exists, insert if not)
      final response = await supabase
          .from('event_attendance')
          .update(playerData)
          .eq('player_name', player.name)
          .eq('match_code', matchCode);

      if (response.error != null) {
        throw Exception(
            'Error saving player rating: ${response.error.message}');
      }

      debugPrint('Player rating for ${player.name} saved successfully!');
    } catch (e) {
      debugPrint('Error saving player rating: $e');
    }
  }
}
