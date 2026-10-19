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

    // يفضل زيادة الوقت قليلاً (مثلاً 2.5 ثانية) لكي تكتمل الحركات بسلاسة قبل الانتقال
    Future.delayed(const Duration(milliseconds: 2500), () {
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
    // استدعاء الـ ColorScheme لضمان التوافق مع الوضعين الفاتح والداكن
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تحسين شكل الأيقونة بوضعها داخل دائرة شفافة بلون الـ Primary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes_rounded, // استخدام النسخة الدائرية (rounded) لشكل أحدث
                size: 80,
                color: scheme.primary,
              ),
            )
                .animate()
                .fade(duration: 800.ms, curve: Curves.easeOut)
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack), // إضافة تأثير ارتداد خفيف (Back)

            const SizedBox(height: 24),

            // تحسين تنسيق العنوان (Font Weight & Letter Spacing)
            Text(
              "FocusFlow",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: scheme.onSurface, // يتغير حسب الثيم (أبيض في الداكن، أسود في الفاتح)
              ),
            )
                .animate()
                .fade(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut), // إضافة تأثير انزلاق من الأسفل

            const SizedBox(height: 12),

            // تحسين تنسيق النص الفرعي
            Text(
              "Stay Focused. Stay Productive.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withOpacity(0.6), // استخدام شفافية بدلاً من لون رمادي ثابت
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fade(delay: 700.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}