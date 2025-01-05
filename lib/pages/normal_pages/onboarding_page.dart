import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController =
      PageController(); // Controller for the PageView
  int _currentPage = 0; // Tracks the current page index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // PageView for onboarding screens
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Update the current page index
                  });
                },
                itemCount: demoData.length,
                itemBuilder: (context, index) {
                  return OnboardContent(
                    illustration: demoData[index]['illustration'] ?? "",
                    title: demoData[index]['title'] ?? "",
                    text: demoData[index]['text'] ?? "",
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            // Page indicator (dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                demoData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 20 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.pink : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // "Get Started" button
            ElevatedButton(
              onPressed: () {
                // Handle navigation to the next screen
                Navigator.pushNamed(context, '/login'); // Example route
              },
              child: Text(
                'Get Started'.toUpperCase(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String illustration, title, text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(illustration),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

List<Map<String, String>> demoData = [
  {
    'illustration': "assets/main_logo.png",
    'title': "Welcome to MatchDay",
    'text': "All your team's stats in one place",
  },
  {
    'illustration': "assets/tactics.png",
    'title': "Create Your Team",
    'text': "Manage players, tactics, and more. All in the palm of your hand",
  },
  {
    'illustration': "assets/Soccer_Field.png",
    'title': "Different Plans for different needs",
    'text': "What plan do you need?",
  },
];
