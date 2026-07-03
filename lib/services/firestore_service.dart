import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';

/// Owns every Firestore read/write in the app.
///
/// Structure used (chosen over a flat top-level `notes` collection with a
/// `uid` field for two reasons):
///   users/{uid}                     - { name, email }
///   users/{uid}/notes/{noteId}      - { title, description, createdAt, updatedAt }
/// 1. Security rules collapse to one check per collection
///    (`request.auth.uid == uid`) instead of validating a `uid` field on
///    every note document.
/// 2. Reading "this user's notes" is just that subcollection - no
///    `where('uid', isEqualTo: uid)` filter (and no composite index) needed.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef => _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _notesRef(String uid) =>
      _usersRef.doc(uid).collection('notes');

  // ---- User profile -------------------------------------------------

  /// Creates the `users/{uid}` profile document right after Firebase Auth
  /// account creation.
  Future<void> createUserProfile(UserModel user) {
    return _usersRef.doc(user.uid).set(user.toMap());
  }

  /// Fetches the profile document for the given uid, or `null` if it
  /// doesn't exist (shouldn't normally happen once registered).
  Future<UserModel?> fetchUserProfile(String uid) async {
    final snapshot = await _usersRef.doc(uid).get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(uid, snapshot.data()!);
  }

  // ---- Notes ----------------------------------------------------------

  /// Real-time stream of every note belonging to [uid], newest-updated
  /// first. Sorting for "oldest" / "title" is done client-side in
  /// [HomeController] over this same stream, so we only keep one listener.
  Stream<List<NoteModel>> streamNotes(String uid) {
    return _notesRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(NoteModel.fromSnapshot).toList());
  }

  Future<void> addNote({
    required String uid,
    required String title,
    required String description,
  }) {
    return _notesRef(uid).add(NoteModel.forCreate(title: title, description: description));
  }

  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String description,
  }) {
    return _notesRef(
      uid,
    ).doc(noteId).update(NoteModel.forUpdate(title: title, description: description));
  }

  Future<void> deleteNote({required String uid, required String noteId}) {
    return _notesRef(uid).doc(noteId).delete();
  }
}
