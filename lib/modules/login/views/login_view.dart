import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/import_to_export.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

/// Login screen. Currently backed by a mock [AuthService] - swap the
/// controller's `login()` implementation for Firebase Auth without
/// touching this view.
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 72, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(AppStrings.loginTitle, textAlign: TextAlign.center, style: boldPoppins(26)),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: regularPoppins(14, textColor: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(controller: controller.emailController, label: AppStrings.email, keyboardType: TextInputType.emailAddress, validator: Validators.email),
                  const SizedBox(height: 16),
                  // Obx rebuilds just the password field when visibility is toggled.
                  Obx(
                    () => CustomTextField(
                      controller: controller.passwordController,
                      label: AppStrings.password,
                      obscureText: !controller.isPasswordVisible.value,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Obx rebuilds just the button to show/hide the loading spinner.
                  Obx(() => CustomButton(label: AppStrings.login, isLoading: controller.isLoading.value, onPressed: controller.login)),
                  const SizedBox(height: 16),
                  // Only a user who registered here can log in - this link is
                  // the only way to create an account (see RegisterController.register).
                  TextButton(
                    onPressed: () async {
                      // Register returns the just-registered email via Get.back(result: ...)
                      // so we can pre-fill the login form for convenience.
                      final registeredEmail = await Get.toNamed(Routes.register);
                      if (registeredEmail != null) {
                        controller.emailController.text = registeredEmail;
                      }
                    },
                    child: Text.rich(
                      TextSpan(
                        text: '${AppStrings.dontHaveAccount} ',
                        style: regularPoppins(14, textColor: Colors.grey.shade700),
                        children: [
                          TextSpan(
                            text: AppStrings.registerNow,
                            style: semiboldPoppins(14, textColor: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
