import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/note_form/bindings/note_form_binding.dart';
import '../modules/note_form/views/note_form_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

/// Maps every route name to its view + binding, so `GetMaterialApp` can
/// build the correct screen (and inject its controller) for `Get.toNamed(...)`.
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: Routes.splash, page: () => SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(name: Routes.register, page: () => const RegisterView(), binding: RegisterBinding()),
    GetPage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: Routes.addNote, page: () => const NoteFormView(), binding: NoteFormBinding()),
    GetPage(name: Routes.editNote, page: () => const NoteFormView(), binding: NoteFormBinding()),
    GetPage(name: Routes.profile, page: () => const ProfileView(), binding: ProfileBinding()),
    GetPage(name: Routes.settings, page: () => const SettingsView(), binding: SettingsBinding()),
  ];
}
