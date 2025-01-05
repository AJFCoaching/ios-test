import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/event_data.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPreviousMatchDataPage extends StatefulWidget {
  const AddPreviousMatchDataPage({super.key});

  @override
  State<AddPreviousMatchDataPage> createState() =>
      _AddPreviousMatchDataPageState();
}

class _AddPreviousMatchDataPageState extends State<AddPreviousMatchDataPage> {
  Future<void> savePlayerDataToSupabase() async {
    final matchAddProvider = Provider.of<MatchAdd>(context, listen: false);
    final matchActionUpdates = {
      'match_code': matchAddProvider.matchCode,
      'half': prevEventHalf,
      'minute': value,
      'action': prevEventAction,
      'player': prevEventPlayerSelect,
      'assist': prevEventPlayerAssistSelect,
    };
    await supabase.from('match_actions').upsert(matchActionUpdates);
  }

  late Future<List<Map<String, dynamic>>> dropdownData;

  @override
  void initState() {
    super.initState();
    dropdownData = fetchDropdownData();
  }

  List<dynamic>? playerList;

  // Fetch player list using teamCode from UserInfo ChangeNotifier
  Future<void> fetchPlayerList() async {
    // Access the userInfo provider to get the teamCode
    final userInfo = Provider.of<UserInfo>(context, listen: false);

    try {
      // Fetch the list of players based on the teamCode
      final List<dynamic> response = await Supabase.instance.client
          .from('squad')
          .select()
          .eq('team_code', userInfo.teamCode); // Use teamCode from UserInfo

      setState(() {
        playerList = response; // Assign fetched players to playerList
      });
    } catch (e) {
      // Handle any errors during fetching
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching players: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchDropdownData() async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    final response = await supabase
        .from('squad')
        .select('player_names')
        .eq('team_code', userInfo.teamCode);

    return response;
  }

  String? selectedPlayer = '';
  double value = 0;

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 5),
            titleText(),
            const SizedBox(height: 30),
            Row(children: [
              const SizedBox(width: 10),
              Expanded(
                child: sliderTimeSelect(),
              ),
              const SizedBox(width: 10),
              buildSlideLabel(value),
              const SizedBox(width: 10),
            ]),
            const SizedBox(height: 20),
            textSelectedHalf(),
            const SizedBox(height: 20),
            teamRadioButton(),
            const SizedBox(height: 20),
            oppTeamRadioButton(),
            const SizedBox(height: 20),
            if (selectedTeam == userInfo.teamName)
              playerSelectList()
            else
              const SizedBox.shrink(),
            const SizedBox(height: 20),
            actionSelectList(),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            if (prevEventAction == 'Goal')
              playerAssistSelectList()
            else
              const SizedBox.shrink(),
            const Spacer(),
            detailsTile(),
            const SizedBox(height: 20),
            submitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget titleText() {
    return const Text(
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
        if (value < matchHalfLength) {
          prevEventHalf = '1st Half'.toString();
        } else {
          prevEventHalf = '2nd Half'.toString();
        }
      }),
    );
  }

  Widget buildSlideLabel(double value) {
    return Text(
      value.round().toString(),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget teamRadioButton() {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    return SizedBox(
      width: 300,
      child: RadioMenuButton(
        value: userInfo.teamName,
        groupValue: selectedTeam,
        onChanged: (selectedValue) {
          setState(() => selectedTeam = selectedValue! as String);
        },
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevation: const WidgetStatePropertyAll(2),
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
        child: Text(userInfo.teamName),
      ),
    );
  }

  Widget oppTeamRadioButton() {
    final matchStats = Provider.of<SelectedMatchStats>(context, listen: false);
    return SizedBox(
      width: 300,
      child: RadioMenuButton(
        value: matchStats.oppName,
        groupValue: selectedTeam,
        onChanged: (selectedValue) {
          setState(() => selectedTeam = selectedValue! as String);
          setState(() => prevEventPlayerSelect = selectedValue! as String);
        },
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevation: const WidgetStatePropertyAll(2),
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
        child: Text(matchStats.oppName),
      ),
    );
  }

  Widget textSelectedTeam() {
    return Text(
      selectedTeam,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget textSelectedHalf() {
    return Text(
      prevEventHalf,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // Player dropdown list widget
  Widget playerSelectList() {
    return SizedBox(
      height: 50,
      child: playerList == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: playerList!.length,
              itemBuilder: (context, index) {
                final player = playerList![index]; // Get current player
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      player['player_short'], // Display player's short name
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        prevEventPlayerSelect = player[
                            'player_name']; // Update selected player name
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget textSelectedPlayer() {
    return Text(
      prevEventPlayerSelect,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget actionSelectList() {
    return SizedBox(
      height: 75,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          // button 1
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text(
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
            child: const Text(
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
            child: const Text(
              'PEN SCORED',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            onPressed: () {
              final matchStats =
                  Provider.of<SelectedMatchStats>(context, listen: false);
              setState(() {
                prevEventAction = 'Penalty Scored';
                // ignore: unrelated_type_equality_checks
                if (oppTeamRadioButton() == matchStats.oppName) {
                  prevOppScore++;
                } else {
                  prevTeamScore++;
                }
              });
            },
          ),

          // button 4
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text(
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
            child: const Text(
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
              child: const Text(
                'GOAL',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
              ),
              onPressed: () {
                final matchStats =
                    Provider.of<SelectedMatchStats>(context, listen: false);
                setState(
                  () {
                    prevEventAction = 'Goal';
                    // ignore: unrelated_type_equality_checks
                    if (oppTeamRadioButton() == matchStats.oppName) {
                      prevOppScore++;
                    } else {
                      prevTeamScore++;
                    }
                  },
                );
              }),

          // button 7
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: const Text(
              'OWN GOAL',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
            ),
            onPressed: () {
              final matchStats =
                  Provider.of<SelectedMatchStats>(context, listen: false);
              setState(() {
                prevEventAction = 'Own Goal';
                // ignore: unrelated_type_equality_checks
                if (oppTeamRadioButton() == matchStats.oppName) {
                  prevTeamScore++;
                } else {
                  prevOppScore++;
                }
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
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget actionAssistText() {
    return const Text(
      'Assist by',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // Player assist dropdown list widget
  Widget playerAssistSelectList() {
    return SizedBox(
      height: 50,
      child: playerList == null
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: playerList!.length,
              itemBuilder: (context, index) {
                final player = playerList![index]; // Get the current player
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      player['player_short'], // Display player's short name
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        prevEventPlayerAssistSelect = player[
                            'player_name']; // Update selected player's name
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget playerAssistSelectText() {
    return Text(
      prevEventPlayerAssistSelect,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget detailsTile() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Colors.yellow),
      child: Row(children: [
        // leading
        const SizedBox(width: 10),
        buildSlideLabel(value),

        SizedBox(
          height: 80,
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // top row
                Row(mainAxisSize: MainAxisSize.max, children: [
                  const Spacer(),
                  textSelectedTeam(),
                  const Spacer(),
                  actionSelectText(),
                  const Spacer(),
                ]),

                // bottom row
                Row(mainAxisSize: MainAxisSize.max, children: [
                  const Spacer(),
                  textSelectedPlayer(),
                  const Spacer(),
                  actionAssistText(),
                  const Spacer(),
                  playerAssistSelectText(),
                  const Spacer(),
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
          icon: const Icon(Icons.cancel),
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
            MaterialPageRoute(builder: (context) => const EventDataPage()),
          );
        },
        child: const Text('Submit'));
  }
}
