import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/save_match_action.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class ShotOnTargetButton extends StatelessWidget {
  final String selectedPlayer; // Pass selected player from parent widget

  const ShotOnTargetButton({
    super.key,
    required this.selectedPlayer,
  });

  @override
  Widget build(BuildContext context) {
    // Access the match event provider
    final matchEventProvider =
        Provider.of<SelectedMatchStats>(context, listen: false);
    final saveActionProvider =
        Provider.of<SaveActionToSupabase>(context, listen: true);
    final userInfoProvider = Provider.of<UserInfo>(context, listen: true);

    // Button
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          try {
            // Accessing saveActionProvider for saving event details
            saveActionProvider.matchCode = matchEventProvider.matchCode;
            saveActionProvider.teamCode = userInfoProvider.teamCode;
            saveActionProvider.matchEventTime =
                matchEventTime; // or any time you wish to log
            saveActionProvider.matchHalf =
                matchHalf; // or use a specific value if needed
            saveActionProvider.selectedPlayer = selectedPlayer;
            saveActionProvider.eventAction = 'Shot On Target';

            // Handle score updates
            if (selectedPlayer == 'Opposition') {
              matchEventProvider.incrementOppShotOnXG();
            } else if (selectedPlayer.isNotEmpty) {
              matchEventProvider.incrementTeamShotOnXG();
            }

            // Save action to Supabase

            await saveActionProvider.saveAction();

            // Close the popup
            Navigator.of(context).pop();
          } catch (error) {
            // Log or show an error message
            print('Error saving action: $error');

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
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Shot On Target',
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
