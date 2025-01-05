import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Make sure to import Supabase package

class SelectedMatchStats extends ChangeNotifier {
  // Properties for team statistics
  bool isLoading = false;
  bool hasError = false;
  String oppName = '';
  int teamScore = 0;
  int oppScore = 0;
  int teamShotOn = 0;
  int oppShotOn = 0;
  int teamShotOff = 0;
  int oppShotOff = 0;
  double teamXG = 0.0; // Expected Goals for Team
  double oppXG = 0.0; // Expected Goals for Opponent
  String matchCode = ''; // Unique code for the match
  String matchResult = ''; // Result of the match
  bool completedEvent = false;
  bool eventTraining = false;
  Map<String, dynamic>? matchStats;

  // Getters
  String get getOppName => oppName;
  int get getTeamScore => teamScore;
  int get getOppScore => oppScore;
  bool get isMatchCompleted => completedEvent; // Getter for completedEvent
  // Add other getters as needed...

  // Setters
  void setTeamScore(int score) {
    teamScore = score;
    notifyListeners();
  }

  void setOppScore(int score) {
    oppScore = score;
    notifyListeners();
  }

  void setMatchCode(String code) {
    matchCode = code;
    notifyListeners();
  }

  void setMatchResult(String result) {
    matchResult = result;
    notifyListeners();
  }

  void setOppXg(double oppositionXG) {
    oppXG = oppositionXG;
    notifyListeners();
  }

  void setTeamXg(double yourTeamXG) {
    teamXG = yourTeamXG;
    notifyListeners();
  }

  // increase or decrease scores
  void incrementTeamScore() {
    teamScore++;
    notifyListeners(); // Notify listeners of the change
  }

  void decrementTeamScore() {
    teamScore--;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementOppScore() {
    oppScore++;
    notifyListeners(); // Notify listeners of the change
  }

  void decrementOppScore() {
    oppScore--;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementTeamShotOn() {
    teamShotOn++;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementOppShotOn() {
    oppShotOn++;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementTeamShotOff() {
    teamShotOff++;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementOppShotOff() {
    oppShotOff++;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementTeamGoalXG() {
    teamXG += 0.45;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementOppGoalXG() {
    oppXG += 0.45;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementOppShotOffXG() {
    oppXG += 0.15;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementTeamShotOffXG() {
    teamXG += 0.15;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementOppShotOnXG() {
    oppXG += 0.35;
    notifyListeners(); // Notify listeners of the change
  }

  void incrementTeamShotOnXG() {
    teamXG += 0.35;
    notifyListeners(); // Notify listeners of the change
  }

  // Method to save previous fixture data to Supabase
  Future<void> saveMatchResultToSupabase() async {
    final supabase =
        Supabase.instance.client; // Ensure Supabase client is initialized
    try {
      await supabase.from('fixtures').update({
        'ktfc_score': teamScore.toString(),
        'opp_score': oppScore.toString(),
        'final_result': matchResult,
        'completed': true,
      }).eq('fixture_ref', matchCode);

      // Notify success (optional)
    } catch (error) {
      // Handle error appropriately
    }
  }

// save fixture stats
  Future<void> saveMatchStatsToSupabase(BuildContext context) async {
    final userInfo = Provider.of<UserInfo>(context);
    final updates = {
      'fixture_code': matchCode,
      'Opposition': getOppName,
      'teamScore': teamScore,
      'oppScore': oppScore,
      'teamOnTarget': teamShotOn,
      'oppOnTarget': oppShotOn,
      'teamOffTarget': teamShotOff,
      'oppOffTarget': oppShotOff,
      'team_xG': teamXG,
      'opp_xG': oppXG,
      'team_code': userInfo.teamCode,
    };

    await supabase.from('fixture_stats').upsert(updates);
  }

  // Method to mark the match as completed
  void markMatchCompleted(bool isCompleted) {
    completedEvent =
        isCompleted; // You can use the parameter if needed for future logic
    notifyListeners(); // Notify listeners that the state has changed
  }

  // Reset all match statistics to default values
  void resetMatchStats() {
    teamScore = 0;
    oppScore = 0;
    teamShotOn = 0;
    oppShotOn = 0;
    teamShotOff = 0;
    oppShotOff = 0;
    teamXG = 0.0;
    oppXG = 0.0;
    matchResult = '';
    completedEvent = false; // Reset completed status

    notifyListeners(); // Notify listeners that the state has changed
  }

  Future<void> fetchSelectedMatchStats(String matchCode) async {
    final supabase =
        Supabase.instance.client; // Ensure Supabase client is initialized
    try {
      isLoading = true; // Start loading
      notifyListeners(); // Notify listeners that loading has started

      // Fetch match stats from Supabase using the matchCode
      final response = await supabase
          .from('fixture_stats')
          .select()
          .eq('fixture_code', matchCode)
          .single(); // Expect only a single row for the match

      if (response != null) {
        // Update the state with data from the response
        oppName = response['Opposition'] ?? '';
        teamScore = response['teamScore'] ?? 0;
        oppScore = response['oppScore'] ?? 0;
        teamShotOn = response['teamOnTarget'] ?? 0;
        oppShotOn = response['oppOnTarget'] ?? 0;
        teamShotOff = response['teamOffTarget'] ?? 0;
        oppShotOff = response['oppOffTarget'] ?? 0;

        // Convert xG values to double and assign, handling possible null values
        teamXG = double.tryParse(response['team_xG'].toString()) ?? 0.0;
        oppXG = double.tryParse(response['opp_xG'].toString()) ?? 0.0;

        this.matchCode = matchCode; // Save the match code
        hasError = false; // Reset error state
      }
      matchStats = response as Map<String, dynamic>?; // Store the fetched data
    } catch (error) {
      hasError = true; // Set error state on exception
      // Log or handle the error appropriately
      print('Error fetching match stats: $error');
    } finally {
      isLoading = false; // Ensure loading state is reset
      notifyListeners(); // Notify listeners about state change
    }
  }
}
