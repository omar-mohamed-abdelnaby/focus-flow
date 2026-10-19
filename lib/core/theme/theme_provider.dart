import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeNotifier extends ChangeNotifier {
  final Box settingsBox = Hive.box('settings');

  ThemeMode get themeMode {
    final mode = settingsBox.get('themeMode', defaultValue: 'system');

    switch (mode) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      default:
        return ThemeMode.system;
    }
  }

  void setTheme(ThemeMode mode) {
    String value = "system";

    if (mode == ThemeMode.light) {
      value = "light";
    } else if (mode == ThemeMode.dark) {
      value = "dark";
    }

    settingsBox.put("themeMode", value);

    notifyListeners();
  }
}