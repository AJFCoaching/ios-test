import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterTeamPage extends StatefulWidget {
  const RegisterTeamPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterTeamPageState createState() => _RegisterTeamPageState();
}

class _RegisterTeamPageState extends State<RegisterTeamPage> {
  final teamController = TextEditingController();
  final userNameController = TextEditingController();

  bool _loading = true; // Control the loading state
  String _roleValue = 'Player'; // Initialize role value
  String _seasonValue = '2024'; // Initialize season value
  String selectedEvent = '';

  @override
  void initState() {
    super.initState();
    _getProfile(); // Fetch profile data on initialization
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    teamController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    final userInfo = Provider.of<UserInfo>(context);
    setState(() {
      _loading = true;
    });

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userInfo.userID) // Use the correct `userID`
          .single();

      userNameController.text = (data['full_name'] ?? '') as String;
      teamController.text = (data['team_name'] ?? '') as String;
    } on PostgrestException catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected Error Occurred'),
          backgroundColor: Colors.red,
        ),
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
    final userType = _roleValue.toString(); // Use initialized role value
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'full_name': username,
      'team_name': teamName,
      'user_type': userType,
      'current_season': _seasonValue, // Use initialized season value
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('profiles').upsert(updates);

      if (mounted) {
        // Access UserInfo ChangeNotifier and update user data
        final userInfo = Provider.of<UserInfo>(context, listen: false);
        userInfo.updateUser(
          userID: user.id,
          teamCode: teamName,
          userName: username,
          role: userType,
          season: _seasonValue,
          teamName: teamName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully Updated Profile!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on PostgrestException catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // UI Components
  Widget userNameTextBox() {
    return TextField(
      controller: userNameController,
      decoration: const InputDecoration(labelText: 'User Name'),
    );
  }

  Widget teamNameTextBox() {
    return TextField(
      controller: teamController,
      decoration: const InputDecoration(labelText: 'Team Name'),
    );
  }

  Widget roleDropDownBox() {
    return DropdownButton<String>(
      value: _roleValue,
      items: ['Player', 'Coach', 'Manager'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _roleValue = newValue!;
        });
      },
    );
  }

  Widget roleSeasonSelectDropDownBox() {
    return DropdownButton<String>(
      value: _seasonValue,
      items:
          ['2023', '2024', '2025', '2026', '2027', '2028'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _seasonValue = newValue!;
        });
      },
    );
  }

  Widget confirmButton() {
    return ElevatedButton(
      onPressed: _updateProfile, // Update profile data
      child: const Text('Confirm'),
    );
  }

  Widget deleteButton() {
    return ElevatedButton(
      onPressed: () {
        // Logic for deleting the profile, if necessary
      },
      child: const Text('Delete Profile'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Team')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                children: [
                  userNameTextBox(),
                  const SizedBox(height: 15),
                  teamNameTextBox(),
                  const SizedBox(height: 15),
                  roleDropDownBox(),
                  const SizedBox(height: 15),
                  roleSeasonSelectDropDownBox(),
                  const SizedBox(height: 100),
                  confirmButton(),
                  const SizedBox(height: 10),
                  deleteButton(),
                ],
              ),
      ),
    );
  }
}
