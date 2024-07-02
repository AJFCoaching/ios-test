import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:matchday/modal/add_old_match.dart';
import 'package:matchday/main.dart';
import 'package:latlong2/latlong.dart';
import 'package:matchday/pages/coach/attendance.dart';
import 'package:matchday/pages/coach/basic_match_v2.dart';
import 'package:matchday/pages/coach/completed_match.dart';
import 'package:matchday/pages/normal_pages/home_page.dart';
import 'package:matchday/supabase.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDataPage extends StatefulWidget {
  const EventDataPage({Key? key}) : super(key: key);

  @override
  State<EventDataPage> createState() => _EventDataPageState();
}

class _EventDataPageState extends State<EventDataPage> {
  late Future<List<Map<String, dynamic>>> _attendanceStatusFuture;

  final matchPlayerList = Supabase.instance.client
      .from('match_actions')
      .select()
      .eq('match_code', matchCode)
      .order('minute', ascending: false);

  final matchEventList = supabase
      .from('match_actions')
      .select()
      .eq('match_code', matchCode)
      .order('minute', ascending: false);

  final ScreenshotController screenshotController = ScreenshotController();

  Future<List<Map<String, dynamic>>> _fetchAttendanceStatus() async {
    final response = await supabase
        .from('event_attendance')
        .select()
        .eq('match_code', matchCode);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  void initState() {
    super.initState();
    _attendanceStatusFuture = _fetchAttendanceStatus();
  }

  Widget buildEventDetails() {
    return Column(
      children: [
        SizedBox(height: 5),
        firstRow(),
        SizedBox(height: 5),
        secondRow(),
        SizedBox(height: 5),
        thirdRow(),
        SizedBox(height: 5),
        mapContainer(),
        SizedBox(height: 5),
        addressRow(),
        SizedBox(height: 10),
        AttendanceButton(),
        SizedBox(height: 10),
        if (!EventTraining && completedEvent) addMatchEventButton(),
        if (!EventTraining) matchStatsData(),
        if (EventTraining) playerAttendance(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EVENT DETAILS'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final image = await screenshotController
                  .captureFromWidget(matchStatsData());
              Share.shareXFiles([XFile.fromData(image, mimeType: "png")]);
            },
          ),
        ],
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: buildEventDetails(),
      bottomNavigationBar: bottmnavbar(),
    );
  }

  Widget firstRow() {
    return Row(children: [
      SizedBox(width: 10),
      Text(
        'EVENT - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 70),
      Text(eventType,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget secondRow() {
    return Row(children: [
      SizedBox(width: 10),
      Text(
        'OPPOSITION - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 40),
      Text(oppTeam,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget thirdRow() {
    return Row(children: [
      SizedBox(width: 10),
      Text(
        'DATE - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 20),
      Text(matchDate,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Spacer(),
      Text(
        'START/KO TIME - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 20),
      Text(
        matchEventTime,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Spacer(),
    ]);
  }

  Widget mapContainer() {
    return Container(
      width: double.infinity, // Set width to match the screen
      height: 200.0, // Set height to 150
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.amber, // Set the background color to amber
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(addresslat, addresslong),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          )
        ],
      ),
    );
  }

  Widget addressRow() {
    return Row(
      children: [
        SizedBox(width: 10),
        Text(
          'ADDRESS - ',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Container(
          width: 275,
          child: Text(
            eventAddress,
            maxLines: 3,
            overflow: TextOverflow.clip,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Spacer(),
      ],
    );
  }

  Widget matchStatsData() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataFromFixtureStatsTable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Column(children: [
                  teamNames(),
                  SizedBox(height: 10),

                  // Score
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        teamScore.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Spacer(),
                      Text('GOALS'),
                      Spacer(),
                      Text(
                        oppScore.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),

                  SizedBox(height: 10),
                  // shot on Target
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        item['teamOnTarget'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Spacer(),
                      Text('SHOT ON TARGET'),
                      Spacer(),
                      Text(
                        item['oppOnTarget'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),

                  SizedBox(height: 10),
                  // shot off Target
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        item['teamOffTarget'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Spacer(),
                      Text('SHOT OFF TARGET'),
                      Spacer(),
                      Text(
                        item['oppOffTarget'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),

                  SizedBox(height: 10),
                  // passes
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        item['teamPass'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Spacer(),
                      Text('PASSES'),
                      Spacer(),
                      Text(
                        item['oppPass'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),

                  SizedBox(height: 10),
                  // Tackles
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        item['teamTackle'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Spacer(),
                      Text('TACKLES'),
                      Spacer(),
                      Text(
                        item['oppTackle'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),

                  SizedBox(height: 10),
                  // shot on Target
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        item['teamOffside'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Spacer(),
                      Text('OFFSIDES'),
                      Spacer(),
                      Text(
                        item['oppOffside'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 10),
                ]);
              },
            );
          }
        },
      ),
    );
  }

  Widget playerAttendance() {
    return DefaultTabController(
      length: 2,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white, // Background color for the container
              padding: EdgeInsets.all(5.0), // Padding around the TabBar
              child: TabBar(
                tabs: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5), // Padding within each tab
                    child:
                        Icon(Icons.check_circle_outline, color: Colors.green),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5), // Padding within each tab
                    child: Icon(Icons.cancel_outlined, color: Colors.red),
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
            Container(
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
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

                  final attending = attendanceStatus
                      .where((player) => player['player_attendance'] == true)
                      .toList();
                  final notAttending = attendanceStatus
                      .where((player) => player['player_attendance'] == false)
                      .toList();

                  return Expanded(
                    child: TabBarView(
                      children: [
                        _buildPlayerList(attending),
                        _buildPlayerList(notAttending),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget teamNames() {
    return Row(
      children: [
        SizedBox(width: 10),
        Text(
          teamName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Spacer(),
        Text(
          oppTeam,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget goalscorers() {
    return Container(
      child: Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: matchPlayerList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final players = snapshot.data!;
            return ListView.builder(
              itemCount: players.length,
              itemBuilder: ((context, index) {
                final player = players[index];
                return Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(player['minute']),
                        SizedBox(width: 15),
                        Text(player['half']),
                        SizedBox(width: 15),
                        Text(player['action']),
                        Spacer(),
                        Text(player['player']),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget AttendanceButton() {
    return Container(
      child: Row(
        children: [
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendancePage()),
              );
            },
            icon: Icon(Icons.person_add_alt_1),
            label: Text('Attendance'),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget addMatchEventButton() {
    return Container(
      child: Row(
        children: [
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddPreviousMatchDataPage()),
              );
              setState(() {
                prevEventAction = '';
                prevEventPlayerAssistSelect = '';
                prevEventPlayerSelect = '';
                prevEventHalf = '1st Half'.toString();
              });
            },
            icon: Icon(Icons.person_add),
            label: Text('Add Match Actions'),
          ),
          Spacer(),
        ],
      ),
    );
  }
// add event actions list

  Widget bottmnavbar() {
    if (completedEvent == false && EventTraining == false)
      return Container(
        height: 65,
        color: Colors.black12,
        child: Row(children: [
          // button 1
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: InkWell(
              onTap: () {
                setState(() {
                  teamcounter = 0;
                  oppcounter = 0;
                  teamPass = 0;
                  oppPass = 0;
                  teamTackle = 0;
                  oppTackle = 0;
                  teamShotOn = 0;
                  oppShotOn = 0;
                  teamShotOff = 0;
                  oppShotOff = 0;
                  teamOffside = 0;
                  oppOffside = 0;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BasicMatchPageV2()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Icon(Icons.sports_soccer, color: Colors.green),
                    Text('GO TO MATCH'),
                  ],
                ),
              ),
            ),
          ),

          // button 2
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompletedMatchPage()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Icon(Icons.sports_soccer, color: Colors.red),
                    Text('COMPLETED'),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );
    else
      return Container(height: 0);
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> players) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final playerName = players[index]['player_name'] as String;

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
          ),
        );
      },
    );
  }
}
