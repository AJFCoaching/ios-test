import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class AddPlayerModal extends StatefulWidget {
  const AddPlayerModal({super.key});

  @override
  State<AddPlayerModal> createState() => _AddPlayerModalState();
}

class _AddPlayerModalState extends State<AddPlayerModal> {
  Future<void> savePlayerDataToSupabase() async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);
    final playerUpdates = {
      'team_code': userInfo.teamCode,
      'player_name': addPlayerName,
      'player_short': playerShort
    };
    await supabase.from('squad').upsert(playerUpdates);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.blue[50],
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 300,
          child: Column(children: [
            titleText(),
            const SizedBox(height: 20),
            playerNameTextBox(),
            const SizedBox(height: 30),
            playerInitalsTextBox(),
            const Spacer(),
            submitButton(),
            const SizedBox(height: 10)
          ]),
        ));
  }

  Widget titleText() {
    return const Text(
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
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
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
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
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
          Future.delayed(const Duration(seconds: 2), () {
            savePlayerDataToSupabase();
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          });
        },
        child: const Text('Submit'));
  }
}
