import 'package:flutter/material.dart';
import 'package:focus_flow/app.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await NotificationService.checkExactAlarmPermission();

  await Hive.initFlutter();
  await Hive.openBox('settings');

  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox('focus');
  await Hive.openBox<UserModel>('user');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const FocusFlowApp(),
    ),
  );
}