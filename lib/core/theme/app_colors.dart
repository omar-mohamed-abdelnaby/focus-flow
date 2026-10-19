import 'package:flutter/material.dart';

/// App color palette for FocusFlow
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Accent Colors
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentLight = Color(0xFF22D3EE);
  static const Color accentDark = Color(0xFF0891B2);

  // Task Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityLow = Color(0xFF10B981); // Green

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors (Light Theme)
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Neutral Colors (Dark Theme)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
    Color(0xFF06B6D4), // Cyan
    Color(0xFF14B8A6), // Teal
  ];

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
  ];

  // Semantic Colors
  static const Color focusActive = Color(0xFFEF4444);
  static const Color breakActive = Color(0xFF10B981);
  static const Color timerPaused = Color(0xFFF59E0B);

  // Helper method to get priority color
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityMedium;
    }
  }
}
