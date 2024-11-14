import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class BottomButtons extends StatelessWidget {
  final StopWatchTimer stopWatchTimer;
  final String matchHalf;
  final int matchHalfLength;
  final Function onHalfSelected;
  final bool click;
  final Function(bool) toggleClick;
  final Function(String) updateEventAction;
  final Function(double) updateMatchEventTime;

  const BottomButtons({
    required this.stopWatchTimer,
    required this.matchHalf,
    required this.matchHalfLength,
    required this.onHalfSelected,
    required this.click,
    required this.toggleClick,
    required this.updateEventAction,
    required this.updateMatchEventTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 120,
        decoration: const BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                Column(
                  children: [
                    // Start/Stop button
                    IconButton(
                      iconSize: 45,
                      onPressed: () {
                        if (click) {
                          // Reset the timer to 0 first
                          stopWatchTimer.onResetTimer();

                          // Check which half is selected and set the timer
                          if (matchHalf == '2nd Half') {
                            stopWatchTimer.setPresetMinuteTime(matchHalfLength);
                          } else {
                            stopWatchTimer
                                .setPresetMinuteTime(0); // 1st Half starts at 0
                          }

                          // Start the timer after resetting and setting the correct time
                          stopWatchTimer.onStartTimer();
                          updateEventAction('Start');
                        } else {
                          // Stop timer logic
                          stopWatchTimer.onStopTimer();
                          final matchEventTime = stopWatchTimer.minuteTime.value
                              .toDouble(); // Extract timer value as double
                          updateMatchEventTime(matchEventTime);
                          updateEventAction('End');
                        }

                        // Toggle click state
                        toggleClick(!click);
                      },
                      icon: Icon(
                        (click == true) ? Icons.play_circle : Icons.stop_circle,
                        color: (click == true)
                            ? Colors.green
                            : Colors.red, // Green for play, red for stop
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Select Half Button
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => onHalfSelected(),
                      child: const Text('Select Half'),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
