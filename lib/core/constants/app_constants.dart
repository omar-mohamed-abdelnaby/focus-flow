/// App-wide constants for FocusFlow
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FocusFlow';
  static const String appVersion = '1.0.0';

  // Default Timer Values (in minutes)
  static const int defaultPomodoroMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultReminderMinutes = 10;

  // Pomodoro Settings
  static const int minPomodoroMinutes = 1;
  static const int maxPomodoroMinutes = 60;
  static const int minBreakMinutes = 1;
  static const int maxBreakMinutes = 30;

  // Task Priorities
  static const String priorityHigh = 'High';
  static const String priorityMedium = 'Medium';
  static const String priorityLow = 'Low';

  static const List<String> taskPriorities = [
    priorityHigh,
    priorityMedium,
    priorityLow,
  ];

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Asset Paths
  static const String audioBeepPath = 'audio/beep.mp3';
  static const String appIconPath = 'assets/icons/app_icon.png';

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
}
