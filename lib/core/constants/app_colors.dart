import 'package:flutter/material.dart';

/// Centralized color palette used across the app's light & dark themes.
/// Keeping colors here avoids magic hex values scattered across widgets.
class AppColors {
  AppColors._(); // Prevents instantiation - this class only holds static constants.

  // Brand color used for buttons, active icons, FAB, etc.
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF8B84FF);

  // Light theme surface colors.
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1E1E1E);

  // Dark theme surface colors.
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFF5F5F5);

  // Shared semantic colors.
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color noteCardColor = Color(0xFFFFF8E1);
  static const Color noteCardColorDark = Color(0xFF2A2A1E);

  // Default text colors used by the Poppins text-style helpers in
  // core/theme/app_text_styles.dart.
  static const Color blackColor = Color(0xFF1E1E1E);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Color(0xFF9E9E9E);
}
