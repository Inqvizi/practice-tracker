import 'package:flutter/material.dart';

/// Centralized color palette matching the Figma design system for Practice Tracker.
abstract final class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF41607A);
  static const Color primaryDark = Color(0xFF34536A);
  static const Color primaryLight = Color(0xFF4A6D85);

  // Background & Surfaces
  static const Color background = Color(0xFFF0F4F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE3E9EE);
  static const Color inputBorder = Color(0xFF9FB1C1);

  // Navigation & Interactive
  static const Color sidebarActive = Color(0xFFD3E4F2);
  static const Color chipBackground = Color(0xFFD3E4F2);
  static const Color chipText = Color(0xFF41607A);

  // Typography
  static const Color textPrimary = Color(0xFF121A21);
  static const Color textSecondary = Color(0xFF5C6B78);
  static const Color textHint = Color(0xFF8B98A4);
  static const Color textLight = Color(0xFFFFFFFF);

  // Statuses
  static const Color statusDoneBackground = Color(0xFFD5EDE0);
  static const Color statusDoneText = Color(0xFF2E6B4A);
  static const Color statusProgressBackground = Color(0xFFF6E7B0);
  static const Color statusProgressText = Color(0xFF7A5B00);

  // Alerts & Actions
  static const Color danger = Color(0xFFC0392B);
  static const Color dangerLight = Color(0xFFFCEBEB);
  static const Color success = Color(0xFF2E6B4A);
  static const Color notificationDot = Color(0xFFE74C3C);
}
