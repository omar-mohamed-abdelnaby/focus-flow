# FocusFlow - Step-by-Step Implementation Guide

## 🎯 Overview

This guide provides a detailed migration path from the current structure to a professional, maintainable architecture. Follow these phases in order.

---

## 📊 Current State Analysis

**Key Issues Found:**
- ❌ 1023-line settings_screen.dart (too large)
- ❌ Unused services (hive_service.dart, task_service.dart with mock data)
- ❌ Inconsistent service locations (lib/services/ and lib/core/services/)
- ❌ No routing abstraction (25+ Navigator.push calls)
- ❌ Magic numbers and strings scattered throughout
- ❌ Direct Hive access in UI widgets
- ❌ Mixed Arabic/English comments
- ❌ Debug print() calls in production code
- ❌ No proper state management for business logic
- ❌ GoRouter in pubspec but not implemented

---

## 🚀 Phase 1: Core Infrastructure Setup (Day 1)

### Step 1.1: Constants & Configuration ✅ DONE

Already created:
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/app_dimensions.dart`
- `lib/core/constants/app_durations.dart`
- `lib/core/constants/app_strings.dart`
- `lib/core/constants/storage_keys.dart`
- `lib/core/constants/index.dart`

### Step 1.2: Theme Enhancement ✅ DONE

Already created:
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_text_styles.dart`

**TODO:** Update existing theme files:

```dart
// lib/core/theme/app_theme.dart - NEEDS UPDATE
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    // Add text theme, card theme, etc.
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
  );
}
```

### Step 1.3: Extensions ✅ DONE

Already created:
- `lib/shared/extensions/context_extensions.dart`
- `lib/shared/extensions/date_time_extensions.dart`
- `lib/shared/extensions/string_extensions.dart`
- `lib/shared/extensions/index.dart`

---

## 🗂️ Phase 2: Service Layer Cleanup (Day 1-2)

### Step 2.1: Remove Unused Services

```bash
# Delete these files:
rm lib/services/hive_service.dart  # Unused
rm lib/services/task_service.dart  # Contains mock data, never used
```

### Step 2.2: Consolidate Services

**Move notification service:**
```bash
# Current: lib/core/services/notification_service.dart
# Target:  lib/services/notification_service.dart

mkdir -p lib/services
mv lib/core/services/notification_service.dart lib/services/
rmdir lib/core/services
```

**Clean up notification service:**
- Replace `print()` with proper logging or remove debug statements
- Extract constants to `lib/core/config/notification_config.dart` ✅ DONE
- Add error handling

### Step 2.3: Create Storage Service

Create `lib/services/storage_service.dart`:
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/core/constants/storage_keys.dart';

/// Abstraction layer for Hive storage operations
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Boxes
  Box<T> getBox<T>(String boxName) => Hive.box<T>(boxName);
  
  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(StorageKeys.settingsBox);
    await box.put(key, value);
  }

  T getSetting<T>(String key, T defaultValue) {
    final box = Hive.box(StorageKeys.settingsBox);
    return box.get(key, defaultValue: defaultValue) as T;
  }

  // Add more helper methods as needed
}
```

---

## 🧭 Phase 3: Routing Implementation (Day 2-3)

### Step 3.1: Create Router Configuration

Create `lib/core/routing/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:focus_flow/features/splash/splash_screen.dart';
import 'package:focus_flow/features/welcome/welcome_screen.dart';
import 'package:focus_flow/features/main/main_screen.dart';
import 'package:focus_flow/features/tasks/add_task_screen.dart';
// Import other screens

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => const AddTaskScreen(),
      ),
      // Add more routes
    ],
  );
}
```

### Step 3.2: Create Route Names

Create `lib/core/routing/route_names.dart`:

```dart
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String main = '/main';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String settings = '/settings';
  // Add more routes
}
```

### Step 3.3: Update app.dart

```dart
import 'package:flutter/material.dart';
import 'package:focus_flow/core/theme/app_theme.dart';
import 'package:focus_flow/core/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:focus_flow/core/theme/theme_provider.dart';

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeNotifier>().themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
```

### Step 3.4: Replace Navigator.push Calls

Search and replace across all files:
```dart
// Old:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
);

// New:
context.push('/add-task');
// or
context.pushNamed(RouteNames.addTask);
```

---

## 🏗️ Phase 4: Repository Pattern (Day 3-4)

### Step 4.1: Create Task Repository

Create `lib/features/tasks/data/task_repository.dart`:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/core/constants/storage_keys.dart';

class TaskRepository {
  final Box<TaskModel> _taskBox;

  TaskRepository() : _taskBox = Hive.box<TaskModel>(StorageKeys.tasksBox);

  // Get all tasks
  List<TaskModel> getAllTasks() {
    return _taskBox.values.toList();
  }

  // Get pending tasks
  List<TaskModel> getPendingTasks() {
    return _taskBox.values.where((task) => !task.isCompleted).toList();
  }

  // Get completed tasks
  List<TaskModel> getCompletedTasks() {
    return _taskBox.values.where((task) => task.isCompleted).toList();
  }

  // Add task
  Future<void> addTask(TaskModel task) async {
    await _taskBox.add(task);
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  // Delete task
  Future<void> deleteTask(TaskModel task) async {
    await task.delete();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    await task.save();
  }

  // Get tasks by priority
  List<TaskModel> getTasksByPriority(String priority) {
    return _taskBox.values
        .where((task) => task.priority == priority)
        .toList();
  }

  // Get today's tasks
  List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    return _taskBox.values.where((task) {
      return task.dueDate.year == now.year &&
          task.dueDate.month == now.month &&
          task.dueDate.day == now.day;
    }).toList();
  }

  // Stream of tasks (for real-time updates)
  Stream<List<TaskModel>> watchTasks() {
    return _taskBox.watch().map((_) => getAllTasks());
  }
}
```

---

## 🎨 Phase 5: State Management (Day 4-5)

### Step 5.1: Create Task Provider

Create `lib/features/tasks/providers/task_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/features/tasks/data/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider(this._repository) {
    loadTasks();
  }

  // Getters
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  List<TaskModel> get pendingTasks => 
      _tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => 
      _tasks.where((t) => t.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get completedCount => completedTasks.length;
  double get progress => 
      _tasks.isEmpty ? 0 : completedCount / _tasks.length;

  // Load tasks
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = _repository.getAllTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add task
  Future<void> addTask(TaskModel task) async {
    try {
      await _repository.addTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete task
  Future<void> deleteTask(TaskModel task) async {
    try {
      await _repository.deleteTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Toggle completion
  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      await _repository.toggleTaskCompletion(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### Step 5.2: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:focus_flow/app.dart';
import 'package:focus_flow/services/notification_service.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/core/theme/theme_provider.dart';
import 'package:focus_flow/features/tasks/providers/task_provider.dart';
import 'package:focus_flow/features/tasks/data/task_repository.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(TaskRepository()),
        ),
        // Add more providers as needed
      ],
      child: const FocusFlowApp(),
    ),
  );
}
```

---

## 📦 Phase 6: Refactor Large Screens (Day 5-6)

### Step 6.1: Break Down SettingsScreen

The 1023-line settings_screen.dart needs to be split:

**Create widget files:**
- `lib/features/settings/presentation/widgets/settings_section.dart`
- `lib/features/settings/presentation/widgets/settings_tile.dart`
- `lib/features/settings/presentation/widgets/theme_selector.dart`
- `lib/features/settings/presentation/widgets/pomodoro_settings.dart`

**Create provider:**
- `lib/features/settings/providers/settings_provider.dart`

### Step 6.2: Refactor FocusScreen

Extract timer logic:
- `lib/features/focus/providers/timer_provider.dart` - Timer state & logic
- `lib/features/focus/presentation/widgets/timer_display.dart` - Timer UI
- `lib/features/focus/presentation/widgets/timer_controls.dart` - Control buttons
- `lib/services/audio_service.dart` - Audio player wrapper

---

## 🧹 Phase 7: Clean Up & Polish (Day 6-7)

### Step 7.1: Update Imports

Use barrel files for cleaner imports:

```dart
// Old:
import 'package:focus_flow/features/widgets/stat_card.dart';
import 'package:focus_flow/features/widgets/progress_card.dart';
import 'package:focus_flow/features/widgets/streak_card.dart';

// New:
import 'package:focus_flow/shared/widgets/index.dart';
```

### Step 7.2: Remove Debug Code

- Remove all `print()` statements
- Remove or translate Arabic comments
- Remove commented-out code

### Step 7.3: Update .gitignore

Ensure *.g.dart is properly handled:
```
# Generated Hive files
*.g.dart
```

### Step 7.4: Update README.md

Replace default Flutter README with actual project documentation.

---

## ✅ Phase 8: Testing & Verification (Day 7)

### Step 8.1: Run Code Analysis

```bash
flutter analyze
dart fix --dry-run
dart fix --apply
flutter pub run dart_code_metrics:metrics analyze lib
```

### Step 8.2: Test the App

- [ ] Test all navigation flows
- [ ] Test task CRUD operations
- [ ] Test focus timer
- [ ] Test notifications
- [ ] Test theme switching
- [ ] Test biometric auth
- [ ] Test data persistence

### Step 8.3: Performance Check

```bash
flutter run --profile
# Check for any performance issues
```

---

## 📋 Migration Checklist

### Core Infrastructure
- [x] Create constants files
- [x] Create extensions
- [x] Create theme files
- [ ] Update app_theme.dart with new colors
- [ ] Create theme index.dart barrel file

### Services
- [ ] Remove unused services
- [ ] Consolidate service locations
- [ ] Create storage service abstraction
- [ ] Clean up notification service
- [ ] Create audio service wrapper

### Routing
- [ ] Implement GoRouter
- [ ] Create route names
- [ ] Replace all Navigator.push calls
- [ ] Update app.dart

### Data Layer
- [ ] Create TaskRepository
- [ ] Create UserRepository (if needed)
- [ ] Create FocusSessionRepository (if needed)

### State Management
- [ ] Create TaskProvider
- [ ] Create FocusProvider
- [ ] Create SettingsProvider
- [ ] Update main.dart with MultiProvider

### UI Refactoring
- [ ] Break down SettingsScreen
- [ ] Extract FocusScreen logic
- [ ] Move widgets to proper locations
- [ ] Use context extensions for theme access

### Clean Up
- [ ] Update all imports
- [ ] Remove debug prints
- [ ] Remove Arabic comments
- [ ] Update README.md
- [ ] Run dart fix
- [ ] Test thoroughly

---

## 🎓 Best Practices Going Forward

1. **Feature Independence**: Each feature should be self-contained
2. **No Direct Hive Access in UI**: Always go through repository
3. **Use Providers for State**: Don't manage state in widgets
4. **Constants Over Magic Values**: Use AppConstants, AppColors, etc.
5. **Consistent Imports**: Use barrel files
6. **Proper Error Handling**: Catch and display errors gracefully
7. **Code Reviews**: Review before committing
8. **Write Tests**: At minimum, test repositories and providers

---

## 📚 Additional Resources

- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-clean-architecture)
- [Provider Package Docs](https://pub.dev/packages/provider)
- [GoRouter Package Docs](https://pub.dev/packages/go_router)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)

---

**Estimated Total Time:** 5-7 days for complete migration
**Priority Order:** Phases 1-2-3 are critical, 4-5 improve architecture, 6-7 polish

**Last Updated:** October 19, 2026
