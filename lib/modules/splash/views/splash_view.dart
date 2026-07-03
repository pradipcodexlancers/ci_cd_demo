import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/import_to_export.dart';
import '../controllers/splash_controller.dart';

/// First screen shown on app launch. Purely presentational -
/// all navigation logic lives in [SplashController.onInit].
// ignore: must_be_immutable
class SplashView extends StatelessWidget {
  SplashView({super.key});
  SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_rounded, size: 96, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: boldPoppins(28, textColor: AppColors.whiteColor),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.splashTagline,
              style: regularPoppins(14, textColor: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
