import 'package:flutter/material.dart';
import 'package:focus_flow/features/main/main_screen.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final nameController = TextEditingController();
  String goal = "Study";

  // قائمة المهام مع الأيقونات الخاصة بها لتصميم بطاقات مخصصة
  final List<Map<String, dynamic>> _goals = [
    {"title": "Study", "icon": Icons.menu_book_rounded},
    {"title": "Work", "icon": Icons.work_outline_rounded},
    {"title": "Personal", "icon": Icons.self_improvement_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // تم إزالة الـ AppBar التقليدي لتوفير مساحة وتصميم عصري (Clean Look)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الرئيسي والنص الفرعي
              Text(
                "Welcome to\nFocusFlow 👋",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Let's set up your profile to personalize your productivity journey.",
                style: TextStyle(
                  fontSize: 16,
                  color: scheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // حقل الاسم
              _buildTextField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person_outline_rounded,
                scheme: scheme,
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // قسم اختيار الهدف
              Text(
                "What's your main goal?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // بطاقات الأهداف المخصصة بدلاً من RadioListTile
              Column(
                children: _goals.map((g) => _buildGoalCard(g, scheme)).toList(),
              ),

              const SizedBox(height: 40),

              // زر المتابعة (Continue)
              SizedBox(
                width: double.infinity,
                height: 56, // جعل الزر أكبر ليكون سهل الضغط
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _onContinue,
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت مخصصة لحقول الإدخال لتكون متناسقة مع باقي التطبيق
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme scheme,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: scheme.onSurface),
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: scheme.onSurface.withOpacity(0.5)),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.onSurface.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }

  // ويدجت مخصصة لبطاقات الأهداف (بديل للـ Radio)
  Widget _buildGoalCard(Map<String, dynamic> goalData, ColorScheme scheme) {
    final isSelected = goal == goalData["title"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => goal = goalData["title"]),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary.withOpacity(0.1) : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.onSurface.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                goalData["icon"],
                color: isSelected ? scheme.primary : scheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Text(
                goalData["title"],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? scheme.primary : scheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: scheme.primary)
              else
                Icon(Icons.circle_outlined, color: scheme.onSurface.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your name",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // حفظ بيانات المستخدم في Hive
    final box = Hive.box<UserModel>('user');

    await box.clear();

    await box.add(
      UserModel(
        name: nameController.text.trim(),
        goal: goal,
      ),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }
}