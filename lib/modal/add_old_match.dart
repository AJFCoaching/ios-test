import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/event_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPreviousMatchDataPage extends StatefulWidget {
  const AddPreviousMatchDataPage({Key? key}) : super(key: key);

  @override
  State<AddPreviousMatchDataPage> createState() =>
      _AddPreviousMatchDataPageState();
}

class _AddPreviousMatchDataPageState extends State<AddPreviousMatchDataPage> {
  Future<void> savePlayerDataToSupabase() async {
    final MatchActionUpdates = {
      'match_code': matchCode,
      'half': prevEventHalf,
      'minute': value,
      'action': prevEventAction,
      'player': prevEventPlayerSelect,
      'assist': prevEventPlayerAssistSelect,
    };
    await supabase.from('match_actions').upsert(MatchActionUpdates);
  }

  late Future<List<Map<String, dynamic>>> dropdownData;

  @override
  void initState() {
    super.initState();
    dropdownData = fetchDropdownData();
  }

  final playerList =
      Supabase.instance.client.from('squad').select().eq('team_code', teamCode);

  Future<List<Map<String, dynamic>>> fetchDropdownData() async {
    final response = await supabase
        .from('squad')
        .select('player_names')
        .eq('team_code', teamCode);

    return response;
  }

  String? selectedPlayer = '';
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 5),
            titleText(),
            SizedBox(height: 30),
            Row(children: [
              SizedBox(width: 10),
              Expanded(
                child: sliderTimeSelect(),
              ),
              SizedBox(width: 10),
              buildSlideLabel(value),
              SizedBox(width: 10),
            ]),
            SizedBox(height: 20),
            textSelectedHalf(),
            SizedBox(height: 20),
            teamRadioButton(),
            SizedBox(height: 20),
            oppTeamRadioButton(),
            SizedBox(height: 20),
            if (selectedTeam == teamName)
              playerSelectList()
            else
              SizedBox.shrink(),
            SizedBox(height: 20),
            actionSelectList(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            if (prevEventAction == 'Goal')
              playerAssistSelectList()
            else
              SizedBox.shrink(),
            Spacer(),
            detailsTile(),
            SizedBox(height: 20),
            submitButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget titleText() {
    return Text(
      'UPDATE MATCH ACTION',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget sliderTimeSelect() {
    return Slider(
      min: 0,
      max: 60,
      divisions: 60,
      value: value,
      label: value.round().toString(),
      activeColor: Colors.blue,
      onChanged: (value) => setState(() {
        this.value = value;
        if (value < matcHalfLength)
          prevEventHalf = '1st Half'.toString();
        else
          prevEventHalf = '2nd Half'.toString();
      }),
    );
  }

  Widget buildSlideLabel(double value) {
    return Text(
      value.round().toString(),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget teamRadioButton() {
    return SizedBox(
      width: 300,
      child: RadioMenuButton(
        value: teamName,
        groupValue: selectedTeam,
        onChanged: (selectedValue) {
          setState(() => selectedTeam = selectedValue! as String);
        },
        child: Text(teamName),
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevation: const MaterialStatePropertyAll(2),
          backgroundColor: const MaterialStatePropertyAll(Colors.white),
        ),
      ),
    );
  }

  Widget oppTeamRadioButton() {
    return SizedBox(
      width: 300,
      child: RadioMenuButton(
        value: oppTeam,
        groupValue: selectedTeam,
        onChanged: (selectedValue) {
          setState(() => selectedTeam = selectedValue! as String);
          setState(() => prevEventPlayerSelect = selectedValue! as String);
        },
        child: Text(oppTeam),
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevation: const MaterialStatePropertyAll(2),
          backgroundColor: const MaterialStatePropertyAll(Colors.white),
        ),
      ),
    );
  }

  Widget textSelectedTeam() {
    return Text(
      selectedTeam,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget textSelectedHalf() {
    return Text(
      prevEventHalf,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

// player dropdown list
  Widget playerSelectList() {
    return Container(
      height: 50,
      child: FutureBuilder<List<Map<String, dynamic>>>(
          future: playerList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final players = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: players.length,
                itemBuilder: ((context, index) {
                  final player = players[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              player['player_short'],
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                prevEventPlayerSelect = player['player_name'];
                                print(players.length);
                              });
                            }),
                      ],
                    ),
                  );
                }));
          }),
    );
  }

  Widget textSelectedPlayer() {
    return Text(
      prevEventPlayerSelect,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget actionSelectList() {
    return Container(
      height: 75,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          // button 1
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(
              'SHOT off TARGET',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            onPressed: () {
              setState(() {
                prevEventAction = 'Shot off Target';
              });
            },
          ),

          // button 2
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text(
              'SHOT on TARGET',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            onPressed: () {
              setState(() {
                prevEventAction = 'Shot on Target';
              });
            },
          ),

          // button 3
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: Text(
              'PEN SCORED',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            onPressed: () {
              setState(() {
                prevEventAction = 'Penalty Scored';
                if (oppTeamRadioButton() == oppTeam)
                  oppcounter++;
                else
                  teamcounter++;
              });
            },
          ),

          // button 4
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(
              'PEN MISSED',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            onPressed: () {
              setState(() {
                prevEventAction = 'Penalty Missed';
              });
            },
          ),

          // button 5
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, foregroundColor: Colors.white),
            child: Text(
              'PEN SAVED',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            onPressed: () {
              setState(() {
                prevEventAction = 'Penalty Saved';
              });
            },
          ),

          // button 6
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.black),
              child: Text(
                'GOAL',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
              ),
              onPressed: () {
                setState(
                  () {
                    prevEventAction = 'Goal';
                    if (oppTeamRadioButton() == oppTeam)
                      oppcounter++;
                    else
                      teamcounter++;
                  },
                );
              }),

          // button 7
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: Text(
              'OWN GOAL',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
            ),
            onPressed: () {
              setState(() {
                prevEventAction = 'Own Goal';
                if (oppTeamRadioButton() == oppTeam)
                  teamcounter++;
                else
                  oppcounter++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget actionSelectText() {
    return Text(
      prevEventAction,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget actionAssistText() {
    return Text(
      'Assist by',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // player dropdown list
  Widget playerAssistSelectList() {
    return Container(
      height: 50,
      child: FutureBuilder<List<Map<String, dynamic>>>(
          future: playerList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final players = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: players.length,
                itemBuilder: ((context, index) {
                  final player = players[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              player['player_short'],
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                prevEventPlayerAssistSelect =
                                    player['player_name'];
                                print(players.length);
                              });
                            }),
                      ],
                    ),
                  );
                }));
          }),
    );
  }

  Widget playerAssistSelectText() {
    return Text(
      prevEventPlayerAssistSelect,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget detailsTile() {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: Colors.yellow),
      child: Row(children: [
        // leading
        SizedBox(width: 10),
        buildSlideLabel(value),

        Container(
          height: 80,
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // top row
                Row(mainAxisSize: MainAxisSize.max, children: [
                  Spacer(),
                  textSelectedTeam(),
                  Spacer(),
                  actionSelectText(),
                  Spacer(),
                ]),

                // bottom row
                Row(mainAxisSize: MainAxisSize.max, children: [
                  Spacer(),
                  textSelectedPlayer(),
                  Spacer(),
                  actionAssistText(),
                  Spacer(),
                  playerAssistSelectText(),
                  Spacer(),
                ]),
              ]),
        ),

        // ending column
        IconButton.outlined(
          onPressed: () {
            setState(() {
              prevEventPlayerSelect = '';
              prevEventAction = '';
              prevEventPlayerAssistSelect = '';
            });
          },
          icon: Icon(Icons.cancel),
        ),
      ]),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          savePlayerDataToSupabase();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDataPage()),
          );
        },
        child: Text('Submit'));
  }
}
