import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:matchday/custom_loader.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:matchday/widgets/goal_scorers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
// Custom loader widget

class MatchStatsPage extends StatefulWidget {
  const MatchStatsPage({super.key});

  @override
  State<MatchStatsPage> createState() => _MatchStatsPageState();
}

class _MatchStatsPageState extends State<MatchStatsPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _saveScreenshot() async {
    try {
      // Capture the screenshot
      final Uint8List? image = await _screenshotController.capture();

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture screenshot')),
        );
        return;
      }

      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/MatchStats_Screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      // Save the image to a file
      final file = File(path);
      await file.writeAsBytes(image);

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Screenshot saved at $path')),
      );

      // Optionally, log the path for debugging
      print('Screenshot saved at: $path');
    } catch (e) {
      print("Screenshot saving error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save screenshot')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchStatsProvider =
          Provider.of<SelectedMatchStats>(context, listen: false);
      final matchCode = Provider.of<MatchAdd>(context, listen: false).matchCode;

      matchStatsProvider.fetchSelectedMatchStats(matchCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MATCH STATS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _saveScreenshot,
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _matchStatsHeader(),
              const SizedBox(height: 10),
              _matchStatsData(), // Display match stats
              const SizedBox(height: 10),
              Goalscorers(), // Display goal scorers
            ],
          ),
        ),
      ),
    );
  }

  Widget _matchStatsHeader() {
    final matchData = Provider.of<MatchAdd>(context);

    return Row(
      children: [
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              matchData.oppTeam,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  matchData.matchType,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Text(
                  matchData.formattedDate,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        Image.asset(
          "assets/main_logo.png",
          height: 80,
          width: 80,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _matchStatsData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        child: Consumer<SelectedMatchStats>(
          builder: (context, matchStatsProvider, child) {
            if (matchStatsProvider.isLoading) {
              return const Center(child: CustomLoader()); // Custom loader
            }

            if (matchStatsProvider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Error fetching match data',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final matchCode =
                            Provider.of<MatchAdd>(context, listen: false)
                                .matchCode;
                        matchStatsProvider.fetchSelectedMatchStats(matchCode);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Spacer(),
                _teamNames(context), // Display team names
                const SizedBox(height: 5),
                _scoreRow(
                  _formatStat(matchStatsProvider.teamScore),
                  'GOALS',
                  _formatStat(matchStatsProvider.oppScore),
                ),
                const SizedBox(height: 5),
                _scoreRow(
                  _formatXG(matchStatsProvider.teamXG),
                  'xG',
                  _formatXG(matchStatsProvider.oppXG),
                ),
                const SizedBox(height: 5),
                _scoreRow(
                  _formatStat(matchStatsProvider.teamShotOn),
                  'SHOT ON TARGET',
                  _formatStat(matchStatsProvider.oppShotOn),
                ),
                const SizedBox(height: 5),
                _scoreRow(
                  _formatStat(matchStatsProvider.teamShotOff),
                  'SHOT OFF TARGET',
                  _formatStat(matchStatsProvider.oppShotOff),
                ),
                Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _scoreRow(String teamStat, String statLabel, String oppStat) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          teamStat,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const Spacer(),
        Text(statLabel),
        const Spacer(),
        Text(
          oppStat,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _teamNames(BuildContext context) {
    final matchData = Provider.of<MatchAdd>(context);
    final userInfo = Provider.of<UserInfo>(context);

    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          userInfo.teamName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const Spacer(),
        Text(
          matchData.oppTeam,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  String _formatStat(dynamic stat) {
    if (stat == null) return '0'; // Default formatting for null values
    return double.tryParse(stat.toString())?.toStringAsFixed(0) ?? '0';
  }

  String _formatXG(dynamic stat) {
    if (stat == null) return '0.00'; // Default formatting for null values
    return double.tryParse(stat.toString())?.toStringAsFixed(2) ?? '0.00';
  }
}
