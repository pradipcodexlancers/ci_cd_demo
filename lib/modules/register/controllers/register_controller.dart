import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../services/auth_service.dart';

/// Handles the Register form: validation, submission state, and navigating
/// back to Login (with the new email pre-filled) once an account is created.
///
/// This is the only way an account enters [AuthService]'s registered-users
/// table, so Login can only ever succeed for someone who registered here first.
class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      // Returns null on success, or a user-facing message on failure
      // (e.g. "This email is already registered").
      final errorMessage = await _authService.register(
        name: nameController.text,
        email: email,
        password: passwordController.text,
      );

      if (errorMessage == null) {
        // Pop back to Login first, handing the new email back so it can be
        // pre-filled - see LoginView's `Get.toNamed<String>(Routes.register)`.
        // The success snackbar is shown *after* popping (not before) because
        // GetX's snackbar overlay and Get.back() conflict when triggered in
        // the same frame - showing the snackbar first can silently swallow
        // both the popup and the navigation.
        Get.back(result: email);
        SnackbarUtil.success(AppStrings.registerSuccess);
      } else {
        SnackbarUtil.error(errorMessage);
      }
    } catch (_) {
      SnackbarUtil.error(AppStrings.genericAuthError);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
