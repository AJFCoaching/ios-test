import 'package:flutter/material.dart';
import 'package:matchday/modal/add_player.dart';
import 'package:matchday/supabase.dart';

class TeamPlayerListPage extends StatefulWidget {
  const TeamPlayerListPage({Key? key}) : super(key: key);

  @override
  State<TeamPlayerListPage> createState() => _TeamPlayerListPageState();
}

Future<void> _refresh() {
  return Future.delayed(Duration(seconds: 2));
}

void _selectAddPlayerModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return AddPlayerModal();
    },
  );
}

class _TeamPlayerListPageState extends State<TeamPlayerListPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 10),
      addPlayerButton(),
      SizedBox(height: 10),
      playerListView(),
    ]);
  }

  // add player button
  Widget addPlayerButton() {
    return Container(
      child: Row(
        children: [
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.black,
            ),
            onPressed: () => _selectAddPlayerModal(context),
            icon: Icon(Icons.person_add),
            label: Text('Add Player'),
          ),
          Spacer(),
        ],
      ),
    );
  }

  // value of players
  Widget playerCount() {
    return Row(
      children: [
        Spacer(),
        Text('No of Players -'),
        SizedBox(width: 2),
      ],
    );
  }

  //  list of players created
  Widget playerListView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: playerList,
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: ListTile(
                      // EVENT DATE
                      leading: FittedBox(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                player['player_short'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          width: 90,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors
                                .amber, // Set the background color to amber
                          ),
                        ),
                      ),
                      // EVENT TITLE
                      title: Text(
                        player['player_name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
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
}
