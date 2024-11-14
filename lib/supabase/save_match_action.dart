import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveActionToSupabase with ChangeNotifier {
  final SupabaseClient supabase;

  // Constructor to initialize SupabaseClient
  SaveActionToSupabase(this.supabase);

  String matchCode = '';
  String teamCode = '';
  String matchEventTime = '';
  String selectedPlayer = '';
  String eventAction = '';
  String matchHalf = '';
  String playerAssist = '';

  // Method to save action to Supabase
  Future<void> saveAction() async {
    final updateAction = {
      'match_code': matchCode,
      'team_code': teamCode,
      'minute': matchEventTime,
      'player': selectedPlayer,
      'action': eventAction,
      'half': matchHalf,
      'assist': playerAssist,
    };

    try {
      await supabase.from('match_actions').upsert(updateAction);
      notifyListeners(); // Notify listeners after saving
    } catch (e) {
      // Handle errors here if necessary
      // ignore: avoid_print
      print('Error saving action: $e');
    }
  }

  // Setters to update properties
  void setMatchCode(String code) {
    matchCode = code;
    notifyListeners();
  }

  void setTeamCode(String tcode) {
    teamCode = tcode;
    notifyListeners();
  }

  void setMatchEventTime(String time) {
    matchEventTime = time;
    notifyListeners();
  }

  void setSelectedPlayer(String player) {
    selectedPlayer = player;
    notifyListeners();
  }

  void setEventAction(String action) {
    eventAction = action;
    notifyListeners();
  }

  void setMatchHalf(String half) {
    matchHalf = half;
    notifyListeners();
  }

  void setPlayerAssist(String assist) {
    playerAssist = assist;
    notifyListeners();
  }
}
