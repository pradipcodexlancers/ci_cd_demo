import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/settings_controller.dart';

/// Settings screen - currently only exposes the light/dark theme toggle,
/// but is the natural place to add future preferences.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settings)),
      body: ListView(
        children: [
          // Obx rebuilds just this tile's switch when the theme preference changes.
          Obx(
            () => SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(AppStrings.darkMode),
              subtitle: Text(AppStrings.darkModeSubtitle),
              value: controller.isDarkMode.value,
              onChanged: controller.toggleTheme,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppStrings.about),
            subtitle: const Text('${AppStrings.appName} v0.1.0'),
          ),
        ],
      ),
    );
  }
}
