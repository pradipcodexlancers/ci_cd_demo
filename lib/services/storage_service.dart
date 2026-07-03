import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Thin wrapper around [GetStorage] - local persistence for on-device UI
/// preferences only (auth session and notes now live in Firebase, not here).
///
/// Registered as a permanent GetX service in `main.dart` before `runApp`,
/// so every other service/controller can safely call `Get.find<StorageService>()`.
class StorageService extends GetxService {
  late final GetStorage _box;

  static const String keyIsDarkMode = 'isDarkMode';

  /// GetStorage requires async initialization (it reads the persisted file
  /// from disk) - this must be awaited before the app starts.
  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);
}
