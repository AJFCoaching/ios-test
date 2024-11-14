import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:matchday/main.dart';
import 'package:latlong2/latlong.dart';
import 'package:matchday/pages/coach/attendance.dart';
import 'package:matchday/pages/coach/match_v3/basic_match_v3.dart';
import 'package:matchday/pages/coach/completed_match.dart';
import 'package:matchday/pages/coach/match_stats.dart';
import 'package:matchday/pages/coach/player_positions.dart';
import 'package:matchday/pages/normal_pages/home_page.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDataPage extends StatefulWidget {
  const EventDataPage({super.key});

  @override
  State<EventDataPage> createState() => _EventDataPageState();
}

class _EventDataPageState extends State<EventDataPage> {
  // Variables to store fetched data
  dynamic matchPlayerList;
  dynamic matchEventList;
  MatchAdd? matchStatsProvider;

  @override
  void initState() {
    super.initState();

    // Fetch match stats and data in initState
    matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);

    // Fetch the data from Supabase asynchronously
    fetchMatchData();
  }

  Future<void> fetchMatchData() async {
    // Fetch match players and event data from Supabase
    try {
      final playerResponse = await Supabase.instance.client
          .from('match_actions')
          .select()
          .eq(
              'match_code',
              matchStatsProvider!
                  .matchCode) // Use the match code from the provider
          .order('half', ascending: true)
          .order('minute', ascending: false);

      final eventResponse = await Supabase.instance.client
          .from('match_actions')
          .select()
          .eq('match_code', matchStatsProvider!.matchCode)
          .order('minute', ascending: false);

      // Update state with the fetched data
      setState(() {
        matchPlayerList = playerResponse;
        matchEventList = eventResponse;
      });
    } catch (error) {
      // Handle any errors here (e.g., display an error message)
      print("Error fetching data: $error");
    }
  }

  void _completedMatch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return const CompletedMatchModal();
      },
    );
  }

  Widget buildEventDetails() {
    return Column(
      children: [
        const SizedBox(height: 15),
        eventDetails(),
        const SizedBox(height: 15),
        mapContainer(),
        const SizedBox(height: 15),
        addressRow(context),
        const SizedBox(height: 15),
        Row(children: [
          const Spacer(),
          attendanceButton(),
          const SizedBox(width: 10),
          positionsButton(),
          const Spacer(),
        ]),
        const SizedBox(height: 15),
        matchStatsButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVENT DETAILS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage()),
            );
          },
        ),
      ),
      body: buildEventDetails(),
      bottomNavigationBar: bottomNavbar(context),
    );
  }

  Widget eventDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: Colors.black, // Black border
            width: 2.0, // Border thickness
          ),
        ),
        child: Column(children: [
          const SizedBox(height: 5),
          firstRow(context),
          const Spacer(),
          secondRow(context),
          const Spacer(),
          thirdRow(context),
          const Spacer(),
        ]),
      ),
    );
  }

  Widget firstRow(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    return Row(children: [
      const SizedBox(width: 10),
      const Text(
        'EVENT - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 70),
      Text(matchData.matchType,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget secondRow(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    return Row(children: [
      const SizedBox(width: 10),
      const Text(
        'OPPOSITION - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 40),
      Text(matchData.oppTeam,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget thirdRow(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    return Row(children: [
      const SizedBox(width: 10),
      const Text(
        'DATE - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 20),
      Text(matchData.matchDate,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Spacer(),
      const Text(
        'START/KO TIME - ',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 20),
      Text(
        matchEventTime,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const Spacer(),
    ]);
  }

  Widget mapContainer() {
    final matchData = Provider.of<MatchAdd>(context);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // Black border
              width: 2.0, // Border thickness
            ),
          ),
          child: FlutterMap(
            options: MapOptions(
              initialCenter:
                  LatLng(matchData.addressLat, matchData.addressLong),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              )
            ],
          ),
        ));
  }

  Widget addressRow(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: Colors.black, // Black border
            width: 2.0, // Border thickness
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Text(
              'ADDRESS - ',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SizedBox(
              width: 275,
              child: Text(
                matchData.address,
                maxLines: 3,
                overflow: TextOverflow.clip,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget teamNames(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    final userInfo = Provider.of<UserInfo>(context);
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          userInfo.teamName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const Spacer(),
        Text(
          matchData.oppTeam,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget attendanceButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AttendancePage()),
        );
      },
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Attendance'),
    );
  }

  Widget positionsButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlayerPositionsPage()),
        );
      },
      icon: const Icon(Icons.groups),
      label: const Text('Positions'),
    );
  }

  Widget matchStatsButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        // Access the providers before performing actions
        final matchStatsProvider =
            Provider.of<SelectedMatchStats>(context, listen: false);
        final matchDataProvider = Provider.of<MatchAdd>(context, listen: false);

        // Get the matchCode from the MatchAdd provider
        final selectedMatchCode = matchDataProvider.matchCode;

        // Show loading indicator or disable the button if needed
        matchStatsProvider.isLoading = true;
        matchStatsProvider.notifyListeners();

        // Fetch match stats using the selected match code
        await matchStatsProvider.fetchSelectedMatchStats(selectedMatchCode);

        // Check if the widget is still mounted before using the context
        if (!mounted) return;

        // After successfully fetching the stats, navigate to MatchStatsPage
        if (!matchStatsProvider.hasError) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MatchStatsPage()),
          );
        } else {
          // Handle error case
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching match stats')),
          );
        }

        // Debug: print the match code to confirm it
        // ignore: avoid_print
        print("Match code passed: $selectedMatchCode");
      },
      icon: const Icon(Icons.data_thresholding_outlined),
      label: const Text('Match Stats'),
    );
  }

  Widget bottomNavbar(BuildContext context) {
    final matchDataProvider = Provider.of<MatchAdd>(context, listen: false);

    // Get the matchCode from the MatchAdd provider
    final selectedMatchCode = matchDataProvider.matchCode;

    // Access the MatchStats provider
    final matchStats = Provider.of<SelectedMatchStats>(context);

    if (!matchStats.completedEvent && !matchStats.eventTraining) {
      return Container(
        height: 65,
        color: Colors.black12,
        child: Row(
          children: [
            // Button 1: Go to Match
            Expanded(
              child: InkWell(
                onTap: () {
                  matchStats.matchCode = selectedMatchCode;
                  matchStats.resetMatchStats(); // Reset stats using MatchStats
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BasicMatchPageV3()),
                  );
                },
                child: const Padding(
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

            // Button 2: Completed
            Expanded(
              child: InkWell(
                onTap: () {
                  matchStats
                      .markMatchCompleted(true); // Mark match as completed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Match marked as completed!')),
                  );
                },
                child: const Padding(
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
          ],
        ),
      );
    } else {
      return const SizedBox
          .shrink(); // Returns an empty widget instead of a container
    }
  }
}
