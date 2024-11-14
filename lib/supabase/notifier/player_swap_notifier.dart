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

  // getter
  void selectedPlayerName(String playerName) {
    selectedPlayer = playerName;

    notifyListeners();
  }

  void selectedPlayerPos(String playerPos) {
    selectedPlayerPosition = playerPos;

    notifyListeners();
  }

  void selectedSubName(String subName) {
    selectedSub = subName;

    notifyListeners();
  }

  void selectedSubPos(String subPos) {
    selectedSubPosition = subPos;

    notifyListeners();
  }

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> swapPlayerPosition() async {
    if (selectedPlayer.isNotEmpty && selectedSub.isNotEmpty) {
      try {
        // Update selected player's position with selectedSub's position
        await supabase.from('event_attendance').update({
          'position': selectedSubPosition,
        }).match({
          'match_code': matchCode,
          'player_name': selectedPlayer,
        });

        // Update selected substitute's position with selectedPlayer's position
        await supabase.from('event_attendance').update({
          'position': selectedPlayerPosition,
        }).match({
          'match_code': matchCode,
          'player_name': selectedSub,
        });

        // Print debug success message
        debugPrint('Player positions swapped successfully.');
      } catch (e) {
        debugPrint('Error swapping positions in Supabase: $e');
      }
    } else {
      debugPrint('Error: Player or Sub not selected.');
    }
  }

  // Swap positions of selectedPlayer and selectedSub
//  Future<void> swapPositions(BuildContext context) async {
//    if (selectedPlayer.isNotEmpty && selectedSub.isNotEmpty) {
//      // Prevent swapping the same player
//      if (selectedPlayer == selectedSub) {
//        debugPrint('Error: Cannot swap the same player.');
//        return;
//      }

//      try {
  // Update positions in Supabase
//        final playerUpdateResponse =
//            await supabase.from('event_attendance').update({
//          'position': selectedSubPosition,
//        }).match({
//          'player_name': selectedPlayer,
//          'match_code': matchCode,
//        });

//        final subUpdateResponse =
//            await supabase.from('event_attendance').update({
//          'position': selectedPlayerPosition,
//        }).match({
//          'player_name': selectedSub,
//          'match_code': matchCode,
//        });

//        if (playerUpdateResponse.error != null ||
//            subUpdateResponse.error != null) {
//          throw Exception(playerUpdateResponse.error?.message ??
//              subUpdateResponse.error?.message);

//        debugPrint('Positions updated successfully in Supabase.');

  // Clear selected players and their positions
//        selectedPlayer = '';
//        selectedPlayerPosition = '';
//        selectedSub = '';
//        selectedSubPosition = '';

  // Notify listeners to update the UI
//        notifyListeners();
//      } catch (e) {
//        debugPrint('Error updating positions in Supabase: $e');
  // Show error feedback to user
//        ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(
//            content: Text('Failed to update positions: $e'),
//            backgroundColor: Colors.red,
//          ),
//        );
//      }
//    } else {
//      debugPrint('Error: Player or Sub not selected.');
//    }
//  }

// Fetch substitutes linked to a specific match from Supabase
  Future<void> fetchSubstitutes(String matchCode) async {
    try {
      final response = await supabase
          .from(
              'event_attendance') // Assuming the table is named 'event_attendance'
          .select('player_name, position') // Adjust columns as needed
          .eq('match_code', matchCode)
          .inFilter('position',
              ['S1', 'S2', 'S3', 'S4', 'S5']); // Substitute positions

      // Parse response data
      if (response is List) {
        playerPositions = {
          for (var row in response)
            row['player_name']: row['position'] ?? 'Unknown'
        };
      } else {
        throw Exception('Unexpected response: $response');
      }
    } catch (e) {
      debugPrint('Error fetching substitutes: $e');
    }
  }
}
