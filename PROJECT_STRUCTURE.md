# FocusFlow - Professional Project Structure

## 📋 Current Analysis (Oct 2026)

**Project Type:** Productivity / Focus Timer App
**Tech Stack:** Flutter 3.11.5, Hive, Provider, Local Notifications, Biometric Auth
**Lines of Code:** ~4,500 lines
**Current State:** Functional but needs structural improvements

---

## 🎯 Recommended Professional Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root app widget
│
├── core/                              # Core infrastructure (shared across all features)
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── storage_keys.dart          # Hive box names & keys
│   │   └── durations.dart             # Time constants
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── theme_provider.dart
│   │   ├── app_colors.dart            # Color palette
│   │   └── app_text_styles.dart       # Typography
│   │
│   ├── config/
│   │   ├── app_config.dart            # Environment config
│   │   └── notification_config.dart   # Notification IDs & channels
│   │
│   ├── services/                      # Core services
│   │   ├── storage_service.dart       # Hive abstraction layer
│   │   ├── notification_service.dart
│   │   └── audio_service.dart         # Audio player wrapper
│   │
│   ├── routing/
│   │   ├── app_router.dart            # GoRouter configuration
│   │   └── route_names.dart           # Named routes
│   │
│   └── utils/
│       ├── date_utils.dart
│       ├── validators.dart
│       └── extensions.dart
│
├── shared/                            # Shared across features
│   ├── models/
│   │   ├── task_model.dart
│   │   ├── task_model.g.dart
│   │   ├── user_model.dart
│   │   └── user_model.g.dart
│   │
│   ├── widgets/                       # Reusable widgets
│   │   ├── cards/
│   │   │   ├── stat_card.dart
│   │   │   ├── progress_card.dart
│   │   │   ├── streak_card.dart
│   │   │   └── action_card.dart
│   │   │
│   │   ├── common/
│   │   │   ├── section_title.dart
│   │   │   ├── empty_state.dart
│   │   │   └── loading_indicator.dart
│   │   │
│   │   └── index.dart                 # Barrel file
│   │
│   └── extensions/
│       ├── date_time_extensions.dart
│       ├── context_extensions.dart
│       └── string_extensions.dart
│
└── features/                          # Feature modules
    ├── splash/
    │   └── splash_screen.dart
    │
    ├── welcome/
    │   └── welcome_screen.dart
    │
    ├── home/
    │   ├── presentation/
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   │       └── home_task_tile.dart
    │   └── providers/
    │       └── home_provider.dart
    │
    ├── tasks/
    │   ├── presentation/
    │   │   ├── tasks_screen.dart
    │   │   ├── add_task_screen.dart
    │   │   └── widgets/
    │   │       └── task_card.dart
    │   ├── providers/
    │   │   └── task_provider.dart
    │   └── repositories/
    │       └── task_repository.dart
    │
    ├── focus/
    │   ├── presentation/
    │   │   ├── focus_screen.dart
    │   │   └── widgets/
    │   │       ├── timer_display.dart
    │   │       └── timer_controls.dart
    │   ├── providers/
    │   │   └── focus_provider.dart
    │   └── models/
    │       └── focus_session.dart
    │
    ├── statistics/
    │   ├── presentation/
    │   │   ├── statistics_screen.dart
    │   │   └── widgets/
    │   │       └── statistics_chart.dart
    │   └── providers/
    │       └── statistics_provider.dart
    │
    ├── settings/
    │   ├── presentation/
    │   │   ├── settings_screen.dart
    │   │   └── widgets/
    │   │       ├── settings_section.dart
    │   │       └── settings_tile.dart
    │   └── providers/
    │       └── settings_provider.dart
    │
    └── main_navigation/
        └── main_screen.dart           # Bottom nav wrapper

```

---

## 🔧 Key Improvements

### 1. **Separation of Concerns**
- **Core**: Infrastructure used everywhere (theme, routing, services)
- **Shared**: Reusable across multiple features (widgets, models)
- **Features**: Self-contained feature modules

### 2. **Feature Module Structure**
Each feature follows a consistent pattern:
```
feature/
├── presentation/       # UI layer (screens, widgets)
├── providers/          # State management
├── repositories/       # Data access (optional)
└── models/            # Feature-specific models (optional)
```

### 3. **Import Organization**
```dart
// ✅ Good: Clear, organized imports
import 'dart:async';                                    // Dart SDK
import 'package:flutter/material.dart';                 // Flutter SDK
import 'package:provider/provider.dart';                // External packages
import 'package:focus_flow/core/theme/app_theme.dart';  // Core
import 'package:focus_flow/shared/models/task_model.dart';  // Shared
import '../widgets/timer_display.dart';                 // Relative (same feature)
```

### 4. **Barrel Files (index.dart)**
Create `index.dart` files to simplify imports:
```dart
// shared/widgets/index.dart
export 'cards/stat_card.dart';
export 'cards/progress_card.dart';
export 'common/section_title.dart';
export 'common/empty_state.dart';

// Usage:
import 'package:focus_flow/shared/widgets/index.dart';
```

---

## 📝 Naming Conventions

### Files
- **Screens**: `*_screen.dart` (e.g., `home_screen.dart`)
- **Widgets**: descriptive name (e.g., `task_card.dart`)
- **Providers**: `*_provider.dart` (e.g., `task_provider.dart`)
- **Services**: `*_service.dart` (e.g., `storage_service.dart`)
- **Models**: `*_model.dart` (e.g., `task_model.dart`)
- **Constants**: `app_constants.dart`, `storage_keys.dart`

### Classes
- **Screens**: `HomeScreen`, `TasksScreen`
- **Widgets**: `TaskCard`, `StatCard`
- **Providers**: `TaskProvider`, `FocusProvider`
- **Services**: `StorageService`, `NotificationService`

### Variables
- Use camelCase: `selectedMinutes`, `isCompleted`
- Booleans: prefix with `is`, `has`, `should`
- Private: prefix with underscore `_privateMethod()`

---

## 🚀 Migration Plan

### Phase 1: Core Infrastructure
1. Create `core/constants/` and extract all magic numbers/strings
2. Create `core/config/` for app configuration
3. Move theme files to proper structure
4. Create `core/utils/` and add utility functions

### Phase 2: Shared Resources
1. Keep models in `shared/models/`
2. Reorganize widgets into `shared/widgets/cards/` and `shared/widgets/common/`
3. Create barrel files (`index.dart`)
4. Add extensions in `shared/extensions/`

### Phase 3: Feature Modules
1. Restructure each feature with `presentation/`, `providers/`, `repositories/`
2. Move feature-specific widgets into feature folders
3. Extract business logic from screens to providers
4. Add repository layer for data access

### Phase 4: Routing & Services
1. Implement GoRouter in `core/routing/`
2. Create service abstractions
3. Add dependency injection (if needed)

### Phase 5: Clean Up
1. Remove unused files (old `services/task_service.dart`)
2. Update all imports
3. Run `dart fix --apply`
4. Update `.gitignore` if needed
5. Update README.md

---

## 📚 Best Practices Checklist

- [ ] No business logic in UI widgets
- [ ] Use Provider/ChangeNotifier for state management
- [ ] Repository pattern for data access
- [ ] Constants extracted (no magic numbers/strings)
- [ ] Proper error handling
- [ ] Loading states handled
- [ ] Empty states handled
- [ ] Consistent naming conventions
- [ ] Barrel files for clean imports
- [ ] Comments for complex logic
- [ ] Proper folder structure
- [ ] Feature independence (low coupling)
- [ ] Reusable widgets in shared/
- [ ] Theme consistency
- [ ] Responsive design considerations

---

## 🎨 Code Style Guidelines

### Widget Structure
```dart
class TaskCard extends StatelessWidget {
  // 1. Properties
  final Task task;
  final VoidCallback onTap;

  // 2. Constructor
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return _buildCard(context);
  }

  // 4. Private helper methods
  Widget _buildCard(BuildContext context) {
    // ...
  }
}
```

### State Management Pattern
```dart
class TaskProvider extends ChangeNotifier {
  // Private state
  List<Task> _tasks = [];
  bool _isLoading = false;

  // Public getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  // Public methods
  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.addTask(task);
      _tasks.add(task);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 🔍 Common Issues to Fix

1. **❌ Widgets in wrong location**
   - Current: `features/widgets/` (shared across features)
   - Fix: Move to `shared/widgets/`

2. **❌ Direct Hive access in UI**
   - Current: `Hive.box<TaskModel>('tasks')` in widgets
   - Fix: Abstract behind repository/service layer

3. **❌ No constants file**
   - Current: Magic strings like `'tasks'`, `'settings'` scattered
   - Fix: Create `storage_keys.dart`

4. **❌ Large screen files**
   - Current: `settings_screen.dart` is 1023 lines
   - Fix: Extract widgets and logic to separate files

5. **❌ Mixed import styles**
   - Current: Mix of relative and absolute imports
   - Fix: Follow consistent pattern

6. **❌ No routing abstraction**
   - Current: Direct `Navigator.push` calls
   - Fix: Implement GoRouter

---

## 📖 Additional Resources

- [Flutter Style Guide](https://flutter.dev/docs/development/style-guide)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Last Updated:** October 19, 2026
**Project Version:** 1.0.0+1
