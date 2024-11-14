import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/coach/register_team.dart';
import 'package:matchday/pages/coach/player_list.dart';
import 'package:matchday/pages/coach/match_v3/basic_match_v3.dart';
import 'package:matchday/pages/normal_pages/fixture_page.dart';
import 'package:matchday/supabase/notifier/next_event.dart';
import 'package:matchday/supabase/supabase.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<Map<String, dynamic>> nextEvent = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        nextMatchContainer(),
        const SizedBox(height: 10),
        lastResults(),
        const SizedBox(height: 10),
        seasonResults(),
        const SizedBox(height: 20),
        resultsPieChart(),
      ],
    );
  }

  Widget nextMatchContainer() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
            width: double.infinity, // Set width to match the screen
            height: 150.0, // Set height to 150
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(
                  15.0), // Set the background color to amber
            ),
            child: Column(children: [
              nextEventTile(),
              const SizedBox(height: 2),
              eventType(),
              const SizedBox(height: 2),
              Row(children: [
                const Spacer(),
                eventDate(),
                const Spacer(),
                eventTime(),
                const Spacer(),
              ]),
              const SizedBox(height: 2),
              nextOpp(),
            ])));
  }

  Widget nextEventTile() {
    return const Text(
      'NEXT EVENT',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }

  Widget noEventSetTile() {
    return const Text(
      'No Event Set',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget eventType() {
    final nextEvent = Provider.of<NextEvent>(context);
    if (nextEvent.nextEventType.isNotEmpty) {
      return Text(
        nextEvent.nextEventType,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      );
    } else {
      return noEventSetTile();
    }
  }

  Widget eventDate() {
    final nextEvent = Provider.of<NextEvent>(context);
    if (nextEvent.nextEventDate.isNotEmpty) {
      return Text(
        nextEvent.nextEventDate,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget eventTime() {
    final nextEvent = Provider.of<NextEvent>(context);
    if (nextEvent.nextEventTime.isNotEmpty) {
      return Text(
        nextEvent.nextEventTime,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget nextOpp() {
    final nextEvent = Provider.of<NextEvent>(context);
    if (nextEvent.nextEventOpp.isNotEmpty) {
      return Text(
        nextEvent.nextEventOpp,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget lastResults() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.black, // Black border
              width: 2.0, // Border thickness
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 10),
            const Text(
              'Last 5 results',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Spacer(),
                const Text(
                  'Latest',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                const Spacer(),
                lastMatchResults(),
                const Spacer(),
                const Text(
                  'Oldest',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                const Spacer(),
              ],
            ),
          ]),
        ));
  }

  Widget lastMatchResults() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 60,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: responseResult,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final matchresult = snapshot.data!;

            // Check if there are no results
            if (matchresult.isEmpty) {
              return const Center(child: Text('No results available.'));
            }

            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: matchresult.length,
              physics: const BouncingScrollPhysics(), // Smooth scrolling
              itemBuilder: (context, index) {
                final result = matchresult[index];
                Color backgroundColor;
                String finalResultText = result['final_result'];

                // Set colors based on the match result
                if (finalResultText == 'Win') {
                  backgroundColor = Colors.green;
                } else if (finalResultText == 'Draw') {
                  backgroundColor = Colors.amber;
                } else if (finalResultText == 'Lost') {
                  backgroundColor = Colors.red;
                } else {
                  backgroundColor = Colors.grey; // Fallback color
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: backgroundColor,
                    foregroundColor: Colors.white,
                    child: Center(
                      child: Text(
                        finalResultText,
                        style: const TextStyle(
                          fontSize: 13, // Adjusted font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget seasonResults() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 140,
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
            const Text(
              "Season Results",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            teamWins(),
            teamDraws(),
            teamLost(),
            const SizedBox(height: 5),
          ]),
        ));
  }

  Widget teamWins() {
    return FutureBuilder<int>(
      future: countWinOccurrences(
          context), // Invoke countWinOccurrences() asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the count is being fetched, show a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred during the fetch, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the count is successfully fetched, display it

          final winCount = snapshot.data;
          pcTeamWins = winCount!;
          return Row(
            children: [
              const SizedBox(width: 50),
              const Text(
                'Total Wins',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '$winCount',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 50),
            ],
          );
        }
      },
    );
  }

  Widget teamDraws() {
    return FutureBuilder<int>(
      future: countDrawOccurrences(
          context), // Invoke countWinOccurrences() asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the count is being fetched, show a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred during the fetch, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the count is successfully fetched, display it
          final drawCount = snapshot.data;
          pcTeamDraws = drawCount!;
          return Row(
            children: [
              const SizedBox(width: 50),
              const Text(
                'Total Draws',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '$drawCount',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 50),
            ],
          );
        }
      },
    );
  }

  Widget teamLost() {
    return FutureBuilder<int>(
      future: countLostOccurrences(
          context), // Invoke countWinOccurrences() asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the count is being fetched, show a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred during the fetch, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the count is successfully fetched, display it
          final lostCount = snapshot.data;
          pcTeamLost = lostCount!;
          return Row(
            children: [
              const SizedBox(width: 50),
              const Text(
                'Total Lost',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '$lostCount',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 50),
            ],
          );
        }
      },
    );
  }

  Widget gridView() {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      crossAxisCount: 2, // Number of columns in the grid
      shrinkWrap: true,
      children: [
        // Fixture Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () {
            // Add code to navigate to the first page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FixturePage()),
            );
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('Fixture'),
        ),

        // Player Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () {
            // Add code to navigate to the second page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TeamPlayerListPage()),
            );
          },
          icon: const Icon(Icons.groups),
          label: const Text('Players'),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () {
            // Add code to navigate to the third page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BasicMatchPageV3()),
            );
          },
          icon: const Icon(Icons.sports_soccer),
          label: const Text('Basic Match'),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterTeamPage()),
            );
          },
          icon: const Icon(Icons.update),
          label: const Text('Update Team'),
        ),
      ],
    );
  }

  Widget resultsPieChart() {
    return PieChart(
      dataMap: dataMap,
      colorList: colorList,
      chartRadius: MediaQuery.of(context).size.width / 2,
      legendOptions: const LegendOptions(showLegends: false),
      centerText: "RESULTS",
    );
  }

// list of last 5 results
  List? eventResults;

  final responseResult = supabase
      .from('fixtures')
      .select('final_result')
      .lte('date', DateTime.now())
      .isFilter('completed', true)
      .isFilter('match_training', false)
      .limit(5)
      .order('date', ascending: false);

// next event

  Map<String, double> dataMap = {
    "Wins": pcTeamWins.toDouble(),
    "Draws": pcTeamDraws.toDouble(),
    "Lost": pcTeamLost.toDouble(),
  };

  List<Color> colorList = [
    const Color(0xff3EE094),
    const Color(0xffFE9539),
    const Color(0xffFA4A42),
  ];
}
