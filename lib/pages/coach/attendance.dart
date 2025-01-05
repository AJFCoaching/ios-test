import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<Map<String, dynamic>>> _attendanceStatusFuture;
  List<Map<String, dynamic>> notConfirmedPlayers = [];
  List<Map<String, dynamic>> attendingPlayers = [];
  List<Map<String, dynamic>> notAttendingPlayers = [];

  @override
  void initState() {
    super.initState();
    _attendanceStatusFuture = _fetchAttendanceStatus();
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceStatus() async {
    final userInfoProvider = Provider.of<UserInfo>(context, listen: false);
    final response = await supabase
        .from('squad')
        .select('player_name, player_short') // Select necessary fields
        .eq('team_code', userInfoProvider.teamCode);

    // Initialize lists
    notConfirmedPlayers = List<Map<String, dynamic>>.from(response);
    return notConfirmedPlayers;
  }

  Future<void> _updateAttendance(
      String playerName, String playerShort, bool attendance) async {
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
    await supabase
        .from('event_attendance')
        .upsert({
          'player_name': playerName,
          'player_short': playerShort,
          'match_code': matchStatsProvider.matchCode,
          'player_attendance': attendance,
        })
        .eq('player_name', playerName)
        .eq('match_code', matchStatsProvider.matchCode);

    // Update state to move player to the appropriate list
    setState(() {
      // Find the player in the notConfirmed list
      final player = notConfirmedPlayers.firstWhere(
          (player) => player['player_name'] == playerName,
          orElse: () => {} // Return an empty map if not found
          );

      // If the player is found, remove them from notConfirmed and move them to the right list
      if (player.isNotEmpty) {
        notConfirmedPlayers.remove(player);
        if (attendance) {
          attendingPlayers.add(player);
        } else {
          notAttendingPlayers.add(player);
        }
      }
    });
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> players) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final playerName = player['player_name'];
        final playerShort = player['player_short'] ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0), // Margin for spacing between tiles
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black, width: 1.0), // Border color and width
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),

          // tile design
          child: ListTile(
            title: Row(
              children: [
                Text(
                  playerName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text('-'),
                const SizedBox(width: 10),
                Text(
                  playerShort,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Wrap(
              spacing: 8.0,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.check_circle_sharp),
                  color: Colors.green,
                  onPressed: () {
                    // Mark player as attending
                    _updateAttendance(playerName, playerShort, true);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  color: Colors.red,
                  onPressed: () {
                    // Mark player as not attending
                    _updateAttendance(playerName, playerShort, false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ATTENDANCE'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.all(5.0),
              child: TabBar(
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0), // Add padding around text
                      child: Text(
                        'Not Confirmed',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0), // Add padding around text
                      child: Text(
                        'Attending',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0), // Add padding around text
                      child: Text(
                        'Not Attending',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _attendanceStatusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return TabBarView(
              children: [
                _buildPlayerList(notConfirmedPlayers), // Not Confirmed tab
                _buildPlayerList(attendingPlayers), // Attending tab
                _buildPlayerList(notAttendingPlayers), // Not Attending tab
              ],
            );
          },
        ),
      ),
    );
  }
}
