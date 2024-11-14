import 'package:flutter/material.dart';
import 'package:matchday/supabase/supabase.dart';

class ScoutPage extends StatefulWidget {
  const ScoutPage({super.key});

  @override
  State<ScoutPage> createState() => _ScoutPageState();
}

class _ScoutPageState extends State<ScoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Stats & Attendance')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPlayerStatsAndAttendance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = snapshot.data!;

          if (players.isEmpty) {
            return const Center(
                child: Text('No player stats or attendance found.'));
          }

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                title: Text(player['player']),
                subtitle: Text(
                    'Goals: ${player['goals']}, Shots On Target: ${player['shotsOnTarget']}, Shots Off Target: ${player['shotsOffTarget']}, Attendance Count: ${player['attendanceCount']}'),
              );
            },
          );
        },
      ),
    );
  }
}
