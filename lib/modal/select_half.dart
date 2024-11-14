import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/home_page.dart';
import 'package:matchday/supabase/notifier/selected_match_stats.dart';
import 'package:provider/provider.dart';

class SelectHalfModal extends StatefulWidget {
  const SelectHalfModal({super.key});

  @override
  State<SelectHalfModal> createState() => _SelectHalfModalState();
}

class _SelectHalfModalState extends State<SelectHalfModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Row(
            children: [
              const Spacer(),

              // 1st half
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    matchHalf = '1st Half';
                  });
                },
                child: const Text('1st Half'),
              ),

              const Spacer(),

              //2nd half
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    matchHalf = '2nd Half';

//                    matcHalfLength = fixtureMins;
                  });
                },
                child: const Text('2nd Half'),
              ),

              const Spacer(),
            ],
          ),

          const SizedBox(height: 30),

          //end match
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showMatchResult(context),
            child: const Text('End Match'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showMatchResult(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(children: [
              Spacer(),
              Text(
                'MATCH RESULT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
            ]),
            content: Row(
              children: [
                const Spacer(),

                // button 1
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  child: const Text('Win'),
                  onPressed: () {
                    final matchStats =
                        Provider.of<SelectedMatchStats>(context, listen: false);
                    setState(() {
                      matchResult = 'Win';
                    });
                    matchStats.saveMatchResultToSupabase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const HomePage()),
                    );
                  },
                ),

                const Spacer(),

                // button 2
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: const Text('Lost'),
                  onPressed: () {
                    final matchStats =
                        Provider.of<SelectedMatchStats>(context, listen: false);
                    setState(() {
                      matchResult = 'Lost';
                    });
                    matchStats.saveMatchResultToSupabase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const HomePage()),
                    );
                  },
                ),

                const Spacer(),
                // button 3
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white),
                  child: const Text('Draw'),
                  onPressed: () {
                    final matchStats =
                        Provider.of<SelectedMatchStats>(context, listen: false);
                    setState(() {
                      matchResult = 'Draw';
                    });
                    matchStats.saveMatchResultToSupabase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const HomePage()),
                    );
                  },
                ),
              ],
            ));
      },
    );
  }
}
