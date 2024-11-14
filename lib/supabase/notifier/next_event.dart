import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class NextEvent extends ChangeNotifier {
  String _nextEventType = '';
  String _nextEventDate = '';
  String _nextEventTime = '';
  String _nextEventOpp = '';

  bool isLoading = false; // For showing loading state
  bool hasError = false; // For error handling

  // Method to fetch the next event from Supabase
  Future<void> fetchNextEvent(BuildContext context) async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    try {
      isLoading = true;
      notifyListeners();

      final response = await Supabase.instance.client
          .from('fixtures')
          .select()
          .gte('date',
              DateTime.now().toIso8601String()) // Get events from today onward
          .isFilter('completed', false) // Ensure event is not completed
          .eq('team_code', userInfo.teamCode)
          .limit(1)
          .order('date', ascending: true); // Get the nearest event

      if (response.isNotEmpty) {
        final event = response[0];
        _nextEventType = event['Type'] ?? '';
        _nextEventDate = event['event_date'] ?? '';
        _nextEventTime = event['time'] ?? '';
        _nextEventOpp = event['Opp'] ?? '';
      } else {
        // No upcoming event found
        _nextEventType = '';
        _nextEventDate = '';
        _nextEventTime = '';
        _nextEventOpp = '';
      }

      isLoading = false;
      hasError = false;
      notifyListeners(); // Notify listeners after successfully fetching data
    } catch (e) {
      // Handle errors
      isLoading = false;
      hasError = true;
      notifyListeners(); // Notify listeners of the error
      // ignore: avoid_print
      print('Error fetching next event: $e');
    }
  }

  // Getters
  String get nextEventType => _nextEventType;
  String get nextEventDate => _nextEventDate;
  String get nextEventTime => _nextEventTime;
  String get nextEventOpp => _nextEventOpp;

  // Setters
  void setNextEventData({
    required String eventType,
    required String eventDate,
    required String eventTime,
    required String eventOpp,
  }) {
    _nextEventType = eventType;
    _nextEventDate = eventDate;
    _nextEventTime = eventTime;
    _nextEventOpp = eventOpp;
    notifyListeners(); // Notify listeners that the data has changed
  }

  // Reset data
  void resetEvent() {
    _nextEventType = '';
    _nextEventDate = '';
    _nextEventTime = '';
    _nextEventOpp = '';
    notifyListeners();
  }
}
