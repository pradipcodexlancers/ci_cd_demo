import 'package:ci_cd_demo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  // Required because we call platform code (GetStorage's file I/O) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Services are registered as permanent singletons here (instead of via a
  // Binding) because they must be ready before the very first route builds -
  // Splash reads AuthService.isLoggedIn immediately on init.
  final storageService = await Get.putAsync(() => StorageService().init());
  // FirestoreService has no async setup, but must be registered before
  // AuthService since AuthService.init() looks up the user's profile via it.
  Get.put(FirestoreService());
  await Get.putAsync(() => AuthService().init());

  // Restore the persisted theme preference before the first frame renders,
  // so the app never "flashes" the wrong theme on launch.
  final isDarkMode = storageService.read<bool>(StorageService.keyIsDarkMode) ?? false;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}
