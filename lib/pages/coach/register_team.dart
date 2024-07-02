import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterTeamPage extends StatefulWidget {
  @override
  _RegisterTeamPageState createState() => _RegisterTeamPageState();
}

class _RegisterTeamPageState extends State<RegisterTeamPage> {
  final teamController = TextEditingController();
  final userNameController = TextEditingController();

  // ignore: unused_field
  var _loading = true;

  String selectedEvent = '';

  // ignore: unused_element
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final data =
          await supabase.from('profiles').select().eq('id', userID).single();
      userNameController.text = (data['full_name'] ?? '') as String;
      teamController.text = (data['team_name'] ?? '') as String;
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected Error Occurred'),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final username = userNameController.text;
    final teamName = teamController.text;
    final userType = _roleValue.toString();
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'full_name': username,
      'team_name': teamName,
      'user_type': userType,
      'current_season': _seasonValue,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        const SnackBar(
          content: Text('Successfully Updated Profile!'),
        );
      }
    } on PostgrestException catch (error) {
      SnackBar(content: Text(error.message), backgroundColor: Colors.red);
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    userNameController.dispose();
    teamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      header(),
      SizedBox(height: 10),
      title(),
      SizedBox(height: 20),
      userNameTextBox(),
      SizedBox(height: 15),
      teamNameTextBox(),
      SizedBox(height: 15),
      roleDropDownBox(),
      SizedBox(height: 15),
      roleSeasonSelectDropDownBox(),
      SizedBox(height: 100),
      confirmButton(),
      SizedBox(height: 10),
      deleteButton(),
      SizedBox(height: 10),
    ]);
  }

  var _roleValue = 'Coach';
  var _seasonValue = '2024/25';

  Widget header() {
    return Container(
      height: 75,
      width: double.infinity,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          height: 50,
          width: 50,
          child: Image.asset("assets/main_logo.png"),
        ),
      ),
    );
  }

  Widget title() {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
        child: Column(children: [
          Text(
            'REGISTER YOUR TEAM',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }

  Widget userNameTextBox() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: userNameController,
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
            labelText: 'Your Name'),
      ),
    );
  }

  Widget teamNameTextBox() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: teamController,
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
            labelText: 'Team Name'),
      ),
    );
  }

  Widget roleDropDownBox() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: DropdownButtonFormField(
        value: _roleValue,
        items: [
          DropdownMenuItem(child: Text('Coach'), value: 'Coach'),
          DropdownMenuItem(child: Text('Parent'), value: 'Parent'),
          DropdownMenuItem(child: Text('Player'), value: 'Player'),
        ],
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
            labelText: 'Role'),
        onChanged: (value) {},
      ),
    );
  }

  Widget roleSeasonSelectDropDownBox() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: DropdownButtonFormField(
        value: _seasonValue,
        items: [
          DropdownMenuItem(child: Text('2024/25'), value: '2024/25'),
          DropdownMenuItem(child: Text('2025/26'), value: '2025/26'),
          DropdownMenuItem(child: Text('2026/27'), value: '2026/27'),
          DropdownMenuItem(child: Text('2027/28'), value: '2027/28'),
          DropdownMenuItem(child: Text('2028/29'), value: '2028/29'),
          DropdownMenuItem(child: Text('2029/30'), value: '2029/30'),
        ],
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
            labelText: 'Select Season'),
        onChanged: (value) {
          setState(() {
            currentSeasonDate = _seasonValue;
          });
        },
      ),
    );
  }

  Widget confirmButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: _loading ? null : _updateProfile,
      child: Text(_loading ? 'Saving...' : 'Update'),
    );
  }

  Widget deleteButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        await supabase.from('squad').delete().match({'team_code': teamCode});

        await supabase.from('profiles').delete().match({'team_code': teamCode});

        await supabase
            .from('match_actions')
            .delete()
            .match({'team_code': teamCode});

        await supabase.from('fixtures').delete().match({'team_code': teamCode});

        await supabase
            .from('fixture_stats')
            .delete()
            .match({'team_code': teamCode});

        await supabase
            .from('event_attendance')
            .delete()
            .match({'team_code': teamCode});

        await supabase.from('Users').delete().match({'email': userEmail});
      },
      child: Text(
        'DELETE ACCOUT',
      ),
    );
  }
}
