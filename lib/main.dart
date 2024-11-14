import 'dart:async';
import 'package:flutter/material.dart';
import 'package:matchday/pages/normal_pages/login.dart';
import 'package:matchday/supabase/notifier/match_scorers.dart';
import 'package:matchday/supabase/notifier/next_event.dart';
import 'package:matchday/supabase/notifier/player_positions_notifier.dart';
import 'package:matchday/supabase/notifier/player_swap_notifier.dart';
import 'package:matchday/supabase/notifier/save_event.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/save_match_action.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pages/normal_pages/loading_page.dart';
import 'pages/normal_pages/home_page.dart';
import 'pages/normal_pages/register.dart'; // Assuming register page exists in pages directory

final storage = FlutterSecureStorage();
late SupabaseClient supabase;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage and securely store the Supabase anonKey
  final storage = FlutterSecureStorage();
  await storage.write(
      key: 'anonKey',
      value:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkZW9mbHp1amJ3b3huZW5rYXZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg1NjE4NjksImV4cCI6MjAwNDEzNzg2OX0.81efpAChAis2j6k23E1QeaElOYDF8ECB9FItR5fpKuc');

  // Retrieve the stored anonKey
  final anonKey = await storage.read(key: 'anonKey');

  // Initialize Supabase with the securely stored anonKey
  await Supabase.initialize(
    url: 'https://gdeoflzujbwoxnenkave.supabase.co',
    anonKey: anonKey ?? '',
  );

  supabase = Supabase.instance.client;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserInfo()), // Register UserInfo
        ChangeNotifierProvider(
            create: (_) => NextEvent()), // Register NextMatch
        ChangeNotifierProvider(create: (_) => NextEvent()), // NextEvent
        ChangeNotifierProvider(
            create: (_) => MatchAdd()), // MatchAdd ChangeNotifier
        ChangeNotifierProvider(
            create: (_) => SelectedMatchStats()), // MatchStats
        ChangeNotifierProvider(
            create: (context) => SaveActionToSupabase(supabase)),
        ChangeNotifierProvider(create: (context) => MatchScorers()),
        ChangeNotifierProvider(create: (context) => EventNotifier()),
        ChangeNotifierProvider(create: (context) => UserInfo()),
        ChangeNotifierProvider(create: (context) => PlayerPositionsNotifier()),
        ChangeNotifierProvider(create: (_) => PlayerSwapProvider()),
      ],
      child: MyApp(),
    ),
  );
}

bool eventTraining = false;

String matchMonth = '';
String currentSeasonDate = '';
String matchEventTime = '';
String matchHalf = '1st Half';
String eventAction = '';
int matchHalfLength = 0;
String matchResult = '';

int pcTeamWins = 0;
int pcTeamDraws = 0;
int pcTeamLost = 0;

String selectedPlayerMain = '';
String playerAssistMain = '';

// Previous Match Details
String prevEventHalf = '';
String prevEventAction = '';
String prevEventPlayerSelect = '';
String prevEventPlayerAssistSelect = '';
String selectedTeam = '';
int prevTeamScore = 0;
int prevOppScore = 0;

// Player details
String addPlayerName = '';
String playerShort = '';

// Match information
class MatchAdd with ChangeNotifier {
  String _teamCode = '';
  String _matchType = '';
  String _matchDate = '';
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

  // Getters
  String get teamCode => _teamCode;
  String get matchType => _matchType;
  String get matchDate => _matchDate;
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

  // Setters
  void setMatchData({
    required String teamCode,
    required String matchType,
    required String matchDate,
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
  }) {
    _teamCode = teamCode;
    _matchType = matchType;
    _matchDate = matchDate;
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
    notifyListeners(); // Notify all listeners when data changes
  }

  // Method to update fixtureRef
  void updateFixtureRef(String fixtureRef) {
    _matchCode = fixtureRef;
    notifyListeners(); // Notify listeners of the change
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
    _matchHalfLength = 45; // Default half length
    _eventTraining = false;
    _season = '';
    _matchCode = '';

    notifyListeners(); // Notify listeners about the change
  }

  // Reset all match stats
  void updateMatchDataFromEvent(Map<String, dynamic> event) {
    _matchType = event['Type'] ?? '';
    _oppTeam = event['Opp'] ?? '';
    _matchDate = event['event_date'] ?? '';
    _address = event['location'] ?? '';
    _addressLong = event['address_long'] ?? 0.0;
    _addressLat = event['address_lat'] ?? 0.0;

    notifyListeners(); // Notify listeners about the change
  }
}

class Routes {
  static const String loading = '/loading';
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matchday',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: Routes.loading,
      routes: {
        Routes.loading: (context) => const LoadingPage(),
        Routes.login: (context) => const LogInPage(),
        Routes.home: (context) => const HomePage(),
        Routes.register: (context) =>
            const RegisterPage(), // If you have a register page
      },
    );
  }
}
