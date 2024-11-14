import 'package:flutter/material.dart';
import 'package:matchday/pages/coach/player_list.dart';
import 'package:matchday/pages/coach/register_team.dart';
import 'package:matchday/pages/normal_pages/first_page.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/fixture_page.dart';
import 'package:matchday/pages/normal_pages/event_data.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? nextEvent;

  int _selectedIndex = 0;
  List<Widget> body = [
    const FirstPage(),
    const FixturePage(),
    const TeamPlayerListPage(),
//     const ScoutPage(),
    const RegisterTeamPage(),
    const EventDataPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfo>(context);
    return Scaffold(
      // appbar
      appBar: AppBar(
        title: Text(
          userInfo.teamName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.red,
          child: Image.asset(
            "assets/ktfc_badge.png",
            height: 50,
            width: 50,
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app_rounded), onPressed: () {}),
        ],
      ),

      // main body
      body: Center(
        child: body[_selectedIndex],
      ),

      // bottom nav bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Fixtures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Scout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    readNextMatchData();
  }

  Future<void> readNextMatchData() async {
    var matchResponse = await supabase
        .from('fixtures')
        .select()
        .gte('date', DateTime.now())
        .isFilter('completed', false)
        .limit(1)
        .order('date', ascending: true);
    setState(() {
      nextEvent = matchResponse as Map<String, dynamic>?;
    });
  }
}
