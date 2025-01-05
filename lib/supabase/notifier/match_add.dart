import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matchday/main.dart';

class MatchAdd with ChangeNotifier {
  String _teamCode = '';
  String _matchType = '';
  String _matchDate = '';
  DateTime _matchDateTime = DateTime.now(); // timestamp
  String _oppTeam = '';
  String _address = '';
  String _postcode = '';
  String _matchEventTime = '';
  double _addressLat = 0.0;
  double _addressLong = 0.0;
  int _matchHalfLength = 45; // Default half length
  bool _eventTraining = false;
  String _season = '';
  String _matchCode = '';
  String _teamScore = '';
  String _oppScore = '';
  int _teamOnTarget = 0;
  int _teamOffTarget = 0;
  int _oppOnTarget = 0;
  int _oppOffTarget = 0;
  int _teamXG = 0;
  int _oppXG = 0;

  // Getters
  String get teamCode => _teamCode;
  String get matchType => _matchType;
  String get formattedDate => _matchDate;
  DateTime get dateTime => _matchDateTime;
  String get oppTeam => _oppTeam;
  String get address => _address;
  String get postcode => _postcode;
  String get matchEventTime => _matchEventTime;
  double get addressLat => _addressLat;
  double get addressLong => _addressLong;
  int get matchHalfLength => _matchHalfLength;
  bool get eventTraining => _eventTraining;
  String get season => _season;
  String get matchCode => _matchCode;
  String get teamScore => _teamScore;
  String get oppScore => _oppScore;
  int get teamOnTarget => _teamOnTarget;
  int get teamOffTarget => _teamOffTarget;
  int get oppOnTarget => _oppOnTarget;
  int get oppOffTarget => _oppOffTarget;
  int get teamXG => _teamXG;
  int get oppXG => _oppXG;

  // Setters
  set teamCode(String code) {
    _teamCode = code;
    notifyListeners();
  }

  set matchType(String type) {
    _matchType = type;
    _eventTraining = type == 'Training';
    notifyListeners();
  }

  set oppName(String oppTeamName) {
    _oppTeam = oppTeamName;
    notifyListeners();
  }

  set matchEventDate(DateTime newDateTime) {
    _matchDateTime = newDateTime;
    notifyListeners();
  }

  set matchEventTime(String time) {
    _matchEventTime = time;
    notifyListeners();
  }

  set address(String address) {
    _address = address;
    notifyListeners();
  }

  set addressLat(double lat) {
    _addressLat = lat;
    notifyListeners();
  }

  set addressLong(double long) {
    _addressLong = long;
    notifyListeners();
  }

  set currentSeasonDate(String season) {
    _season = season;
    notifyListeners();
  }

  set matchHalfLength(int halfLength) {
    matchHalfLength = halfLength;
    notifyListeners();
  }

  set eventTraining(bool training) {
    eventTraining = training;
    notifyListeners();
  }

  void setMatchData({
    required String teamCode,
    required String matchType,
    required String formattedDate,
    required DateTime dateTime,
    required String oppTeam,
    required String address,
    required String postcode,
    required String matchEventTime,
    required double addressLat,
    required double addressLong,
    required int matchHalfLength,
    required bool eventTraining,
    required String season,
    required String matchCode,
    required String teamScore,
    required String oppScore,
    required int teamOnTarget,
    required int teamOffTarget,
    required int oppOnTarget,
    required int oppOffTarget,
    required int teamXG,
    required int oppXG,
  }) {
    _teamCode = teamCode;
    _matchType = matchType;
    _matchDate = formattedDate;
    _matchDateTime = dateTime;
    _oppTeam = oppTeam;
    _address = address;
    _postcode = postcode;
    _matchEventTime = matchEventTime;
    _addressLat = addressLat;
    _addressLong = addressLong;
    _matchHalfLength = matchHalfLength;
    _eventTraining = eventTraining;
    _season = season;
    _matchCode = matchCode;
    _teamScore = teamScore;
    _oppScore = oppScore;
    _teamOnTarget = teamOnTarget;
    _teamOffTarget = teamOffTarget;
    _oppOnTarget = oppOnTarget;
    _oppOffTarget = oppOffTarget;
    _teamXG = teamXG;
    _oppXG = oppXG;
    notifyListeners(); // Notify all listeners when data changes
  }

  set matchDate(String formattedDate) {
    _matchDate = formattedDate;
    notifyListeners();
  }

  // Method to update fixtureRef
  void updateFixtureRef(String fixtureRef) {
    _matchCode = fixtureRef;
    notifyListeners();
  }

  // Reset all match stats
  void resetMatchAdd() {
    _teamCode = '';
    _matchType = '';
    _matchDate = '';
    _oppTeam = '';
    _address = '';
    _postcode = '';
    _matchEventTime = '';
    _addressLat = 0.0;
    _addressLong = 0.0;
    _matchHalfLength = 45;
    _eventTraining = false;
    _season = '';
    _matchCode = '';
    notifyListeners();
  }

  // Update match data from event
  void updateMatchDataFromEvent(Map<String, dynamic> event) {
    _matchType = event['Type'] ?? '';
    _oppTeam = event['Opp'] ?? '';
    _matchDate = event['event_date'] ?? '';
    _matchEventTime = event['time'] ?? '';
    _address = event['location'] ?? '';
    _addressLong = event['address_long'] ?? 0.0;
    _addressLat = event['address_lat'] ?? 0.0;
    notifyListeners();
  }

  // Randomly generate match code
  String _generateMatchCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Method to save event data to Supabase
  Future<void> saveEventToSupabaseFixture() async {
    final String matchCode = _generateMatchCode();
    final updates = {
      'team_code': teamCode,
      'Type': matchType,
      'event_date': _matchDate,
      'date': _matchDateTime.toIso8601String(),
      'Opp': oppTeam,
      'location': address,
      'time': matchEventTime,
      'address_long': addressLong,
      'address_lat': addressLat,
      'match_half_length': matchHalfLength,
      'match_training': eventTraining,
      'fixture_ref': matchCode,
      'season': season,
    };

    try {
      await supabase.from('fixtures').upsert(updates);
      final response = await supabase
          .from('squad')
          .select('player_name')
          .eq('team_code', teamCode);

      List<Map<String, dynamic>> attendanceData = [];
      for (var player in response) {
        attendanceData.add({
          'player_name': player['player_name'],
          'player_attendance': null,
          'match_code': matchCode,
        });
      }
    } catch (e) {
      print('Error saving event to Supabase: $e');
    }
  }

// Save event stats to 'fixture_stats' table in Supabase
  Future<void> saveEventToSupabaseFixtureStats() async {
    final Map<String, dynamic> updateFixtureStats = {
      'Opposition': oppTeam,
      'teamScore': teamScore,
      'oppScore': oppScore,
      'teamOnTarget': teamOnTarget,
      'oppOnTarget': oppOnTarget,
      'teamPass': 0,
      'oppPass': 0,
      'teamTackle': 0,
      'oppTackle': 0,
      'teamOffTarget': teamOffTarget,
      'oppOffTarget': oppOffTarget,
      'teamOffside': 0,
      'oppOffside': 0,
      'fixture_code': matchCode,
      'team_xG': teamXG,
      'opp_xG': oppXG,
      'team_code': teamCode,
    };

    try {
      // Insert the stats into the 'fixture_stats' table
      await supabase.from('fixture_stats').upsert(updateFixtureStats);
      print('Event successfully saved to Supabase.');
    } catch (e) {
      // Log the error for debugging purposes
      print('Error saving event to Supabase: $e');
    }
  }
}
