import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/normal_pages/loading_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gdeoflzujbwoxnenkave.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkZW9mbHp1amJ3b3huZW5rYXZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg1NjE4NjksImV4cCI6MjAwNDEzNzg2OX0.81efpAChAis2j6k23E1QeaElOYDF8ECB9FItR5fpKuc',
  );

  runApp(MyApp());
}

double minvalue = 0;

// basic match stats
int teamShotOn = 0;
int oppShotOn = 0;
int teamShotOff = 0;
int oppShotOff = 0;
int teamPass = 0;
int oppPass = 0;
int teamTackle = 0;
int oppTackle = 0;
int teamOffside = 0;
int oppOffside = 0;
double teamXG = 0.0;
double oppXG = 0.0;

int pcTeamWins = 0;
int pcTeamDraws = 0;
int pcTeamLost = 0;

bool matchEventPopup = false;
bool completedEvent = false;
bool EventTraining = true;

String username = '';
String userPassword = '';
String userType = '';
String userEmail = supabase.auth.currentUser!.email.toString();
var userID = supabase.auth.currentUser!.id;

String selectedTeam = 'Non Selected';
String currentSeasonDate = '2024/25';

String nextEventType = '';
String nextEventDate = '';
String nextEventTime = '';
String nextEventOpp = '';

String prevEventPlayerSelect = '';
String prevEventPlayerAssistSelect = '';
String prevEventAction = '';
String prevEventHalf = '';

String oppTeam = '';
String teamCode = '';
String teamName = '';
String matchDate = '';
String listDate = '';
String matchPc = '';
String matchCode = '';
String matchHalf = '1st Half';
String matchType = '';
String matchResult = 'Match Result';
int matcHalfLength = 0;
int matchHalfSeconds = 0;

String matchMonth = '';

int extraTimeLength = 0;
int matchEventMin = 0;

String matchEventTime = '';

String addPlayerName = '';
String eventPlayer = '';
String playerShort = '';
String eventAction = '';

String eventAddress = '';
String eventDate = '';
String eventType = '';

String teamScore = '';
String oppScore = '';

String SelectedPlayer = '';
String PlayerAssist = '';

int teamcounter = 0;

int oppcounter = 0;

String address = '';
double addresslat = 0.0;
double addresslong = 0.0;

bool goalScored = false;
bool oppAction = false;

final supabase = Supabase.instance.client;

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      debugShowCheckedModeBanner: false,
      title: 'Matchday',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingPage(),
    );
  }
}
