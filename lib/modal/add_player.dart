import 'package:flutter/material.dart';
import 'package:matchday/main.dart';

class AddPlayerModal extends StatefulWidget {
  const AddPlayerModal({Key? key}) : super(key: key);

  @override
  State<AddPlayerModal> createState() => _AddPlayerModalState();
}

class _AddPlayerModalState extends State<AddPlayerModal> {
  Future<void> savePlayerDataToSupabase() async {
    final PlayerUpdates = {
      'team_code': teamCode,
      'player_name': addPlayerName,
      'player_short': playerShort
    };
    await supabase.from('squad').upsert(PlayerUpdates);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.blue[50],
        ),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Container(
          height: 300,
          child: Column(children: [
            titleText(),
            SizedBox(height: 20),
            playerNameTextBox(),
            SizedBox(height: 30),
            playerInitalsTextBox(),
            Spacer(),
            submitButton(),
            SizedBox(height: 10)
          ]),
        ));
  }

  Widget titleText() {
    return Text(
      'ADD PLAYER',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget playerNameTextBox() {
    return TextFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.red[50],
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Player Name'),
        validator: (valuePN) {
          if (valuePN!.isEmpty) {
            return 'Please enter Player Name';
          }
          return null;
        },
        onChanged: (valuePN) {
          setState(() {
            addPlayerName = valuePN;
          });
        });
  }

  Widget playerInitalsTextBox() {
    return TextFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.red[50],
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Player Initials'),
        validator: (valuePS) {
          if (valuePS!.isEmpty) {
            return 'Please enter Player Initials';
          }
          return null;
        },
        onChanged: (valuePS) {
          setState(() {
            playerShort = valuePS;
          });
        });
  }

  Widget submitButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          Future.delayed(Duration(seconds: 2), () {
            savePlayerDataToSupabase();
            Navigator.pop(context);
          });
        },
        child: Text('Submit'));
  }
}
