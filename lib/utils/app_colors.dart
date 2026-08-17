import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF3B82F6);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF64748B);

  static const Color error = Color(0xFFEF4444);
  static const Color divider = Color(0xFFE2E8F0);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );
}
