import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/storage_service.dart';

/// Controls the app-wide theme (light/dark) and persists the user's choice
/// so it's restored on the next app launch.
class SettingsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Restore the previously saved preference; defaults to light mode.
    isDarkMode.value = _storage.read<bool>(StorageService.keyIsDarkMode) ?? false;
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    Get.changeTheme(value ? AppTheme.darkTheme : AppTheme.lightTheme);
    await _storage.write(StorageService.keyIsDarkMode, value);
  }
}
