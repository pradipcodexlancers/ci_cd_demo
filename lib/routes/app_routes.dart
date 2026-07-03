/// String constants for every named route in the app.
/// Using constants instead of raw strings prevents typos in `Get.toNamed(...)`.
abstract class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String addNote = '/add-note';
  static const String editNote = '/edit-note';
}
