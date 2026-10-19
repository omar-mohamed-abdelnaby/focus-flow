/// Notification configuration for FocusFlow
class NotificationConfig {
  NotificationConfig._();

  // Notification Channels
  static const String taskChannelId = 'task_reminders';
  static const String taskChannelName = 'Task Reminders';
  static const String taskChannelDescription = 'Notifications for task reminders';

  static const String focusChannelId = 'focus_sessions';
  static const String focusChannelName = 'Focus Sessions';
  static const String focusChannelDescription = 'Notifications for focus timer';

  // Notification IDs
  static const int focusCompleteNotificationId = 1;
  static const int breakCompleteNotificationId = 2;
  static const int taskReminderBaseId = 1000; // Task reminders start from 1000

  // Notification Messages
  static const String focusCompleteTitle = '🎯 Focus Session Complete!';
  static const String focusCompleteBody = 'Great work! Time for a break.';

  static const String breakCompleteTitle = '✅ Break Complete!';
  static const String breakCompleteBody = 'Ready to focus again?';

  static const String taskReminderTitle = '📋 Task Reminder';
  static String taskReminderBody(String taskTitle) =>
      'Don\'t forget: $taskTitle';
}
