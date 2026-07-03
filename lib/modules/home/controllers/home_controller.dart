import 'dart:async';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../models/note_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

/// Client-side sort choices applied over the Firestore stream (which always
/// arrives ordered newest-updated-first - see [FirestoreService.streamNotes]).
/// Re-sorting in memory avoids re-subscribing to Firestore every time the
/// user changes their mind, which would re-download the whole list.
enum NoteSortOption { newest, oldest, titleAz }

/// Drives the Home screen: subscribes to the signed-in user's notes in
/// real time, and exposes the add/edit/delete actions plus search & sort.
/// All Firestore access goes through [FirestoreService]; this controller
/// only holds UI-facing state (loading/error, search query, sort choice).
class HomeController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  StreamSubscription<List<NoteModel>>? _notesSubscription;

  // Raw notes as they arrive from Firestore, newest-updated first.
  final RxList<NoteModel> _notes = <NoteModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<NoteSortOption> sortOption = NoteSortOption.newest.obs;

  String get _uid => _authService.currentUser.value!.uid;

  @override
  void onInit() {
    super.onInit();
    _subscribeToNotes();
  }

  void _subscribeToNotes() {
    isLoading.value = true;
    errorMessage.value = '';

    _notesSubscription = _firestoreService.streamNotes(_uid).listen(
      (notes) {
        _notes.assignAll(notes);
        isLoading.value = false;
      },
      onError: (Object error) {
        // Surfaces things like missing security-rule permissions or being offline.
        errorMessage.value = AppStrings.errorLoadingNotes;
        isLoading.value = false;
      },
    );
  }

  /// Cancels and restarts the Firestore listener - used by the error state's
  /// Retry button.
  void retry() {
    _notesSubscription?.cancel();
    _subscribeToNotes();
  }

  /// The list actually rendered by the view: [_notes] filtered by
  /// [searchQuery] (case-insensitive match on title or description), then
  /// ordered per [sortOption].
  List<NoteModel> get filteredNotes {
    final query = searchQuery.value.trim().toLowerCase();
    final matches = query.isEmpty
        ? List<NoteModel>.from(_notes)
        : _notes.where((note) {
            return note.title.toLowerCase().contains(query) ||
                note.description.toLowerCase().contains(query);
          }).toList();

    switch (sortOption.value) {
      case NoteSortOption.newest:
        matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOption.oldest:
        matches.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSortOption.titleAz:
        matches.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return matches;
  }

  // Exposed so the view can tell "no notes at all" apart from "no search results".
  bool get hasAnyNotes => _notes.isNotEmpty;

  void updateSearchQuery(String value) => searchQuery.value = value;

  void updateSortOption(NoteSortOption option) => sortOption.value = option;

  Future<void> deleteNote(NoteModel note) async {
    final confirmed = await showConfirmDialog(
      title: AppStrings.delete,
      message: AppStrings.deleteNoteConfirm,
    );
    if (!confirmed) return;

    try {
      await _firestoreService.deleteNote(uid: _uid, noteId: note.id);
      SnackbarUtil.success(AppStrings.noteDeleted);
    } catch (_) {
      SnackbarUtil.error(AppStrings.noteDeleteFailed);
    }
  }

  @override
  void onClose() {
    _notesSubscription?.cancel();
    super.onClose();
  }
}
