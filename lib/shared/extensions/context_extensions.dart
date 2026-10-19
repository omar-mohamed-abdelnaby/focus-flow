import 'package:flutter/material.dart';

/// Extension methods for BuildContext
extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  // Color shortcuts
  Color get primaryColor => colorScheme.primary;

  Color get backgroundColor => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colorScheme.surface;

  Color get errorColor => colorScheme.error;

  Color get onPrimaryColor => colorScheme.onPrimary;

  Color get onSurfaceColor => colorScheme.onSurface;

  // Text style shortcuts
  TextStyle? get displayLarge => textTheme.displayLarge;

  TextStyle? get displayMedium => textTheme.displayMedium;

  TextStyle? get displaySmall => textTheme.displaySmall;

  TextStyle? get headlineLarge => textTheme.headlineLarge;

  TextStyle? get headlineMedium => textTheme.headlineMedium;

  TextStyle? get headlineSmall => textTheme.headlineSmall;

  TextStyle? get titleLarge => textTheme.titleLarge;

  TextStyle? get titleMedium => textTheme.titleMedium;

  TextStyle? get titleSmall => textTheme.titleSmall;

  TextStyle? get bodyLarge => textTheme.bodyLarge;

  TextStyle? get bodyMedium => textTheme.bodyMedium;

  TextStyle? get bodySmall => textTheme.bodySmall;

  TextStyle? get labelLarge => textTheme.labelLarge;

  TextStyle? get labelMedium => textTheme.labelMedium;

  TextStyle? get labelSmall => textTheme.labelSmall;

  // Screen size shortcuts
  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  // MediaQuery shortcuts
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  bool get isKeyboardOpen => viewInsets.bottom > 0;

  // Responsive breakpoints
  bool get isMobile => screenWidth < 600;

  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  bool get isDesktop => screenWidth >= 900;

  // Navigation shortcuts
  NavigatorState get navigator => Navigator.of(this);

  void pop<T>([T? result]) => navigator.pop(result);

  Future<T?> push<T>(Route<T> route) => navigator.push(route);

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed(routeName, arguments: arguments);

  Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result}) =>
      navigator.pushReplacement(route, result: result);

  Future<T?> pushReplacementNamed<T, TO>(String routeName, {TO? result, Object? arguments}) =>
      navigator.pushReplacementNamed(routeName, result: result, arguments: arguments);

  // Snackbar shortcuts
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  // Focus shortcuts
  void unfocus() => FocusScope.of(this).unfocus();

  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);
}
