import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';
import '../utils/import_to_export.dart';

/// Shows a Yes/No confirmation dialog and returns `true` if confirmed.
/// Used before destructive actions like deleting a note or logging out.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            confirmLabel ?? title,
            style: mediumPoppins(14, textColor: Colors.red),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
