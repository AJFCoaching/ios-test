import 'dart:math';
import 'package:flutter/material.dart';
import 'package:matchday/main.dart';

class EventNotifier extends ChangeNotifier {
  String _teamCode = '';
  String _selectedEventType = 'Training'; // Default event type
  String _oppositionName = '';
  String _matchDate = '';
  String _eventDate = '';
  String _matchEventTime = '';
  String _address = '';
  double _addressLat = 0.0;
  double _addressLong = 0.0;
  int _currentTimeValue = 30; // Default match half length
  bool _eventTraining = false; // Training vs match flag
  String _currentSeasonDate = '2024/25'; // Default season date
  DateTime _selectedDate = DateTime.now();

  // Getters
  String get teamCode => _teamCode;
  String get selectedEventType => _selectedEventType;
  String get oppositionName => _oppositionName;
  String get matchDate => _matchDate;
  String get eventDate => _eventDate;
  String get matchEventTime => _matchEventTime;
  String get address => _address;
  double get addressLat => _addressLat;
  double get addressLong => _addressLong;
  int get currentTimeValue => _currentTimeValue;
  bool get eventTraining => _eventTraining;
  String get currentSeasonDate => _currentSeasonDate;
  DateTime get selectedDate => _selectedDate;

  // Setters
  set teamCode(String code) {
    _teamCode = code;
    notifyListeners();
  }

  set selectedEventType(String type) {
    _selectedEventType = type;
    _eventTraining = type == 'Training';
    notifyListeners();
  }

  set oppositionName(String name) {
    _oppositionName = name;
    notifyListeners();
  }

  set matchDate(String date) {
    _matchDate = date;
    notifyListeners();
  }

  set eventDate(String newDate) {
    _eventDate = newDate;
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

  set currentTimeValue(int value) {
    _currentTimeValue = value;
    notifyListeners();
  }

  set currentSeasonDate(String season) {
    _currentSeasonDate = season;
    notifyListeners();
  }

  set selectedDate(DateTime dateTime) {
    _selectedDate = dateTime;
    notifyListeners();
  }

  // Method to set all event data at once
  void setEventData({
    required String teamCode,
    required String matchType,
    required String matchDate,
    required String eventDate,
    required String matchMonth,
    required String oppTeam,
    required String address,
    required double addressLat,
    required double addressLong,
    required String matchEventTime,
    required int matchHalfLength,
    required bool eventTraining,
    required String season,
    required DateTime selectedDate,
  }) {
    this.teamCode = teamCode;
    selectedEventType = matchType;
    this.matchDate = matchDate;
    this.eventDate = eventDate;
    oppositionName = oppTeam;
    this.address = address;
    this.addressLat = addressLat;
    this.addressLong = addressLong;
    this.matchEventTime = matchEventTime;
    currentTimeValue = matchHalfLength;
    currentSeasonDate = season;
    this.selectedDate = selectedDate;
  }

  // Method to save event data to Supabase
  Future<void> saveEventToSupabase({
    required String teamCode,
    required String matchType,
    required String matchDate, // Keep this as DateTime
    required String eventDate,
    required String oppTeam,
    required String address,
    required double addressLat,
    required double addressLong,
    required String matchEventTime,
    required int matchHalfLength,
    required bool eventTraining,
    required String season,
  }) async {
    final String matchCode = _generateMatchCode();

    final updates = {
      'team_code': teamCode,
      'Type': matchType,
      'event_date': matchDate, // Save the formatted date string
      'date': eventDate,
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
      // Save event data to Supabase
      await supabase.from('fixtures').upsert(updates);

      // Fetch players for the given teamCode
      final response = await supabase
          .from('squad')
          .select('player_name')
          .eq('team_code', _teamCode);

      // Prepare attendance data
      List<Map<String, dynamic>> attendanceData = [];
      for (var player in response) {
        attendanceData.add({
          'player_name': player['player_name'],
          'player_attendance': null, // Default attendance status
          'match_code': matchCode,
        });
      }

      // Save attendance data
      await supabase.from('event_attendance').upsert(attendanceData);

      notifyListeners(); // Notify listeners if any UI needs to be updated
    } catch (error) {
      // Handle errors
      throw Exception('Failed to save event data: $error');
    }
  }

  // Randomly generate match code
  String _generateMatchCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
