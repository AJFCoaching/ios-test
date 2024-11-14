import 'package:flutter/material.dart';
import 'package:matchday/modal/player_swap_popup.dart';
import 'package:matchday/pages/coach/match_v3/basic_match_v3.dart';
import 'package:matchday/supabase/notifier/player_swap_notifier.dart';
import 'package:provider/provider.dart';

class SwapPlayerButton extends StatelessWidget {
  final String selectedPlayer;
  final String selectedPlayerPosition;

  const SwapPlayerButton({
    super.key,
    required this.selectedPlayer,
    required this.selectedPlayerPosition,
  });

  @override
  Widget build(BuildContext context) {
    final swapPlayerProvider =
        Provider.of<PlayerSwapProvider>(context, listen: false);

    // button
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          swapPlayerProvider.selectedPlayer = selectedPlayer;
          swapPlayerProvider.selectedPlayerPosition = selectedPlayerPosition;
          swapPlayerProvider.fetchSubstitutes(matchCode);
          showDialog(
            context: context,
            builder: (context) => ChangeNotifierProvider.value(
              value: swapPlayerProvider,
              child: const PlayerSwapPopup(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Swap Players',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
