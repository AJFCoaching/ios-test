import 'package:flutter/material.dart';
import 'package:matchday/custom_loader.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/add_old_match.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:matchday/widgets/goal_scorers.dart';
import 'package:provider/provider.dart';
// Custom loader widget

class MatchStatsPage extends StatefulWidget {
  const MatchStatsPage({super.key});

  @override
  State<MatchStatsPage> createState() => _MatchStatsPageState();
}

class _MatchStatsPageState extends State<MatchStatsPage> {
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
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _matchStatsData(), // Display match stats
          const SizedBox(height: 10),
          _addMatchEventButton(context), // Button for adding match actions
          const SizedBox(height: 10),
          Goalscorers(), // Display goal scorers
        ],
      ),
    );
  }

  Widget _matchStatsData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
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
                _teamNames(context), // Display team names
                const SizedBox(height: 5),
                // Displaying match stats with consistent formatting
                _scoreRow(
                  _formatStat(matchStatsProvider.teamScore),
                  'GOALS',
                  _formatStat(matchStatsProvider.oppScore),
                ),
                const SizedBox(height: 5),
                _scoreRow(
                  _formatStat(matchStatsProvider.teamXG),
                  'xG',
                  _formatStat(matchStatsProvider.oppXG),
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

  Widget _addMatchEventButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        _resetEventStates();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddPreviousMatchDataPage(),
          ),
        );
      },
      icon: const Icon(Icons.person_add),
      label: const Text('Add Match Actions'),
    );
  }

  void _resetEventStates() {
    setState(() {
      prevEventAction = '';
      prevEventPlayerAssistSelect = '';
      prevEventPlayerSelect = '';
      prevEventHalf = '1st Half';
    });
  }

  String _formatStat(dynamic stat) {
    if (stat == null) return '0.00'; // Default formatting for null values
    return double.tryParse(stat.toString())?.toStringAsFixed(2) ?? '0.00';
  }
}
