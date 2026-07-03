import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Handles the Login form: validation, submission state, and navigation
/// on success. Delegates the actual "authentication" to [AuthService].
class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Form key lets us trigger validation on all fields at once via `formKey.currentState!.validate()`.
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive flags driving the UI: spinner on the button, show/hide password.
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    // Validate() returns false and shows field errors if inputs are invalid - bail out early.
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // Returns null on success, or a user-facing message on failure
      // (e.g. "Invalid email or password", "Network error...").
      final errorMessage = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (errorMessage == null) {
        SnackbarUtil.success(AppStrings.loginSuccess);
        Get.offAllNamed(Routes.home);
      } else {
        SnackbarUtil.error(errorMessage);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose text controllers to free resources when this controller is removed.
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
