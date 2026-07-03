import '../constants/app_strings.dart';

/// Shared form-field validators used by GetX-driven `TextFormField`s.
/// Returning `null` means the field is valid (standard Flutter convention).
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.\-]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    return null;
  }

  /// Returns a validator bound to [passwordController]'s current text, so the
  /// Confirm Password field can check it matches the Password field live.
  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) {
      if (value == null || value.isEmpty) {
        return AppStrings.confirmPasswordRequired;
      }
      if (value != password()) {
        return AppStrings.passwordMismatch;
      }
      return null;
    };
  }

  static String? noteTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.titleRequired;
    }
    return null;
  }
}
