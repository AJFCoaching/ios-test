import 'package:flutter/material.dart';
import 'package:matchday/pages/normal_pages/home_page.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/register.dart';
import 'package:matchday/supabase/notifier/next_event.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  List? eventList;

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content(),
    );
  }

  Widget content() {
    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.redAccent,
          child: Padding(
            padding: const EdgeInsets.only(top: 70, bottom: 50),
            child: SizedBox(
              height: 150,
              width: 150,
              child: Image.asset("assets/main_logo.png"),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _loginFormKey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Text(
                  'SIGN IN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Enter email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.red[50],
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'User Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter User Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Enter password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.red[50],
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (_loginFormKey.currentState!.validate()) {
                      try {
                        // Login attempt
                        final response = await supabase.auth.signInWithPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        if (response.user == null) {
                          showErrorDialog('Error', 'Invalid email or password');
                        } else {
                          // Fetch user data
                          final data = await supabase
                              .from('profiles')
                              .select()
                              .eq('id', response.user!.id)
                              .single();

                          // Access the UserInfo provider to update user details
                          final userInfo =
                              Provider.of<UserInfo>(context, listen: false);
                          userInfo.updateUser(
                            userID: data['id'],
                            userName: data['full_name'],
                            role: data['user_type'],
                            teamCode: data['team_code'],
                            teamName: data['team_name'],
                            season: data['current_season'],
                          );

                          // Link to the NextMatch provider here
                          final nextMatchData =
                              Provider.of<NextEvent>(context, listen: false);

                          if (eventList != null && eventList!.isNotEmpty) {
                            // Extract the first event from the eventList
                            final firstEvent = eventList![0];

                            // Set next match data using the first event
                            nextMatchData.setNextEventData(
                              eventType: firstEvent['Type'] ?? '',
                              eventDate: firstEvent['event_date'] ?? '',
                              eventTime: firstEvent['time'] ?? '',
                              eventOpp: firstEvent['Opp'] ?? '',
                            );
                          }

                          // Navigate to HomePage
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                          );
                        }
                      } catch (e) {
                        showErrorDialog('Login Error', e.toString());
                      }
                    }
                  },
                ),
                TextButton(
                  child: const Text(
                    'Register an Account Here',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> readData() async {
    final response = await supabase
        .from('fixtures')
        .select()
        .gte('date', DateTime.now())
        .isFilter('completed', false)
        .limit(1)
        .order('date', ascending: true);

    setState(() {
      eventList = response.toList();
    });
  }

  Future<void> showErrorDialog(String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
