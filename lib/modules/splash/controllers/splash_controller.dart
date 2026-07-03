import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Decides where to send the user after the splash delay:
/// straight to Home if a session was restored, otherwise to Login.
class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // Small artificial delay so the splash branding is actually visible.
    await Future.delayed(const Duration(seconds: 2));

    if (_authService.isLoggedIn) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}
