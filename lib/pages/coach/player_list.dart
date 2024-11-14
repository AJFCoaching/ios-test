import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart'; // Assuming you're using Provider for UserInfo
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase client
import 'package:matchday/modal/add_player.dart';

class TeamPlayerListPage extends StatefulWidget {
  const TeamPlayerListPage({super.key});

  @override
  State<TeamPlayerListPage> createState() => _TeamPlayerListPageState();
}

class _TeamPlayerListPageState extends State<TeamPlayerListPage> {
  Future<List<Map<String, dynamic>>> fetchPlayerList() async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);

    try {
      // Fetch the list of players based on the team_code
      final List<dynamic> response = await Supabase.instance.client
          .from('squad')
          .select()
          .eq('team_code', userInfo.teamCode);

      // Convert the dynamic response to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Handle error
      throw Exception('Error fetching players: $e');
    }
  }

  Future<void> _refresh() {
    return Future.delayed(const Duration(seconds: 2), () {
      setState(() {}); // Refresh the state to reload the player list
    });
  }

  void _selectAddPlayerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return const AddPlayerModal(); // Your existing add player modal
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 10),
      addPlayerButton(),
      const SizedBox(height: 10),
      playerListView(),
    ]);
  }

  // Add player button
  Widget addPlayerButton() {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.black,
          ),
          onPressed: () => _selectAddPlayerModal(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Add Player'),
        ),
        const Spacer(),
      ],
    );
  }

  // List of players
  Widget playerListView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPlayerList(), // Fetch the player list dynamically
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final players = snapshot.data;

              if (players == null || players.isEmpty) {
                return const Center(child: Text('No players available.'));
              }

              return ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: ListTile(
                      // Player short code or ID
                      leading: FittedBox(
                        child: Container(
                          width: 90,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors
                                .amber, // Set the background color to amber
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                player['player_short'] ??
                                    'Unknown', // Short name
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Player full name
                      title: Text(
                        player['player_name'] ?? 'No Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
