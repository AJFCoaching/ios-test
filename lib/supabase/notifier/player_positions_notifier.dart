import 'package:flutter/material.dart';
import 'package:matchday/main.dart';

class PlayerPositionsNotifier with ChangeNotifier {
  String? _matchCode;
  final List<String> positionOrder = [
    'GK',
    'LB',
    'LCB',
    'CB',
    'RCB',
    'RB',
    'LWB',
    'LCDM',
    'CDM',
    'RCDM',
    'RWB',
    'LM',
    'LCM',
    'CM',
    'RCM',
    'RM',
    'LW',
    'LAM',
    'CAM',
    'RAM',
    'RW',
    'LF',
    'LCF',
    'CF',
    'RCF',
    'RF',
    'S1',
    'S2',
    'S3',
    'S4',
    'S5',
  ];

  List<Map<String, dynamic>> _forwards = [];
  List<Map<String, dynamic>> _attackingMidfielders = [];
  List<Map<String, dynamic>> _midfielders = [];
  List<Map<String, dynamic>> _defensiveMidfielders = [];
  List<Map<String, dynamic>> _defenders = [];
  List<Map<String, dynamic>> _goalkeepers = [];
  List<Map<String, dynamic>> _substitutes = [];

  List<Map<String, dynamic>> get forwards => _forwards;
  List<Map<String, dynamic>> get attackingMidfielders => _attackingMidfielders;
  List<Map<String, dynamic>> get midfielders => _midfielders;
  List<Map<String, dynamic>> get defensiveMidfielders => _defensiveMidfielders;
  List<Map<String, dynamic>> get defenders => _defenders;
  List<Map<String, dynamic>> get goalkeepers => _goalkeepers;
  List<Map<String, dynamic>> get substitutes => _substitutes;

  void setMatchCode(String matchCode) {
    _matchCode = matchCode;
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    if (_matchCode == null) return;

    _forwards = await fetchPlayersByPosition(
        _matchCode!, ['LF', 'LCF', 'CF', 'RCF', 'RF']);
    _attackingMidfielders = await fetchPlayersByPosition(
        _matchCode!, ['LW', 'LAM', 'CAM', 'RAM', 'RW']);
    _midfielders = await fetchPlayersByPosition(
        _matchCode!, ['LM', 'LCM', 'CM', 'RCM', 'RM']);
    _defensiveMidfielders = await fetchPlayersByPosition(
        _matchCode!, ['LWB', 'LCDM', 'CDM', 'RCDM', 'RWB']);
    _defenders = await fetchPlayersByPosition(
        _matchCode!, ['LB', 'LCB', 'CB', 'RCB', 'RB']);
    _goalkeepers = await fetchPlayersByPosition(_matchCode!, ['GK']);
    _substitutes = await fetchPlayersByPosition(
        _matchCode!, ['S1', 'S2', 'S3', 'S4', 'S5']);

    notifyListeners(); // Notify listeners to update the UI
  }

  Future<List<Map<String, dynamic>>> fetchPlayersByPosition(
      String matchCode, List<String> positionShorts) async {
    String conditions =
        positionShorts.map((position) => 'position.eq.$position').join(',');

    final response = await supabase
        .from('event_attendance')
        .select()
        .eq('match_code', matchCode)
        .or(conditions);

    List<Map<String, dynamic>> players =
        List<Map<String, dynamic>>.from(response);

    // Sort players based on the predefined position order
    players.sort((a, b) {
      int aIndex = positionOrder.indexOf(a['position']);
      int bIndex = positionOrder.indexOf(b['position']);
      return aIndex.compareTo(bIndex);
    });

    return players;
  }
}
