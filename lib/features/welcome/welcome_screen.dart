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

  final emailController = TextEditingController();

  String goal = "Study";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome"), centerTitle: true),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              const Text(
                "Welcome to FocusFlow 👋",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Goal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              RadioListTile(
                title: const Text("Study"),
                value: "Study",
                groupValue: goal,
                onChanged: (value) {
                  setState(() {
                    goal = value!;
                  });
                },
              ),

              RadioListTile(
                title: const Text("Work"),
                value: "Work",
                groupValue: goal,
                onChanged: (value) {
                  setState(() {
                    goal = value!;
                  });
                },
              ),

              RadioListTile(
                title: const Text("Personal"),
                value: "Personal",
                groupValue: goal,
                onChanged: (value) {
                  setState(() {
                    goal = value!;
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your name")),
                      );

                      return;
                    }

                    final box = Hive.box<UserModel>('user');

                    await box.add(
                      UserModel(
                        name: nameController.text.trim(),

                        email: emailController.text.trim(),

                        goal: goal,
                      ),
                    );

                    if (!mounted) return;

                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
