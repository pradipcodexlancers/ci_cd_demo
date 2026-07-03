import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../core/constants/app_strings.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Wraps Firebase Authentication (email/password) and keeps the app's
/// Firestore `users/{uid}` profile in sync with the signed-in account.
///
/// [currentUser] is the single source of truth the rest of the app watches
/// via `Obx` - it's populated from Firestore, not directly from
/// `FirebaseAuth.User` (which only knows the email, not the display name).
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Reactive currently-logged-in profile; null when logged out.
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  bool get isLoggedIn => currentUser.value != null;

  /// Hydrates [currentUser] from Firebase's persisted session (if any)
  /// before the app's first route builds, then keeps listening so a
  /// sign-out on another device / token revocation is reflected here too.
  Future<AuthService> init() async {
    final initialUser = await _auth.authStateChanges().first;
    await _syncProfile(initialUser);

    _auth.authStateChanges().listen(_syncProfile);
    return this;
  }

  Future<void> _syncProfile(User? firebaseUser) async {
    if (firebaseUser == null) {
      currentUser.value = null;
      return;
    }
    currentUser.value = await _firestoreService.fetchUserProfile(firebaseUser.uid);
  }

  /// Creates a Firebase Auth account + the matching Firestore profile, then
  /// signs out immediately so the user has to log in explicitly afterwards
  /// (Firebase signs a new account in automatically by default).
  /// Returns `null` on success, or a user-facing error message on failure.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      await _firestoreService.createUserProfile(
        UserModel(uid: uid, email: email.trim(), name: name.trim()),
      );

      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    }
  }

  /// Signs in and (synchronously, before returning) loads the Firestore
  /// profile into [currentUser] so Home/Profile have data the instant
  /// navigation happens - not a moment later via the auth-state listener.
  /// Returns `null` on success, or a user-facing error message on failure.
  Future<String?> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _syncProfile(credential.user);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    }
  }

  Future<void> logout() => _auth.signOut();

  /// Maps common `FirebaseAuthException` codes to plain-English messages -
  /// Firebase's default `e.message` is technically correct but reads like a
  /// server log, not something to show a user.
  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppStrings.emailAlreadyRegistered;
      case 'invalid-email':
        return AppStrings.emailInvalid;
      case 'weak-password':
        return AppStrings.passwordTooShort;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.loginFailed;
      case 'user-disabled':
        return AppStrings.accountDisabled;
      case 'too-many-requests':
        return AppStrings.tooManyAttempts;
      case 'network-request-failed':
        return AppStrings.networkError;
      default:
        return e.message ?? AppStrings.genericAuthError;
    }
  }
}
