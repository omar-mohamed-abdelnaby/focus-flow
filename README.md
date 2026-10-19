# FocusFlow 🎯

A modern productivity app combining task management with the Pomodoro Technique to help you stay focused and achieve more.

## ✨ Features

- **Task Management**: Create, organize, and track your tasks with priority levels
- **Pomodoro Timer**: Built-in focus timer with customizable work and break intervals
- **Smart Notifications**: Task reminders and timer notifications to keep you on track
- **Statistics & Analytics**: Track your productivity with detailed statistics and charts
- **Dark Mode**: Beautiful themes that work in any lighting condition
- **Biometric Security**: Optional biometric authentication for privacy
- **Offline First**: All data stored locally with Hive for instant access

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.11.5)
- Dart SDK (>=3.11.5)
- Android Studio / VS Code
- Android SDK (for Android) or Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/focus_flow.git
   cd focus_flow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/                          # Core infrastructure
│   ├── constants/                 # App-wide constants
│   ├── theme/                     # Theme configuration
│   ├── config/                    # App configuration
│   ├── routing/                   # Navigation setup
│   └── services/                  # Core services
│
├── shared/                        # Shared resources
│   ├── models/                    # Data models
│   ├── widgets/                   # Reusable widgets
│   └── extensions/                # Dart extensions
│
├── features/                      # Feature modules
│   ├── home/                      # Home dashboard
│   ├── tasks/                     # Task management
│   ├── focus/                     # Pomodoro timer
│   ├── statistics/                # Analytics
│   └── settings/                  # App settings
│
├── services/                      # Business services
└── main.dart                      # App entry point
```

## 🏗️ Architecture

FocusFlow follows a **Clean Architecture** approach with clear separation of concerns:

- **Presentation Layer**: UI widgets and screens
- **Business Logic Layer**: Providers and state management
- **Data Layer**: Repositories and data sources

### Key Technologies

- **State Management**: Provider
- **Local Storage**: Hive
- **Routing**: GoRouter (planned)
- **Notifications**: flutter_local_notifications
- **Charts**: fl_chart
- **Authentication**: local_auth

## 🎨 Design System

- **Material Design 3**: Modern Material You design
- **Custom Theme**: Consistent color palette and typography
- **Responsive**: Adapts to different screen sizes
- **Accessibility**: Built with accessibility in mind

## 📱 Screenshots

[Add screenshots here]

## 🔧 Configuration

### Notification Settings

Edit `lib/core/config/notification_config.dart` to customize notification behavior.

### Theme Customization

Modify `lib/core/theme/app_colors.dart` to change the color scheme.

### Pomodoro Defaults

Update `lib/core/constants/app_constants.dart` for default timer values.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 📦 Building

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Run `flutter analyze` to check for issues

## 📋 Roadmap

- [ ] Implement GoRouter for navigation
- [ ] Add task categories and tags
- [ ] Cloud sync with Firebase
- [ ] Export statistics as PDF
- [ ] Widget support for home screen
- [ ] Multi-language support
- [ ] Custom sound options
- [ ] Long break after 4 pomodoros
- [ ] Task templates

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Omar Elfarhoo** - Initial work - [@omarelfarhoo3112005-eng](https://github.com/omarelfarhoo3112005-eng)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- All open-source package contributors

## 📞 Support

For support, email omar@example.com or create an issue in the repository.

## 🐛 Known Issues

See the [Issues](https://github.com/yourusername/focus_flow/issues) page for known bugs and feature requests.

## 📚 Documentation

- [Project Structure](PROJECT_STRUCTURE.md) - Detailed architecture documentation
- [Implementation Guide](IMPLEMENTATION_GUIDE.md) - Migration and refactoring guide
- [API Documentation](docs/api.md) - Code documentation (coming soon)

---

**Made with ❤️ and Flutter**

*Stay focused. Get things done.*
