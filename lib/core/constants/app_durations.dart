/// Duration constants for animations and timers
class AppDurations {
  AppDurations._();

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // UI Feedback
  static const Duration snackBarShort = Duration(seconds: 2);
  static const Duration snackBarNormal = Duration(seconds: 3);
  static const Duration snackBarLong = Duration(seconds: 5);

  // Debounce & Throttle
  static const Duration debounceShort = Duration(milliseconds: 300);
  static const Duration debounceMedium = Duration(milliseconds: 500);
  static const Duration debounceLong = Duration(milliseconds: 1000);

  // Timer Intervals
  static const Duration timerTick = Duration(seconds: 1);
  static const Duration autoSaveInterval = Duration(seconds: 5);

  // Splash Screen
  static const Duration splashDuration = Duration(seconds: 2);
}
