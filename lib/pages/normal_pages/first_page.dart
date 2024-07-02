import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/coach/register_team.dart';
import 'package:matchday/pages/coach/player_list.dart';
import 'package:matchday/pages/coach/basic_match.dart';
import 'package:matchday/pages/normal_pages/fixture_page.dart';
import 'package:matchday/supabase.dart';
import 'package:pie_chart/pie_chart.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

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
        nextMatchContainer(),
        SizedBox(height: 10),
        Text(
          'Last 5 results',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Spacer(),
            Text(
              'Latest',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
            Spacer(),
            lastMatchResults(),
            Spacer(),
            Text(
              'Oldest',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 20),
        Text(
          "Season Results",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        teamWins(),
        teamDraws(),
        teamLost(),
        SizedBox(height: 20),
        resultsPieChart(),
      ],
    );
  }

  Widget nextMatchContainer() {
    return Container(
        width: double.infinity, // Set width to match the screen
        height: 150.0, // Set height to 150
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: Colors.amber // Set the background color to amber
            ),
        child: Column(children: [
          nextEventTile(),
          SizedBox(height: 2),
          eventType(),
          SizedBox(height: 2),
          Row(children: [
            Spacer(),
            eventDate(),
            Spacer(),
            eventTime(),
            Spacer(),
          ]),
        ]));
  }

  Widget nextEventTile() {
    return Text(
      'NEXT EVENT',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }

  Widget noEventSetTile() {
    return Text(
      'No Event Set',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget eventType() {
    if (nextEvent.isNotEmpty) {
      return Text(
        nextEvent[0]['Type'],
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      );
    } else {
      return noEventSetTile();
    }
  }

  Widget eventDate() {
    if (nextEvent.isNotEmpty) {
      return Text(
        nextEvent[0]['event_date'],
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget eventTime() {
    if (nextEvent.isNotEmpty) {
      return Text(
        nextEvent[0]['time'],
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget nextOpp() {
    if (nextEvent.isNotEmpty) {
      return Text(
        nextEvent[0]['Opp'],
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget lastMatchResults() {
    return Container(
      height: 60,
      child: FutureBuilder<List<Map<String, dynamic>>>(
          future: responseResult,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final matchresult = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: matchresult.length,
                itemBuilder: ((context, index) {
                  final result = matchresult[index];
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        if (result['final_result'] == 'Win')
                          CircleAvatar(
                            child: Text(
                              result['final_result'],
                              style: TextStyle(fontSize: 15),
                            ),
                            radius: 25,
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        if (result['final_result'] == 'Draw')
                          CircleAvatar(
                            child: Text(
                              result['final_result'],
                              style: TextStyle(fontSize: 15),
                            ),
                            radius: 25,
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                        if (result['final_result'] == 'Lost')
                          CircleAvatar(
                            child: Text(
                              result['final_result'],
                              style: TextStyle(fontSize: 15),
                            ),
                            radius: 25,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                      ],
                    ),
                  );
                }));
          }),
    );
  }

  Widget teamWins() {
    return FutureBuilder<int>(
      future:
          countWinOccurrences(), // Invoke countWinOccurrences() asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the count is being fetched, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred during the fetch, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the count is successfully fetched, display it

          final winCount = snapshot.data;
          pcTeamWins = winCount!;
          return Row(
            children: [
              SizedBox(width: 50),
              Text(
                'Total Wins',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Spacer(),
              Text(
                '$winCount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(width: 50),
            ],
          );
        }
      },
    );
  }

  Widget teamDraws() {
    return FutureBuilder<int>(
      future:
          countDrawOccurrences(), // Invoke countWinOccurrences() asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the count is being fetched, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred during the fetch, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the count is successfully fetched, display it
          final drawCount = snapshot.data;
          pcTeamDraws = drawCount!;
          return Row(
            children: [
              SizedBox(width: 50),
              Text(
                'Total Draws',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Spacer(),
              Text(
                '$drawCount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(width: 50),
            ],
          );
        }
      },
    );
  }

  Widget teamLost() {
    return FutureBuilder<int>(
      future:
          countLostOccurrences(), // Invoke countWinOccurrences() asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the count is being fetched, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred during the fetch, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the count is successfully fetched, display it
          final lostCount = snapshot.data;
          pcTeamLost = lostCount!;
          return Row(
            children: [
              SizedBox(width: 50),
              Text(
                'Total Lost',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Spacer(),
              Text(
                '$lostCount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(width: 50),
            ],
          );
        }
      },
    );
  }

  Widget gridView() {
    return GridView.count(
      padding: EdgeInsets.all(20),
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
            print(teamCode);
            // Add code to navigate to the first page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FixturePage()),
            );
          },
          icon: Icon(Icons.calendar_month),
          label: Text('Fixture'),
        ),

        // Player Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () {
            // Add code to navigate to the second page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TeamPlayerListPage()),
            );
          },
          icon: Icon(Icons.groups),
          label: Text('Players'),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () {
            // Add code to navigate to the third page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BasicMatchPage()),
            );
          },
          icon: Icon(Icons.sports_soccer),
          label: Text('Basic Match'),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterTeamPage()),
            );
          },
          icon: Icon(Icons.update),
          label: Text('Update Team'),
        ),
      ],
    );
  }

  Widget resultsPieChart() {
    return PieChart(
      dataMap: dataMap,
      colorList: colorList,
      chartRadius: MediaQuery.of(context).size.width / 2,
      legendOptions: LegendOptions(showLegends: false),
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

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    var response = await supabase
        .from('fixtures')
        .select()
        .gte('date', DateTime.now())
        .isFilter('completed', false)
        .limit(1)
        .order('date', ascending: true);
    setState(() {
      nextEvent = response.toList();
    });
  }

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
