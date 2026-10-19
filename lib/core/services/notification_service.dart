import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminder_channel_v2',
        'Task Reminder',
        channelDescription: 'Task notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('task_reminder'),
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'focus_timer_channel',
        'Focus Timer',
        description: 'Shows the running FocusFlow timer',
        importance: Importance.low,
      ),
    );
    tz.initializeTimeZones();

    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {}
  }
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    );

    print("Now       : ${tz.TZDateTime.now(tz.local)}");
    print("Scheduled : $scheduledDate");

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print("ERROR: Scheduled time is in the past");
      return;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel_v2',
          'Task Reminder',
          channelDescription: 'Task notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('task_reminder'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
      payload: id.toString(),
    );

    print("Notification scheduled successfully");
  }

  static Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'FocusFlow',
      'Test notification',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel_v2',
          'Task Reminder',
          channelDescription: 'Task notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('task_reminder'),
        ),
      ),
    );
  }

  static Future<void> testNotification() async {
    await showTestNotification();
  }

  static Future<void> checkExactAlarmPermission() async {
    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final canSchedule =
    await androidPlugin?.canScheduleExactNotifications();

    print("Can schedule exact notifications: $canSchedule");
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> showFocusTimerNotification({
    required String title,
    required String timeRemaining,
  }) async {
    await _notifications.show(
      1001,
      title,
      '$timeRemaining remaining',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_timer_channel',
          'Focus Timer',
          channelDescription: 'Shows the running FocusFlow timer',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: false,
          category: AndroidNotificationCategory.progress,
        ),
      ),
    );
  }

  static Future<void> cancelFocusTimerNotification() async {
    await _notifications.cancel(1001);
  }

}