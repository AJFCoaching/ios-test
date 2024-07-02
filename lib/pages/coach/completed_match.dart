import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/fixture_page.dart';
import 'package:matchday/supabase.dart';

class CompletedMatchPage extends StatefulWidget {
  const CompletedMatchPage({Key? key}) : super(key: key);

  @override
  State<CompletedMatchPage> createState() => _CompletedMatchPageState();
}

class _CompletedMatchPageState extends State<CompletedMatchPage> {
  void incrementteamCounter() {
    setState(() {
      teamcounter++;
    });
  }

  void decrementteamCounter() {
    setState(() {
      teamcounter--;
    });
  }

  void incrementOppCounter() {
    setState(() {
      oppcounter++;
    });
  }

  void decrementOppCounter() {
    setState(() {
      oppcounter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 10),
            MatchDate(),
            SizedBox(height: 10),
            MatchType(),
            SizedBox(height: 30),
            Container(
              child: Column(
                children: [
                  // top row
                  Row(
                    children: [
                      SizedBox(width: 20),
                      MatchTeam(),
                      Spacer(),
                      TeamReduceButton(),
                      SizedBox(width: 10),
                      Text(
                        '${teamcounter}',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      TeamAddButton(),
                      SizedBox(width: 20)
                    ],
                  ),

                  SizedBox(height: 30),

                  // bottom row
                  Row(
                    children: [
                      SizedBox(width: 20),
                      MatchOpp(),
                      Spacer(),
                      OppReduceButton(),
                      SizedBox(width: 10),
                      Text(
                        '${oppcounter}',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      OppAddButton(),
                      SizedBox(width: 20)
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Spacer(),
                WinButton(),
                Spacer(),
                DrawButton(),
                Spacer(),
                LostButton(),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            if (matchResult != '') ResultText() else SizedBox.shrink(),
            Spacer(),
            submitButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget MatchDate() {
    return Text(
      matchDate,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget MatchType() {
    return Text(
      matchType,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget MatchOpp() {
    return Text(
      oppTeam,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget MatchTeam() {
    return Text(
      teamName,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget TeamAddButton() {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: incrementteamCounter,
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget TeamReduceButton() {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: decrementteamCounter,
          backgroundColor: Colors.red,
          child: Icon(Icons.remove),
        ),
      ),
    );
  }

  Widget OppAddButton() {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: incrementOppCounter,
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget OppReduceButton() {
    return SizedBox(
      width: 20,
      height: 20,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: decrementOppCounter,
          backgroundColor: Colors.red,
          child: Icon(Icons.remove),
        ),
      ),
    );
  }

  Widget WinButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, foregroundColor: Colors.white),
      child: Text('Win'),
      onPressed: () {
        setState(() {
          matchResult = 'Win';
        });
      },
    );
  }

  Widget DrawButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber, foregroundColor: Colors.black),
      child: Text('Draw'),
      onPressed: () {
        setState(() {
          matchResult = 'Draw';
        });
      },
    );
  }

  Widget LostButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, foregroundColor: Colors.white),
      child: Text('Lost'),
      onPressed: () {
        setState(() {
          matchResult = 'Lost';
        });
      },
    );
  }

  Widget ResultText() {
    return Text(
      matchResult,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        savePrevFixtureToSupabase();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FixturePage()),
        );
      },
      child: Text('Sumbit'),
    );
  }
}
