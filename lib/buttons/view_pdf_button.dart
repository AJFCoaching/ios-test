import 'package:flutter/material.dart';
import 'package:matchday/pages/coach/save_as_pdf.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:provider/provider.dart';

class ViewPDFButton extends StatelessWidget {
  const ViewPDFButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      onPressed: () async {
        final matchStatsProvider =
            Provider.of<SelectedMatchStats>(context, listen: false);
        final matchDataProvider = Provider.of<MatchAdd>(context, listen: false);

        final selectedMatchCode = matchDataProvider.matchCode;

        matchStatsProvider.isLoading = true;

        await matchStatsProvider.fetchSelectedMatchStats(selectedMatchCode);

        if (!matchStatsProvider.hasError &&
            matchStatsProvider.matchStats != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaveAsPDFPage(
                matchStats: matchStatsProvider.matchStats!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching match stats')),
          );
        }

        matchStatsProvider.isLoading = false;
      },
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('View PDF'),
    );
  }
}
