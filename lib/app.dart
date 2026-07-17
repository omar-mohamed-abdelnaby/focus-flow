import 'package:flutter/material.dart';
import 'package:focus_flow/core/theme/app_theme.dart';
import 'package:focus_flow/features/splash/splash_screen.dart';

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}
