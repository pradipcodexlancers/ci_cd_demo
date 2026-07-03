import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Exposes the logged-in user's details and the logout action.
class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Reactive so the view updates immediately if the user data ever changes.
  Rxn<UserModel> get user => _authService.currentUser;

  Future<void> logout() async {
    final confirmed = await showConfirmDialog(
      title: AppStrings.logout,
      message: AppStrings.logoutConfirm,
    );
    if (!confirmed) return;

    await _authService.logout();
    // offAllNamed clears the navigation stack so Back can't return to Home post-logout.
    Get.offAllNamed(Routes.login);
  }
}
