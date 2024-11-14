// event_popup.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matchday/buttons/goalButton.dart'; // Import custom goal button widget
import 'package:matchday/buttons/player_swap.dart';
import 'package:matchday/buttons/shot_on.dart'; // Import custom shot on target button widget
import 'package:matchday/buttons/shot_off.dart'; // Import custom shot off target button widget

class EventPopup extends StatelessWidget {
  final String matchEventTime;
  final String selectedPlayer;
  final String selectedPlayerPosition;

  const EventPopup({
    super.key,
    required this.matchEventTime,
    required this.selectedPlayer,
    required this.selectedPlayerPosition,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'EVENT',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      content: SizedBox(
        height: 500,
        width: 300,
        child: Column(
          children: [
            Text(
              matchEventTime,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              selectedPlayer,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Team Goal Button
            GoalButton(
                selectedPlayer: selectedPlayer), // onPressed is optional here

            const SizedBox(height: 40),
            // Team Shot On Target Button
            ShotOnTargetButton(selectedPlayer: selectedPlayer),
            const SizedBox(height: 40),
            // Team Shot Off Target Button
            ShotOffTargetButton(selectedPlayer: selectedPlayer),

            const SizedBox(height: 40),
            SwapPlayerButton(
                selectedPlayer: selectedPlayer,
                selectedPlayerPosition: selectedPlayerPosition),
          ],
        ),
      ),
    );
  }
}

// Function to show the popup
void showEventPopup(BuildContext context, String matchEventTime,
    String selectedPlayer, String selectedPlayerPosition, String matchCode) {
  showDialog(
    context: context,
    builder: (context) => EventPopup(
      matchEventTime: matchEventTime,
      selectedPlayer: selectedPlayer,
      selectedPlayerPosition: selectedPlayerPosition,
    ),
  );
}

// Function to show the goal alert animation
void _showGoalAlert(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // Automatically close the alert after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) Navigator.of(context).pop();
      });

      return AlertDialog(
        content: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.network(
            'https://lottie.host/d54d9150-ac67-4459-97ef-b1fe425588e8/tbWIw0RMUe.json',
            fit: BoxFit.contain,
          ),
        ),
      );
    },
  );
}
