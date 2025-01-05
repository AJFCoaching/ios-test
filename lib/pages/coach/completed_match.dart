import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/match_add.dart';

import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';

import 'package:provider/provider.dart';

class CompletedMatchModal extends StatefulWidget {
  const CompletedMatchModal({super.key});

  @override
  State<CompletedMatchModal> createState() => _CompletedMatchModalState();
}

class _CompletedMatchModalState extends State<CompletedMatchModal> {
  // Increment team score using MatchStats ChangeNotifier
  void incrementTeamCounter() {
    final matchStats = Provider.of<SelectedMatchStats>(context, listen: false);
    matchStats.incrementTeamScore(); // Assumes you have a method in MatchStats
  }

  // Decrement team score using MatchStats ChangeNotifier
  void decrementTeamCounter() {
    final matchStats = Provider.of<SelectedMatchStats>(context, listen: false);
    matchStats.decrementTeamScore(); // Assumes you have a method in MatchStats
  }

  // Increment opponent score using MatchStats ChangeNotifier
  void incrementOppCounter() {
    final matchStats = Provider.of<SelectedMatchStats>(context, listen: false);
    matchStats.incrementOppScore(); // Assumes you have a method in MatchStats
  }

  // Decrement opponent score using MatchStats ChangeNotifier
  void decrementOppCounter() {
    final matchStats = Provider.of<SelectedMatchStats>(context, listen: false);
    matchStats.decrementOppScore(); // Assumes you have a method in MatchStats
  }

  @override
  Widget build(BuildContext context) {
    // Access MatchStats to get the current team and opponent counters
    final matchStats = Provider.of<SelectedMatchStats>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 10),
            matchDateWidget(),
            const SizedBox(height: 10),
            matchTypeWidget(),
            const SizedBox(height: 30),
            Column(
              children: [
                // top row
                Row(
                  children: [
                    const SizedBox(width: 20),
                    matchTeamWidget(),
                    const Spacer(),
                    // Decrement team counter
                    teamReduceButton(onPressed: decrementTeamCounter),
                    const SizedBox(width: 10),
                    Text(
                      '${matchStats.teamScore}', // Get the current team score from MatchStats
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    // Increment team counter
                    teamAddButton(onPressed: incrementTeamCounter),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 30),

                // bottom row
                Row(
                  children: [
                    const SizedBox(width: 20),
                    matchOppWidget(),
                    const Spacer(),
                    // Decrement opponent counter
                    oppReduceButton(onPressed: decrementOppCounter),
                    const SizedBox(width: 10),
                    Text(
                      '${matchStats.oppScore}', // Get the current opponent score from MatchStats
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    // Increment opponent counter
                    oppAddButton(onPressed: incrementOppCounter),
                    const SizedBox(width: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const Spacer(),
                winButton(),
                const Spacer(),
                drawButton(),
                const Spacer(),
                lostButton(),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            if (matchResult != '') resultText() else const SizedBox.shrink(),
            const Spacer(),
            submitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget matchDateWidget() {
    final matchData = Provider.of<MatchAdd>(context);
    return Text(
      matchData.formattedDate,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget matchTypeWidget() {
    final matchData = Provider.of<MatchAdd>(context);
    return Text(
      matchData.matchType,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget matchOppWidget() {
    final matchData = Provider.of<MatchAdd>(context);
    return Text(
      matchData.oppTeam,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget matchTeamWidget() {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    return Text(
      userInfo.teamName,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget teamAddButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget teamReduceButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.red,
          child: const Icon(Icons.remove),
        ),
      ),
    );
  }

  Widget oppAddButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget oppReduceButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.red,
          child: const Icon(Icons.remove),
        ),
      ),
    );
  }

  Widget winButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, foregroundColor: Colors.white),
      child: const Text('Win'),
      onPressed: () {
        setState(() {
          matchResult = 'Win';
        });
      },
    );
  }

  Widget drawButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber, foregroundColor: Colors.black),
      child: const Text('Draw'),
      onPressed: () {
        setState(() {
          matchResult = 'Draw';
        });
      },
    );
  }

  Widget lostButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, foregroundColor: Colors.white),
      child: const Text('Lost'),
      onPressed: () {
        setState(() {
          matchResult = 'Lost';
        });
      },
    );
  }

  Widget resultText() {
    return Text(
      matchResult,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget submitButton() {
    final matchStats = Provider.of<SelectedMatchStats>(context, listen: false);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        matchStats.saveMatchStatsToSupabase(context);

        // Return to the previous page
        Navigator.pop(context);
      },
      child: const Text('Sumbit'),
    );
  }
}
