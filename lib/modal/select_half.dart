import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/home_page.dart';
import 'package:matchday/supabase.dart';

class SelectHalfModal extends StatefulWidget {
  const SelectHalfModal({Key? key}) : super(key: key);

  @override
  State<SelectHalfModal> createState() => _SelectHalfModalState();
}

class _SelectHalfModalState extends State<SelectHalfModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(height: 20),

          Row(
            children: [
              Spacer(),

              // 1st half
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    matchHalf = '1st Half';
                  });
                },
                child: Text('1st Half'),
              ),

              Spacer(),

              //2nd half
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    matchHalf = '2nd Half';

//                    matcHalfLength = fixtureMins;

                    print(matcHalfLength);
                    print(matchEventMin.toString());
                    print(matchEventTime);
                  });
                },
                child: Text('2nd Half'),
              ),

              Spacer(),
            ],
          ),

          SizedBox(height: 30),

          //end match
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showMatchResult(context),
            child: Text('End Match'),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showMatchResult(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Row(children: [
              Spacer(),
              Text(
                'MATCH RESULT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
            ]),
            content: Row(
              children: [
                Spacer(),

                // button 1
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  child: Text('Win'),
                  onPressed: () {
                    setState(() {
                      matchResult = 'Win';
                    });
                    saveFixtureToSupabase();
                    saveFixtureStatsToSupabase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                    print(matchCode);
                    print(oppTeam);
                    print(teamcounter);
                    print(oppcounter);
                    print(teamShotOn);
                    print(oppShotOn);
                    print(teamShotOff);
                    print(oppShotOff);
                    print(teamPass);
                    print(oppPass);
                    print(teamTackle);
                    print(oppTackle);
                    print(teamOffside);
                    print(oppOffside);
                  },
                ),

                Spacer(),

                // button 2
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: Text('Lost'),
                  onPressed: () {
                    setState(() {
                      matchResult = 'Lost';
                    });
                    saveFixtureToSupabase();
                    saveFixtureStatsToSupabase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                ),

                Spacer(),
                // button 3
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white),
                  child: Text('Draw'),
                  onPressed: () {
                    setState(() {
                      matchResult = 'Draw';
                    });
                    saveFixtureToSupabase();
                    saveFixtureStatsToSupabase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                ),
              ],
            ));
      },
    );
  }
}
