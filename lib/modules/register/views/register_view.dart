import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/import_to_export.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../controllers/register_controller.dart';

/// Registration screen. Only accounts created here can subsequently log in
/// via [LoginView] - see [AuthService.register] / [AuthService.login].
class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.registerTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add_alt_1, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: regularPoppins(14, textColor: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: controller.nameController,
                    label: AppStrings.name,
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: controller.emailController,
                    label: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  // Obx rebuilds just this field when its visibility icon is tapped.
                  Obx(
                    () => CustomTextField(
                      controller: controller.passwordController,
                      label: AppStrings.password,
                      obscureText: !controller.isPasswordVisible.value,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextField(
                      controller: controller.confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      // Reads the password field live, so editing either field re-checks the match.
                      validator: Validators.confirmPassword(() => controller.passwordController.text),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Obx rebuilds just the button to show/hide the loading spinner.
                  Obx(
                    () => CustomButton(
                      label: AppStrings.register,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.register,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text.rich(
                      TextSpan(
                        text: '${AppStrings.alreadyHaveAccount} ',
                        style: regularPoppins(14, textColor: Colors.grey.shade700),
                        children: [
                          TextSpan(
                            text: AppStrings.loginNow,
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
