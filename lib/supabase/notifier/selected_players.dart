import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectedPlayers with ChangeNotifier {
  List<Map<String, dynamic>> _players = []; // List to store selected players
  bool _isLoading = false; // Track loading state
  String _errorMessage = ''; // Track error message
  String _selectedPlayerName = ''; // Holds the name of the selected player

  List<Map<String, dynamic>> get players => _players; // Getter for players
  bool get isLoading => _isLoading; // Getter for loading state
  String get errorMessage => _errorMessage; // Getter for error message

  // Fetch players based on attendance and match code
  Future<void> fetchSelectedPlayers(String matchCode) async {
    _isLoading = true; // Set loading state
    notifyListeners(); // Notify listeners for loading state

    try {
      // Fetch player list from Supabase
      final response = await Supabase.instance.client
          .from('event_attendance')
          .select()
          .eq('match_code', matchCode) // Filter by match_code
          .eq('player_attendance', true);

      // Check for errors in response
      _errorMessage = response as String; // Set error message
      _players = []; // Clear players if there's an error
    } catch (error) {
      _errorMessage =
          'Error fetching players: $error'; // Handle unexpected errors
      _players = []; // Clear players on error
    } finally {
      _isLoading = false; // Reset loading state
      notifyListeners(); // Notify listeners of changes
    }
  }

  // Optional: Reset players list and error message
  void resetSelectedPlayers() {
    _players = [];
    _errorMessage = '';
    notifyListeners();
  }

  // Getter for selected player name
  String get selectedPlayerName => _selectedPlayerName;

  // Method to set the selected player
  void setSelectedPlayer(String playerName) {
    _selectedPlayerName = playerName;
    notifyListeners(); // Notify listeners of the change
  }
}
