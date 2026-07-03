import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// Lazily creates [SplashController] only when the Splash route is visited.
/// GetX disposes it automatically once the route is popped.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
