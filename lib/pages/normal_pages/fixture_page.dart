import 'package:flutter/material.dart';
import 'package:matchday/pages/normal_pages/event_data.dart';
import 'package:matchday/modal/add_fixture.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matchday/main.dart';

class FixturePage extends StatefulWidget {
  const FixturePage({Key? key}) : super(key: key);

  @override
  State<FixturePage> createState() => _FixturePageState();
}

String selectedEvent = '';

Future<void> _refresh() {
  return Future.delayed(Duration(seconds: 2));
}

void _addFixture(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return AddEventModel();
    },
  );
}

class _FixturePageState extends State<FixturePage> {
  final fixtureList = Supabase.instance.client
      .from('fixtures')
      .select()
      .eq('team_code', teamCode)
      .order('date', ascending: false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        addFixtureButton(),
        SizedBox(height: 10),
        listOfFixtures(),
      ],
    );
  }

  Widget listOfFixtures() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fixtureList,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final fixtures = snapshot.data!;

              return ListView.builder(
                itemCount: fixtures.length,
                itemBuilder: ((context, index) {
                  final event = fixtures[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: ListTile(
                      // EVENT DATE
                      leading: Wrap(spacing: 2, children: [
                        if (event['final_result'].toString().isEmpty)
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['day'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      event['month'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (event['match_training'] == true)
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['day'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      event['month'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (event['final_result'] == 'Win')
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['day'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      event['month'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (event['final_result'] == 'Draw')
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['day'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      event['month'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (event['final_result'] == 'Lost')
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['day'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      event['month'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ]),

                      // EVENT TITLE
                      title: Text(
                        event['Type'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),

                      // OPPOSITION TEAM
                      subtitle: Text(event['Opp']),

                      //FIXTURE REF

                      // Match Result
                      trailing: Wrap(
                        spacing: 2,
                        children: [
                          //delete event
                          IconButton.filled(
                            onPressed: () async {
                              selectedEvent = (event['fixture_ref']);

                              await supabase
                                  .from('fixtures')
                                  .delete()
                                  .match({'fixture_ref': selectedEvent});

                              await supabase
                                  .from('event_attendance')
                                  .delete()
                                  .match({'match_code': selectedEvent});

                              await supabase
                                  .from('match_actions')
                                  .delete()
                                  .match({'match_code': selectedEvent});

                              await supabase
                                  .from('fixture_stats')
                                  .delete()
                                  .match({'fixture_code': selectedEvent});
                            },
                            icon: Icon(Icons.delete_forever),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white),
                          ),

                          // event
                          IconButton.filled(
                            onPressed: () {
                              oppTeam = (event['Opp']);
                              matchDate = (event['event_date']);
                              eventAddress = (event['location']);
                              eventType = (event['Type']);
                              addresslat = (event['address_lat']);
                              addresslong = (event['address_long']);
                              matchCode = (event['fixture_ref']);
                              matchType = (event['Type']);
                              matchEventTime = (event['time']);
                              matcHalfLength = (event['match_half_length']);
                              teamScore = (event['ktfc_score']);
                              oppScore = (event['opp_score']);
                              matchResult = (event['final_result']);
                              completedEvent = (event['completed']);
                              EventTraining = (event['match_training']);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventDataPage()),
                              );
                            },
                            icon: Icon(Icons.arrow_forward_ios_outlined),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget addFixtureButton() {
    return Container(
      child: Row(
        children: [
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.black,
            ),
            onPressed: () => _addFixture(context),
            icon: Icon(Icons.person_add),
            label: Text('Add Event'),
          ),
          Spacer(),
        ],
      ),
    );
  }

  List? eventList;

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
      eventList = response.toList();
    });
  }
}
