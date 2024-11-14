import 'package:flutter/material.dart';
import 'package:matchday/pages/normal_pages/home_page.dart';
import 'package:matchday/pages/normal_pages/login.dart';
import 'package:matchday/main.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: content(),
      ),
    );
  }

  Widget content() {
    return Column(
      children: [
        pageHeader(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              children: [
                textHeader(),
                const SizedBox(height: 20),
                registerEmail(),
                const SizedBox(height: 20),
                password1(),
                const SizedBox(height: 20),
                password2(),
                const SizedBox(height: 20),
                registerUserButton(context),
                const SizedBox(height: 10),
                returnToLogIn(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget pageHeader() {
    return Container(
      width: double.infinity,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 70, 0, 10),
        child: SizedBox(
          height: 70,
          width: 70,
          child: Image.asset("assets/main_logo.png"),
        ),
      ),
    );
  }

  Widget textHeader() {
    return const Text(
      'REGISTER',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }

  Widget registerEmail() {
    return TextFormField(
      controller: emailController,
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
        labelText: 'Email',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget password1() {
    return TextFormField(
      controller: passwordController,
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
      obscureText: true, // Hide the password
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget password2() {
    return TextFormField(
      controller: password2Controller,
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
        labelText: 'Confirm Password',
      ),
      obscureText: true, // Hide the password
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget registerUserButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text(
        'Register User',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            // Sign up user with Supabase
            final response = await supabase.auth.signUp(
              email: emailController.text,
              password: passwordController.text,
            );

            if (response.user != null) {
              // Access the UserInfo provider and update the data
              final userInfo = Provider.of<UserInfo>(context, listen: false);
              userInfo.userID = response.user!.id;
              userInfo.userName = userNameController.text;

              // Notify listeners about the change
              userInfo.notifyListeners();

              // You can also save other user data to the UserInfo ChangeNotifier if needed
            }

            // Handle successful registration (e.g., navigate to another page)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } catch (e) {
            // Handle sign up error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error registering user: $e')),
            );
          }
        }
      },
    );
  }

  Widget returnToLogIn() {
    return TextButton(
      child: const Text(
        'Return to Log-In page',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
        );
      },
    );
  }

  final snackbarError = const SnackBar(
    content: Text('Error with Registration, please check details'),
  );

  final snackbarReg = const SnackBar(
    content: Text('Registration Complete'),
  );
}
