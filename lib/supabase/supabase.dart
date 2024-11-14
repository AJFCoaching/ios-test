import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matchday/main.dart';

// save old event data
Future<void> savePlayerDataToSupabase() async {
  final matchActionUpdates = {
    'half': '',
    'minute': '',
    'action': '',
    'player': '',
    'assist': '',
  };
  await supabase.from('match_actions').upsert(matchActionUpdates);
}

//final oldActionPlayer = Supabase.instance.client
//    .from('squad')
//    .select('player_name')
//    .eq('team_code', teamCode);

// add player attandance
Future<void> savePlayerAttendance(BuildContext context) async {
  final userInfo = Provider.of<UserInfo>(context, listen: false);
  final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);

  final saveAttendance = {
    'match_code': matchStatsProvider.matchCode,
    'player_name': selectedPlayerMain,
    'player_attendance': '',
    'goal': 0,
    'assist': 0,
    'team_code': userInfo.teamCode,
  };
  await supabase.from('event_attendance').upsert(saveAttendance);
}

// add player goals to squad table
Future<void> savePlayerGoalstoMain(BuildContext context) async {
  final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
  final playerGoal = supabase.from('event_attendance');

  // Fetch the current player_goals value for the selected player
  final response = await playerGoal.select('goal').match({
    'player_short': selectedPlayerMain,
    'match_code': matchStatsProvider.matchCode,
    'player_attendance': true,
  });

  final currentGoals = response[0]['goal'];

  // Increment the player_goals value by 1
  final updatedGoals = currentGoals + (1);

  // Update the player_goals value in the table for the selected player
  await playerGoal.update({'goal': updatedGoals}).match({
    'player_name': selectedPlayerMain,
    'match_code': matchStatsProvider.matchCode,
    'player_attendance': true,
  });
}

// add player assist to squad table
Future<void> savePlayerAssistToMain(BuildContext context) async {
  final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
  final playerAssist = supabase.from('event_attendance');

  // Fetch the current player_goals value for the selected player
  final response = await playerAssist.select('assist').match({
    'player_name': playerAssistMain,
    'match_code': matchStatsProvider.matchCode,
    'player_attendance': true,
  });

  final currentAssists = response[0]['assist'];

  // Increment the player_goals value by 1
  final updatedAssists = currentAssists + (1);

  // Update the player_goals value in the table for the selected player
  await playerAssist.update({'assist': updatedAssists}).match({
    'player_name': playerAssistMain,
    'match_code': matchStatsProvider.matchCode,
    'player_attendance': true,
  });
}

// team wins
Future<int> countWinOccurrences(BuildContext context) async {
  final userInfo = Provider.of<UserInfo>(context, listen: false);
  final squadTable = supabase.from('fixtures');

  final response = await squadTable
      .select(
          'final_result') // Replace `column_name` with the actual column name
      .eq('team_code', userInfo.teamCode)
      .like('final_result',
          '%Win%'); // Replace `column_name` with the actual column name

  final winOccurrences = response.length;
  return winOccurrences;
}

// team draws
Future<int> countDrawOccurrences(BuildContext context) async {
  final userInfo = Provider.of<UserInfo>(context, listen: false);
  final squadTable = supabase.from('fixtures');

  final response = await squadTable
      .select(
          'final_result') // Replace `column_name` with the actual column name
      .eq('team_code', userInfo.teamCode)
      .like('final_result',
          '%Draw%'); // Replace `column_name` with the actual column name

  final drawOccurrences = response.length;
  return drawOccurrences;
}

// team lost
Future<int> countLostOccurrences(BuildContext context) async {
  final userInfo = Provider.of<UserInfo>(context, listen: false);
  final squadTable = supabase.from('fixtures');

  final response = await squadTable
      .select(
          'final_result') // Replace `column_name` with the actual column name
      .eq('team_code', userInfo.teamCode)
      .like('final_result',
          '%Lost%'); // Replace `column_name` with the actual column name

  final lostOccurrences = response.length;
  return lostOccurrences;
}

// match data
Future<List<Map<String, dynamic>>> fetchDataFromFixtureStatsTable(
    BuildContext context) async {
  final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
  final response = await supabase
      .from('fixture_stats') // Replace with your different table name
      .select()
      .eq('fixture_code', matchStatsProvider.matchCode);

  return List<Map<String, dynamic>>.from(response);
}

// fetch players for assist
Future<List<Map<String, dynamic>>> fetchPlayers(BuildContext context) async {
  final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
  try {
    // Make sure you have the correct table and field names
    final response = await supabase
        .from('event_attendance') // Replace with your actual table name
        .select(
            'player_name , player_short') // You can select other fields as necessary
        .eq(
            'match_code',
            matchStatsProvider
                .matchCode) // Ensure you filter based on your logic
        .eq('player_attendance', true)
        .order(
            'player_name'); // Optional: Order by player name or another field

    // Convert response to List<Map<String, dynamic>> if necessary
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return []; // Return an empty list on error
  }
}

// Player Stats page
// Function to fetch player stats (goals, shots on target, shots off target) and attendance count
Future<List<Map<String, dynamic>>> fetchPlayerStatsAndAttendance() async {
  final supabase = Supabase.instance.client;

  try {
    // Step 1: Fetch player stats from match_actions with OR condition for actions
    final matchActionsResponse = await supabase
        .from('match_actions')
        .select('player, action')
        .or('action.eq.Goal,action.eq.Shot on Target,action.eq.Shot off Target');

    // Step 2: Fetch player attendances from event_attendance
    final attendanceResponse = await supabase
        .from('event_attendance')
        .select('player_name, player_short') // Get full and short names
        .eq('player_attendance', true);

    // Step 3: Convert the responses to lists
    final List<dynamic> matchActions = matchActionsResponse;
    final List<dynamic> playerAttendances = attendanceResponse;

    // Step 4: Create a map to store the short-to-full name mapping
    final Map<String, String> shortToFullNameMap = {};

    // Populate the map with player_short as the key and player_name as the value
    for (var record in playerAttendances) {
      final shortName = record['player_short'];
      final fullName = record['player_name'];
      shortToFullNameMap[shortName] = fullName;
    }

    // Step 5: Create a map to accumulate stats and attendance for each player
    final Map<String, Map<String, dynamic>> playerStats = {};

    // Step 6: Process match actions to accumulate goals, shots on target, shots off target
    for (var record in matchActions) {
      var playerName = record['player'];
      final playerAction = record['action'];

      // Check if player name is a short name and replace with full name
      if (shortToFullNameMap.containsKey(playerName)) {
        playerName = shortToFullNameMap[playerName]!;
      }

      if (!playerStats.containsKey(playerName)) {
        // Initialize player stats
        playerStats[playerName] = {
          'player': playerName, // Use the full player name
          'goals': 0,
          'shotsOnTarget': 0,
          'shotsOffTarget': 0,
          'attendanceCount': 0, // Will be updated later
        };
      }

      // Increment stats based on action
      switch (playerAction) {
        case 'Goal':
          playerStats[playerName]!['goals'] += 1;
          break;
        case 'Shot on Target':
          playerStats[playerName]!['shotsOnTarget'] += 1;
          break;
        case 'Shot off Target':
          playerStats[playerName]!['shotsOffTarget'] += 1;
          break;
      }
    }

    // Step 7: Process attendances to accumulate attendance count
    final Map<String, int> attendanceMap = {};

    for (var record in playerAttendances) {
      final fullName = record['player_name'];

      if (attendanceMap.containsKey(fullName)) {
        attendanceMap[fullName] = attendanceMap[fullName]! + 1;
      } else {
        attendanceMap[fullName] = 1;
      }
    }

    // Step 8: Combine the attendance count with the stats
    attendanceMap.forEach((playerName, count) {
      if (playerStats.containsKey(playerName)) {
        playerStats[playerName]!['attendanceCount'] = count;
      } else {
        // In case there are players who only have attendance but no match actions
        playerStats[playerName] = {
          'player': playerName,
          'goals': 0,
          'shotsOnTarget': 0,
          'shotsOffTarget': 0,
          'attendanceCount': count,
        };
      }
    });

    // Step 9: Convert the stats map to a list for display
    return playerStats.values.toList();
  } catch (e) {
    return [];
  }
}
