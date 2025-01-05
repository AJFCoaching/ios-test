import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/pages/normal_pages/login.dart';
import 'package:matchday/pages/normal_pages/onboarding_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  // Simulate loading time with a delay

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 10));
    final session = supabase.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Image.asset("assets/main_logo.png"),
          ),
          const SizedBox(
            height: 150,
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
