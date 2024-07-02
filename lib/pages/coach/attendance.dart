import 'package:flutter/material.dart';
import 'package:matchday/main.dart'; // Assuming supabase instance is imported from main.dart

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<Map<String, dynamic>>> _attendanceStatusFuture;

  @override
  void initState() {
    super.initState();
    _attendanceStatusFuture = _fetchAttendanceStatus();
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceStatus() async {
    final response = await supabase
        .from('event_attendance')
        .select()
        .eq('match_code', matchCode);

    print('Match Code: $matchCode');
    print('Response: $response'); // Print response data to see its structure

    return List<Map<String, dynamic>>.from(response);
  }

  Color _getAttendanceColor(bool? playerAttendance) {
    if (playerAttendance == null) return Colors.black;
    return playerAttendance ? Colors.green : Colors.red;
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> players) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final playerName = players[index]['player_name'] as String;
        final playerAttendance = players[index]['player_attendance'] as bool?;
        _getAttendanceColor(playerAttendance);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: ListTile(
            title: Text(
              playerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            trailing: Wrap(
              spacing: 2,
              children: [
                IconButton(
                  onPressed: () {
                    _updateAttendance(playerName, true);
                  },
                  icon: Icon(Icons.person_add),
                  color: playerAttendance == true ? Colors.green : Colors.black,
                ),
                IconButton(
                  onPressed: () {
                    _updateAttendance(playerName, false);
                  },
                  icon: Icon(Icons.not_interested),
                  color: playerAttendance == false ? Colors.red : Colors.black,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateAttendance(String playerName, bool attendance) async {
    await supabase
        .from('event_attendance')
        .update({'player_attendance': attendance})
        .eq('player_name', playerName)
        .eq('match_code', matchCode);
    setState(() {
      _attendanceStatusFuture = _fetchAttendanceStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ATTENDANCE'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
                60.0), // Set the height you want for the container
            child: Container(
              color: Colors.white, // Background color for the container
              padding: EdgeInsets.all(5.0), // Padding around the TabBar
              child: TabBar(
                tabs: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5), // Padding within each tab
                    child: Text('Not Confirmed'),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5), // Padding within each tab
                    child: Text('Attending'),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5), // Padding within each tab
                    child: Text('Not Attending'),
                  ),
                ],
                indicatorColor: Colors.white, // Color of the tab indicator
                labelColor: Colors.white, // Color of the selected tab label
                unselectedLabelColor:
                    Colors.black, // Color of the unselected tab labels
                indicator: BoxDecoration(
                  color:
                      Colors.blueAccent, // Background color of the selected tab
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
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final List<Map<String, dynamic>> attendanceStatus =
                snapshot.data ?? [];

            final notConfirmed = attendanceStatus
                .where((player) => player['player_attendance'] == null)
                .toList();
            final attending = attendanceStatus
                .where((player) => player['player_attendance'] == true)
                .toList();
            final notAttending = attendanceStatus
                .where((player) => player['player_attendance'] == false)
                .toList();

            return TabBarView(
              children: [
                _buildPlayerList(notConfirmed),
                _buildPlayerList(attending),
                _buildPlayerList(notAttending),
              ],
            );
          },
        ),
      ),
    );
  }
}
