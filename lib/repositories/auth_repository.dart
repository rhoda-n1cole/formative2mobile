import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app/constants.dart';
import '../app/validators.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> userChanges() => _auth.userChanges();

  Stream<AppUser?> watchProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!Validators.isAluEmail(cleanEmail)) {
      throw AuthException('Only ALU email addresses can register.');
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      await _db
          .collection('users')
          .doc(user.uid)
          .set(
            AppUser(
              uid: user.uid,
              email: cleanEmail,
              name: name.trim(),
              role: UserRole.student,
            ).toMap(),
          );
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    } on FirebaseException catch (e) {
      throw AuthException('Could not save your profile: ${e.message}');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resendVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  /// Reloads the user and refreshes the token so Firestore rules
  /// see the updated email_verified value.
  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed?.emailVerified ?? false) {
      await refreshed!.getIdToken(true);
      return true;
    }
    return false;
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and retry.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
