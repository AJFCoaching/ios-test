import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:provider/provider.dart'; // Assuming supabase instance is imported from main.dart

class PlayerPositionsPage extends StatefulWidget {
  const PlayerPositionsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PlayerPositionsPageState createState() => _PlayerPositionsPageState();
}

class _PlayerPositionsPageState extends State<PlayerPositionsPage> {
  late Future<List<Map<String, dynamic>>> _attendanceStatusFuture;

  // Track selected player initials for each position
  Map<String, String> selectedPlayers = {};

  @override
  void initState() {
    super.initState();
    _attendanceStatusFuture = _fetchAttendanceStatus();
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceStatus() async {
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
    final response = await supabase
        .from('event_attendance')
        .select()
        .eq('match_code', matchStatsProvider.matchCode);

    return List<Map<String, dynamic>>.from(response);
  }

// Save selected positions to Supabase filtered by player_short (initials)
  Future<void> _savePlayerPositions() async {
    final matchStatsProvider = Provider.of<MatchAdd>(context, listen: false);
    try {
      for (var entry in selectedPlayers.entries) {
        // Get the short position (e.g., "LF", "CM")
        String shortPosition = entry.key;
        String playerInitials = entry.value; // This holds player initials

        await supabase
            .from('event_attendance')
            .update({'position': shortPosition}) // Save the short position
            .eq('match_code',
                matchStatsProvider.matchCode) // Filter by match code
            .eq('player_short', playerInitials); // Filter by player initials
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player positions saved successfully!')),
      );
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving player positions: $error')),
      );
    }
  }

// Show dialog to select a player for the given position
  void _selectPlayerForPosition(
      String position, List<Map<String, dynamic>> players) {
    // Filter out players that are already selected for other positions
    final availablePlayers = players.where((player) {
      final playerName = player['player_name'] as String;
      return !selectedPlayers
          .containsValue(playerName); // Only show unselected players
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Player for $position'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];
                final playerName = player['player_name'] as String;
                final playerInitials = _getPlayerInitials(playerName);

                return ListTile(
                  title: Text(playerName),
                  onTap: () {
                    // Update selected player for the position
                    setState(() {
                      selectedPlayers[position] =
                          playerInitials; // Show initials after selection
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

// Helper function to get initials from a player's name
  String _getPlayerInitials(String playerName) {
    final names = playerName.split(' ');
    String initials = '';
    if (names.length > 1) {
      initials =
          names[0][0] + names[1][0]; // Get first letters of first and last name
    } else if (names.isNotEmpty) {
      initials = names[0][0]; // If only one name part exists
    }
    return initials.toUpperCase();
  }

  // Helper to build a row of position buttons
  Widget _buildPositionRow(
      List<String> positions, List<Map<String, dynamic>> players) {
    return Row(
      children: positions.map((position) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 4.0), // Adjust spacing between buttons
            child: _buildPositionButton(position, players),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPositionButton(
      String position, List<Map<String, dynamic>> players) {
    final isPlayerSelected = (selectedPlayers[position] ?? '').isNotEmpty;

    return GestureDetector(
      onTap: () => _selectPlayerForPosition(position, players),
      child: CircleAvatar(
        radius: 30, // Size of the CircleAvatar
        backgroundColor: isPlayerSelected
            ? Colors.green
            : Colors.black, // Change color based on selection
        child: Center(
          child: Text(
            isPlayerSelected
                ? selectedPlayers[position]! // Show player initials
                : position, // Show position name if no player selected
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Center text within the CircleAvatar
          ),
        ),
      ),
    );
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: _savePlayerPositions,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text(
        'Confirm Positions',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Positions'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _attendanceStatusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final List<Map<String, dynamic>> players = snapshot.data ?? [];

              // Filter players who are attending
              final attendingPlayers = players
                  .where((player) => player['player_attendance'] == true)
                  .toList();

              // If no players are attending, show a message
              if (attendingPlayers.isEmpty) {
                return const Center(child: Text('No players attending'));
              }

              // Display position buttons with player selection
              return Column(
                children: [
                  const Spacer(),
                  _buildPositionRow(
                      ['LF', 'LCF', 'CF', 'RCF', 'RF'], attendingPlayers),
                  const Spacer(),
                  _buildPositionRow(
                      ['LW', 'LAM', 'CAM', 'RAM', 'RW'], attendingPlayers),
                  const Spacer(),
                  _buildPositionRow(
                      ['LM', 'LCM', 'CM', 'RCM', 'RM'], attendingPlayers),
                  const Spacer(),
                  _buildPositionRow(
                      ['LWB', 'LCDM', 'CDM', 'RCDM', 'RWB'], attendingPlayers),
                  const Spacer(),
                  _buildPositionRow(
                      ['LB', 'LCB', 'CB', 'RCB', 'RB'], attendingPlayers),
                  const Spacer(),
                  _buildPositionRow(['GK'], attendingPlayers),
                  const Spacer(),
                  _buildPositionRow(
                      ['S1', 'S2', 'S3', 'S4', 'S5'], attendingPlayers),
                  const Spacer(),
                  saveButton(), // Save button at the bottom
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
