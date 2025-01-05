import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/assist_popup.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/save_match_action.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:matchday/supabase/supabase.dart';
import 'package:provider/provider.dart';

class GoalButton extends StatelessWidget {
  final String selectedPlayer;

  const GoalButton({super.key, required this.selectedPlayer});

  @override
  Widget build(BuildContext context) {
    // Access required providers
    final matchStatsProvider =
        Provider.of<SelectedMatchStats>(context, listen: false);
    final saveActionProvider =
        Provider.of<SaveActionToSupabase>(context, listen: false);
    final userInfoProvider = Provider.of<UserInfo>(context, listen: false);

    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          try {
            // Set save action properties
            saveActionProvider.matchCode = matchStatsProvider.matchCode;
            saveActionProvider.teamCode = userInfoProvider.teamCode;
            saveActionProvider.matchEventTime =
                matchEventTime; // Set match time
            saveActionProvider.matchHalf = matchHalf; // Set match half
            saveActionProvider.selectedPlayer = selectedPlayer;
            saveActionProvider.eventAction = 'Goal';

            // Update match stats based on selected player
            if (selectedPlayer == 'Opposition') {
              matchStatsProvider.incrementOppScore();
              matchStatsProvider.incrementOppGoalXG();

              // Close the popup after the goal is logged
              Navigator.pop(context);

              // Optional: Implement an alert or logic for goal confirmation
              _showGoalAlert(context);
            } else if (selectedPlayer.isNotEmpty) {
              matchStatsProvider.incrementTeamScore();
              matchStatsProvider.incrementTeamGoalXG();

              // Close the popup after the goal is logged
              Navigator.pop(context);

              // Trigger AssistPopup if the goal is for the team
              AssistPopup.showAssistSelection(
                context,
                fetchPlayers, // Provide the fetchPlayers method
                (context) {
                  // Optional: Implement an alert or logic for goal confirmation
                  _showGoalAlert(context);
                },
              );
            }

            // Save the action to Supabase
            await saveActionProvider.saveAction();
          } catch (error) {
            // Show error feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save action: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Goal',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

_showGoalAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Lottie.network(
          'https://lottie.host/d54d9150-ac67-4459-97ef-b1fe425588e8/tbWIw0RMUe.json',
          width: 300,
          height: 300,
        ),
      );
    },
  );
}
