import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a single note, stored at `users/{uid}/notes/{noteId}`
/// in Firestore. [id] is the Firestore document id - never stored as a
/// field inside the document itself.
class NoteModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builds a [NoteModel] from a Firestore document snapshot.
  /// Falls back to `DateTime.now()` for timestamps that are still `null`
  /// because `FieldValue.serverTimestamp()` hasn't been confirmed by the
  /// server yet (visible for an instant right after a local write).
  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NoteModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Fields written when a new note is created - timestamps are set by the
  /// server so every client agrees on ordering regardless of local clock skew.
  static Map<String, dynamic> forCreate({required String title, required String description}) {
    return {
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Fields written on edit - `createdAt` is intentionally left untouched.
  static Map<String, dynamic> forUpdate({required String title, required String description}) {
    return {
      'title': title,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
