import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/import_to_export.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/profile_controller.dart';

/// Displays the logged-in user's info and provides the logout action.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.profile)),
      body: Obx(() {
        final user = controller.user.value;
        // user should never be null here since this screen is only reachable
        // while logged in, but guard defensively against a race on logout.
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: boldPoppins(36, textColor: AppColors.whiteColor),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: boldPoppins(
                  22,
                  textColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.whiteColor
                      : AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(user.email, style: regularPoppins(14, textColor: Colors.grey.shade600)),
              const SizedBox(height: 40),
              CustomButton(
                label: AppStrings.logout,
                icon: Icons.logout,
                onPressed: controller.logout,
              ),
            ],
          ),
        );
      }),
    );
  }
}
