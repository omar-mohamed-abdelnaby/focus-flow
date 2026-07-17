import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main/main_screen.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final userBox = Hive.box<UserModel>('user');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              userBox.isEmpty ? const WelcomeScreen() : const MainScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.track_changes,
              size: 90,
              color: Color(0xff4F46E5),
            ).animate().fade(duration: 800.ms).scale(),

            const SizedBox(height: 20),

            const Text(
              "FocusFlow",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ).animate().fade(delay: 400.ms),

            const SizedBox(height: 10),

            const Text(
              "Stay Focused. Stay Productive.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ).animate().fade(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}
