import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerSwapProvider with ChangeNotifier {
  String matchCode = '';
  String selectedPlayer = '';
  String selectedPlayerPosition = '';
  String selectedSub = '';
  String selectedSubPosition = '';
  Map<String, String> playerPositions =
      {}; // e.g., {'Player1': 'Midfielder', 'Player2': 'Forward'}

  final SupabaseClient supabase = Supabase.instance.client;

  // Set the match code and notify listeners
  void setMatchCode(String selectedMatch) {
    matchCode = selectedMatch;
    notifyListeners();
  }

  // Set the selected player and update their position to null
  Future<void> setSelectedPlayer(String playerName) async {
    selectedPlayer = playerName;
    notifyListeners();

    if (playerName.isNotEmpty) {
      await updatePlayerPositionToSub(playerName);
    }
  }

  // Set the selected player's position
  void setSelectedPlayerPosition(String playerPos) {
    selectedPlayerPosition = playerPos;
    notifyListeners();
  }

  // Set the substitute and update their position
  Future<void> setSelectedSub(String subName) async {
    selectedSub = subName;
    notifyListeners();

    if (subName.isNotEmpty) {
      await updateSubPositionToPlayerPosition(subName, selectedPlayerPosition);
    }
  }

  // Set the substitute's position
  void setSelectedSubPosition(String subPos) {
    selectedSubPosition = subPos;
    notifyListeners();
  }

  /// Update the player's position to the substitute's position (nullifying original position)
  Future<void> updatePlayerPositionToSub(String playerName) async {
    try {
      await supabase
          .from('event_attendance')
          .update({
            'position': selectedSubPosition,
          })
          .eq('match_code', matchCode)
          .eq('player_name', playerName);
      debugPrint('Player position set to substitute\'s position successfully.');
    } catch (e) {
      debugPrint('Error updating player position: $e');
      throw e; // Re-throw for potential UI-level handling
    }
  }

  /// Update the substitute's position to the selected player's position
  Future<void> updateSubPositionToPlayerPosition(
      String subName, String selectedPlayerPosition) async {
    try {
      await supabase
          .from('event_attendance')
          .update({
            'position': selectedPlayerPosition,
          })
          .eq('match_code', matchCode)
          .eq('player_name', subName);
      debugPrint('Substitute\'s position updated successfully.');
    } catch (e) {
      debugPrint('Error updating substitute\'s position: $e');
    }
  }

  /// Fetch substitutes and mark their positions as 'Sub'
  Future<void> fetchSubs(String matchCode) async {
    try {
      final response = await supabase
          .from('event_attendance')
          .select('player_name, position')
          .eq('match_code', matchCode)
          .inFilter(
              'position', ['S1', 'S2', 'S3', 'S4', 'S5']); // Sub positions

      if (response is List) {
        playerPositions = {
          for (var row in response) row['player_name']: row['position'] ?? 'Sub'
        };
        notifyListeners();
      } else {
        throw Exception('Unexpected response: $response');
      }
    } catch (e) {
      debugPrint('Error fetching substitutes: $e');
    }
  }
}
