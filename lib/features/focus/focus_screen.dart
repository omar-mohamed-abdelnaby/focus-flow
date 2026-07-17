import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int selectedMinutes = 25;
  int breakMinutes = 5;

  late int initialSeconds = selectedMinutes * 60;
  late int secondsLeft = initialSeconds;

  bool isBreak = false;
  bool isRunning = false;

  Timer? timer;
  final AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> playBeep() async {
    try {
      await player.stop();
      await player.play(AssetSource('audio/beep.mp3'));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _updateInitialTimeIfPristine() {
    // تحديث الشاشة فوراً إذا لم يكن المؤقت قد بدأ العد التنازلي بعد
    if (secondsLeft == initialSeconds) {
      initialSeconds = (isBreak ? breakMinutes : selectedMinutes) * 60;
      secondsLeft = initialSeconds;
    }
  }

  Future<void> startTimer() async {
    FocusScope.of(context).unfocus();

    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (secondsLeft > 0) {
        setState(() => secondsLeft--);
        return;
      }

      timer.cancel();
      await playBeep();
      await _handleSessionCompletion();
    });
  }

  Future<void> _handleSessionCompletion() async {
    if (!isBreak) {
      // تسجيل جلسة التركيز
      final focusBox = Hive.box('focus');
      int sessions = focusBox.get('sessions', defaultValue: 0);
      focusBox.put('sessions', sessions + 1);
      int minutes = focusBox.get('minutes', defaultValue: 0);
      focusBox.put('minutes', minutes + selectedMinutes);
    }

    setState(() {
      isRunning = false;
    });

    final proceedToNext = await _showCompletionSheet(isBreakFinished: isBreak);

    if (!mounted) return;

    setState(() {
      if (proceedToNext == true) {
        isBreak = !isBreak; // التبديل بين نوع الجلسة
      }
      initialSeconds = (isBreak ? breakMinutes : selectedMinutes) * 60;
      secondsLeft = initialSeconds;
    });

    if (proceedToNext == true) {
      startTimer();
    }
  }

  Future<bool?> _showCompletionSheet({required bool isBreakFinished}) async {
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isBreakFinished ? "☕" : "🎉", style: const TextStyle(fontSize: 55)),
                const SizedBox(height: 15),
                Text(
                  isBreakFinished ? "Break Finished" : "Focus Completed",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  isBreakFinished
                      ? "Ready for another focus session?"
                      : "You finished $selectedMinutes minutes.\nTake a short break?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(isBreakFinished ? "Start Focus" : "Start Break"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Later"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isBreak = false;
      initialSeconds = selectedMinutes * 60;
      secondsLeft = initialSeconds;
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Focus Timer"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- شارة الحالة (Status Badge) ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBreak ? Colors.green.withOpacity(.15) : const Color(0xFF4F46E5).withOpacity(.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: isBreak ? Colors.green : const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBreak ? "Break Session" : "Focus Session",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBreak ? Colors.green : const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- عرض المؤقت (Timer Display) ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: initialSeconds > 0 ? (initialSeconds - secondsLeft) / initialSeconds : 0,
                        strokeWidth: 9,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          isBreak ? Colors.green : const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isBreak ? Icons.coffee : Icons.timer,
                          size: 45,
                          color: isBreak ? Colors.green : const Color(0xFF4F46E5),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          formatTime(secondsLeft),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isBreak ? "Enjoy your break ☕" : "Stay Focused 🎯",
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 45),

                // --- الإعدادات (Settings) ---
                const Text("Pomodoro Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Column(
                  children: [
                    const Text("Focus Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: isRunning || selectedMinutes <= 1
                              ? null
                              : () => setState(() {
                            selectedMinutes = (selectedMinutes - 1).clamp(1, 180);
                            _updateInitialTimeIfPristine();
                          }),
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 20),
                        Text("$selectedMinutes min", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        IconButton.filled(
                          onPressed: isRunning || selectedMinutes >= 180
                              ? null
                              : () => setState(() {
                            selectedMinutes = (selectedMinutes + 1).clamp(1, 180);
                            _updateInitialTimeIfPristine();
                          }),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text("Break Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: isRunning || breakMinutes <= 1
                              ? null
                              : () => setState(() {
                            breakMinutes = (breakMinutes - 1).clamp(1, 60);
                            _updateInitialTimeIfPristine();
                          }),
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 20),
                        Text("$breakMinutes min", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        IconButton.filled(
                          onPressed: isRunning || breakMinutes >= 60
                              ? null
                              : () => setState(() {
                            breakMinutes = (breakMinutes + 1).clamp(1, 60);
                            _updateInitialTimeIfPristine();
                          }),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- أزرار التحكم (Controls) ---
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: isRunning ? null : startTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start"),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: isRunning ? pauseTimer : null,
                        icon: const Icon(Icons.pause),
                        label: const Text("Pause"),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: (isRunning || secondsLeft != initialSeconds) ? resetTimer : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Reset"),
                      ),
                    ),
                    if (isBreak)
                      SizedBox(
                        width: 140,
                        child: FilledButton.icon(
                          onPressed: () {
                            timer?.cancel();
                            setState(() {
                              isBreak = false;
                              isRunning = false;
                              initialSeconds = selectedMinutes * 60;
                              secondsLeft = initialSeconds;
                            });
                          },
                          icon: const Icon(Icons.skip_next),
                          label: const Text("Skip"),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}