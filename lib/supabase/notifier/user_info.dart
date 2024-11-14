// User information - user_info.dart

import 'package:flutter/material.dart';

class UserInfo extends ChangeNotifier {
  String _userID = "";
  String _teamCode = "";
  String _userName = "";
  String _role = "Player";
  String _currentSeasonDate = "2024";
  String _teamName = '';

  // Getters
  String get userID => _userID;
  String get teamCode => _teamCode;
  String get userName => _userName;
  String get role => _role;
  String get currentSeasonDate => _currentSeasonDate;
  String get teamName => _teamName;

  // Setters
  set userID(String id) {
    _userID = id;
    notifyListeners();
  }

  set teamCode(String code) {
    _teamCode = code;
    notifyListeners();
  }

  set userName(String name) {
    _userName = name;
    notifyListeners();
  }

  set role(String userRole) {
    _role = userRole;
    notifyListeners();
  }

  set currentSeasonDate(String season) {
    _currentSeasonDate = season;
    notifyListeners();
  }

  set teamName(String teamName) {
    _teamName = teamName;
    notifyListeners();
  }

  // Method to update user information
  void updateUser({
    required String userID,
    required String teamCode,
    required String userName,
    required String role,
    required String season,
    required String teamName,
  }) {
    _userID = userID;
    _teamCode = teamCode;
    _userName = userName;
    _role = role;
    _currentSeasonDate = season;
    _teamName = teamName;

    notifyListeners();
  }
}
