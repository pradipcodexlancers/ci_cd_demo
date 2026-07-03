import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../models/note_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

/// Backs both the Add Note and Edit Note screens - they're the same form,
/// just seeded differently. [Get.arguments] is the [NoteModel] being edited,
/// or `null` when adding a brand-new note (see Routes.addNote / Routes.editNote).
class NoteFormController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  final RxBool isLoading = false.obs;

  NoteModel? _editingNote;
  bool get isEditing => _editingNote != null;

  @override
  void onInit() {
    super.onInit();
    _editingNote = Get.arguments as NoteModel?;
    titleController = TextEditingController(text: _editingNote?.title ?? '');
    descriptionController = TextEditingController(text: _editingNote?.description ?? '');
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final uid = _authService.currentUser.value!.uid;
    isLoading.value = true;
    try {
      final wasEditing = isEditing;
      if (isEditing) {
        await _firestoreService.updateNote(
          uid: uid,
          noteId: _editingNote!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );
      } else {
        await _firestoreService.addNote(
          uid: uid,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );
      }
      // Home's Firestore stream picks up the change in real time, so a
      // simple pop is enough - no manual refresh needed. Pop *before*
      // showing the snackbar (not after) - GetX's snackbar overlay and
      // Get.back() conflict when triggered in the same frame, which can
      // silently swallow both the popup and the navigation.
      Get.back();
      SnackbarUtil.success(wasEditing ? AppStrings.noteUpdated : AppStrings.noteAdded);
    } catch (_) {
      SnackbarUtil.error(AppStrings.noteSaveFailed);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
