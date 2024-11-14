// lib/widgets/current_score.dart

import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class CurrentScore extends StatelessWidget {
  const CurrentScore({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfo>(context);

    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
// Section A
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userInfo.teamName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.red,
                      width: 5,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    children: [
                      // Consumer to display team score
                      Consumer<SelectedMatchStats>(
                        builder: (context, matchStats, child) {
                          return Text(
                            '${matchStats.teamScore}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                          height: 5), // Add some spacing between score and xG
                      // Consumer to display team xG
                      Consumer<SelectedMatchStats>(
                        builder: (context, matchStats, child) {
                          return Text(
                            'xG: ${matchStats.teamXG.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .white, // Use white to match score styling
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Section B
          const Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'vs',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Section C
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userInfo.teamName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.blue,
                      width: 5,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    children: [
                      // Consumer to display team score
                      Consumer<SelectedMatchStats>(
                        builder: (context, matchStats, child) {
                          return Text(
                            '${matchStats.oppScore}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                          height: 5), // Add some spacing between score and xG
                      // Consumer to display team xG
                      Consumer<SelectedMatchStats>(
                        builder: (context, matchStats, child) {
                          return Text(
                            'xG: ${matchStats.oppXG.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .white, // Use white to match score styling
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
