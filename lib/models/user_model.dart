/// Data model for the logged-in user's profile, stored at `users/{uid}`
/// in Firestore (fields: name, email). The document id *is* the Firebase
/// Auth uid, so it's never duplicated as a field inside the document.
class UserModel {
  final String uid;
  final String email;
  final String name;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
  });

  /// Fields written to `users/{uid}` on registration.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

  /// Builds a [UserModel] from the `users/{uid}` document - [uid] comes from
  /// the document id (i.e. `FirebaseAuth` uid), not from the data map.
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
    );
  }
}
