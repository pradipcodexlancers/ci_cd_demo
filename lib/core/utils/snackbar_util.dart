import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// Wraps `Get.snackbar` so every screen shows feedback in a consistent style
/// without duplicating snackbar styling code everywhere.
class SnackbarUtil {
  SnackbarUtil._();

  static void success(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  static void error(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
