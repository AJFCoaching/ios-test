import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:matchday/pages/working_on/drag_drop_file/spilt_panels.dart';
import 'package:matchday/pages/normal_pages/login.dart';
import 'package:matchday/pages/normal_pages/onboarding_page.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/match_scorers.dart';
import 'package:matchday/supabase/notifier/next_event.dart';
import 'package:matchday/supabase/notifier/player_positions_notifier.dart';
import 'package:matchday/supabase/notifier/player_rating_notifier.dart';
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
        ChangeNotifierProvider(create: (_) => PlayerRatingNotifier()),
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

class Routes {
//  static const String dragDrop = '/dragDrop';
  static const String loading = '/loading';
  static const String onboarding = '/onboarding';
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
//        Routes.dragDrop: (context) => const SplitPanels(),
        Routes.loading: (context) => const LoadingPage(),
        Routes.onboarding: (context) => const OnboardingPage(),
        Routes.login: (context) => const LogInPage(),
        Routes.home: (context) => const HomePage(),
        Routes.register: (context) =>
            const RegisterPage(), // If you have a register page
      },
    );
  }
}
