import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:focus_flow/core/services/notification_service.dart';

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

  late final TextEditingController _focusController;
  late final TextEditingController _breakController;

  @override
  void initState() {
    super.initState();

    final settingsBox = Hive.box('settings');

    selectedMinutes =
        settingsBox.get('pomodoroMinutes', defaultValue: 25);

    breakMinutes =
        settingsBox.get('shortBreakMinutes', defaultValue: 5);

    initialSeconds = selectedMinutes * 60;
    secondsLeft = initialSeconds;

    _focusController =
        TextEditingController(text: selectedMinutes.toString());

    _breakController =
        TextEditingController(text: breakMinutes.toString());
  }

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
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
    if (secondsLeft == initialSeconds) {
      initialSeconds = (isBreak ? breakMinutes : selectedMinutes) * 60;
      secondsLeft = initialSeconds;
    }
  }

  void _updateFocusMinutes(int newMinutes) {
    setState(() {
      selectedMinutes = newMinutes.clamp(1, 180);
      _focusController.text = selectedMinutes.toString();
      _updateInitialTimeIfPristine();
    });
  }

  void _updateBreakMinutes(int newMinutes) {
    setState(() {
      breakMinutes = newMinutes.clamp(1, 60);
      _breakController.text = breakMinutes.toString();
      _updateInitialTimeIfPristine();
    });
  }

  Future<void> startTimer() async {
    FocusScope.of(context).unfocus();
    if (isRunning) return;

    setState(() => isRunning = true);

    // إظهار الإشعار أول ما التايمر يبدأ
    await NotificationService.showFocusTimerNotification(
      title: isBreak ? 'Break Time ☕' : 'Deep Focus 🎯',
      timeRemaining: formatTime(secondsLeft),
    );

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (secondsLeft > 0) {
          setState(() => secondsLeft--);

          // تحديث الوقت في الإشعار
          await NotificationService.showFocusTimerNotification(
            title: isBreak ? 'Break Time ☕' : 'Deep Focus 🎯',
            timeRemaining: formatTime(secondsLeft),
          );

          return;
        }

        timer.cancel();

        // إلغاء إشعار التايمر عند انتهاء الوقت
        await NotificationService.cancelFocusTimerNotification();

        await playBeep();
        await _handleSessionCompletion();
      },
    );
  }

  Future<void> _handleSessionCompletion() async {
    // حفظ إحصائيات جلسة الـ Focus
    if (!isBreak) {
      final focusBox = Hive.box('focus');

      int sessions = focusBox.get('sessions', defaultValue: 0);
      await focusBox.put('sessions', sessions + 1);

      int minutes = focusBox.get('minutes', defaultValue: 0);
      await focusBox.put('minutes', minutes + selectedMinutes);
    }

    if (!mounted) return;

    setState(() {
      isRunning = false;
    });

    // قراءة إعداد Auto-start Breaks
    final settingsBox = Hive.box('settings');
    final bool autoStartBreaks =
    settingsBox.get('autoStartBreaks', defaultValue: false);

    // لو جلسة Focus انتهت و Auto-start Breaks مفعّل
    if (!isBreak && autoStartBreaks) {
      setState(() {
        isBreak = true;
        initialSeconds = breakMinutes * 60;
        secondsLeft = initialSeconds;
      });

      // يبدأ الـ Break تلقائياً
      startTimer();
      return;
    }

    // السلوك العادي لو Auto-start Breaks غير مفعّل
    // أو لو الـ Break نفسه انتهى
    final proceedToNext = await showCompletionSheet(
      isBreakFinished: isBreak,
    );

    if (!mounted) return;

    setState(() {
      if (proceedToNext == true) {
        isBreak = !isBreak;
      }

      initialSeconds =
          (isBreak ? breakMinutes : selectedMinutes) * 60;

      secondsLeft = initialSeconds;
    });

    if (proceedToNext == true) {
      startTimer();
    }
  }

  Future<bool?> showCompletionSheet({required bool isBreakFinished}) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isBreakFinished ? Colors.indigoAccent.withOpacity(0.2) : Colors.tealAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(isBreakFinished ? "💼" : "🎉", style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 24),
                Text(
                  isBreakFinished ? "Break Finished!" : "Focus Completed!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: scheme.onSurface),
                ),
                const SizedBox(height: 12),
                Text(
                  isBreakFinished
                      ? "Ready to dive back into deep work?"
                      : "Awesome job completing $selectedMinutes minutes.\nTime to recharge!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: scheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isBreakFinished ? Colors.indigoAccent : Colors.tealAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      isBreakFinished ? "Start Focus" : "Start Break",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: scheme.onSurface.withOpacity(0.7)),
                    child: const Text("Maybe Later", style: TextStyle(fontSize: 16)),
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

    setState(() {
      isRunning = false;
    });

    NotificationService.cancelFocusTimerNotification();
  }

  void resetTimer() {
    timer?.cancel();

    NotificationService.cancelFocusTimerNotification();

    setState(() {
      isBreak = false;
      initialSeconds = selectedMinutes * 60;
      secondsLeft = initialSeconds;
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isBreak ? Colors.tealAccent : Colors.indigoAccent;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // التعديل الأول: تفتيح الخلفية قليلاً في الوضع الفاتح
    final bgColor = activeColor.withOpacity(isDark ? 0.10 : 0.15);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Pomodoro",
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: scheme.onSurface,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // --- Status Pill ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: activeColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isBreak ? Icons.local_cafe_rounded : Icons.psychology_rounded, size: 20, color: activeColor),
                    const SizedBox(width: 8),
                    Text(
                      isBreak ? "Break Time" : "Deep Focus",
                      style: TextStyle(fontWeight: FontWeight.bold, color: activeColor, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- Main Timer Display ---
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: initialSeconds > 0 ? (initialSeconds - secondsLeft) / initialSeconds : 0,
                      strokeWidth: 12,
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(activeColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatTime(secondsLeft),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBreak ? "Relax & Recharge" : "Stay on task",
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // --- Controls (Play/Pause/Reset) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.refresh_rounded,
                    onTap: (isRunning || secondsLeft != initialSeconds) ? resetTimer : null,
                    color: scheme.onSurface,
                    bgColor: scheme.surface,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: isRunning ? pauseTimer : startTimer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Icon(
                        isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black87,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  if (isBreak)
                    _buildControlButton(
                      icon: Icons.skip_next_rounded,
                      onTap: () {
                        timer?.cancel();
                        setState(() {
                          isBreak = false;
                          isRunning = false;
                          initialSeconds = selectedMinutes * 60;
                          secondsLeft = initialSeconds;
                        });
                      },
                      color: scheme.onSurface,
                      bgColor: scheme.surface,
                    )
                  else
                    const SizedBox(width: 56),
                ],
              ),
              const SizedBox(height: 48),

              // --- Settings Card ---
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.10)
                        : theme.dividerColor,
                    width: 1,
                  ),
                  // التعديل الثالث: إضافة Shadow لبطاقة الإعدادات في الوضع الفاتح
                  boxShadow: isDark
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: scheme.onSurface),
                    ),
                    const SizedBox(height: 24),
                    _buildSettingRow(
                      title: "Focus Time",
                      icon: Icons.track_changes_rounded,
                      color: Colors.indigoAccent,
                      controller: _focusController,
                      value: selectedMinutes,
                      onMinus: () => _updateFocusMinutes(selectedMinutes - 1),
                      onPlus: () => _updateFocusMinutes(selectedMinutes + 1),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);

                        if (parsed != null) {
                          final clampedValue = parsed.clamp(1, 180);

                          setState(() {
                            selectedMinutes = clampedValue;
                            _updateInitialTimeIfPristine();
                          });

                          if (parsed > 180) {
                            _focusController.text = "180";
                            _focusController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _focusController.text.length),
                            );
                          }
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: isDark ? Colors.white.withOpacity(0.1) : theme.dividerColor,
                      ),
                    ),
                    _buildSettingRow(
                      title: "Break Time",
                      icon: Icons.coffee_rounded,
                      color: Colors.tealAccent,
                      controller: _breakController,
                      value: breakMinutes,
                      onMinus: () => _updateBreakMinutes(breakMinutes - 1),
                      onPlus: () => _updateBreakMinutes(breakMinutes + 1),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);

                        if (parsed != null) {
                          final clampedValue = parsed.clamp(1, 60);

                          setState(() {
                            breakMinutes = clampedValue;
                            _updateInitialTimeIfPristine();
                          });

                          if (parsed > 60) {
                            _breakController.text = "60";
                            _breakController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _breakController.text.length),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback? onTap, required Color color, required Color bgColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.3 : 1.0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            // التعديل الثاني: إضافة Border خفيف للزر في الوضع الفاتح
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
            ),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: isRunning || value <= 1 ? null : onMinus,
              icon: const Icon(Icons.remove_circle_outline),
              color: scheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(
              width: 50,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !isRunning,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                onChanged: onChanged,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
            IconButton(
              onPressed: isRunning || value >= (title == "Focus Time" ? 180 : 60) ? null : onPlus,
              icon: const Icon(Icons.add_circle_outline),
              color: scheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }
}