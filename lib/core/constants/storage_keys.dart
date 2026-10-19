/// Storage keys for Hive boxes and preferences
class StorageKeys {
  StorageKeys._();

  // Box Names
  static const String tasksBox = 'tasks';
  static const String userBox = 'user';
  static const String settingsBox = 'settings';
  static const String focusBox = 'focus';

  // Settings Keys
  static const String pomodoroMinutesKey = 'pomodoroMinutes';
  static const String shortBreakMinutesKey = 'shortBreakMinutes';
  static const String longBreakMinutesKey = 'longBreakMinutes';
  static const String autoStartBreaksKey = 'autoStartBreaks';
  static const String autoStartPomodorosKey = 'autoStartPomodoros';
  static const String notificationsEnabledKey = 'notificationsEnabled';
  static const String soundEnabledKey = 'soundEnabled';
  static const String themeModeKey = 'themeMode';
  static const String biometricEnabledKey = 'biometricEnabled';

  // User Keys
  static const String userNameKey = 'userName';
  static const String userStreakKey = 'userStreak';
  static const String userTotalTasksKey = 'userTotalTasks';
  static const String userCompletedTasksKey = 'userCompletedTasks';

  // Focus Session Keys
  static const String totalFocusSessionsKey = 'totalFocusSessions';
  static const String totalFocusTimeKey = 'totalFocusTime';
  static const String todayFocusSessionsKey = 'todayFocusSessions';
  static const String lastSessionDateKey = 'lastSessionDate';
}
