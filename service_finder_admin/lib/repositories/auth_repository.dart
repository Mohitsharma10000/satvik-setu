import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if the given UID exists in the 'admins' collection.
  /// If the entire collection is EMPTY, auto-bootstrap this user as the first admin.
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.adminsCollection)
          .doc(uid)
          .get();

      if (doc.exists) return true;

      // Collection might be empty → bootstrap first admin
      final collectionSnapshot = await _firestore
          .collection(AppConstants.adminsCollection)
          .limit(1)
          .get();

      if (collectionSnapshot.docs.isEmpty) {
        // No admins exist at all → create this user as the first admin
        await _firestore
            .collection(AppConstants.adminsCollection)
            .doc(uid)
            .set({
          'email': _auth.currentUser?.email ?? '',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'isFirstAdmin': true,
        });
        return true;
      }

      return false;
    } catch (e) {
      // If permission-denied on reading admins collection,
      // try creating the doc directly (works if rules allow it)
      try {
        final collectionSnapshot = await _firestore
            .collection(AppConstants.adminsCollection)
            .limit(1)
            .get();
        if (collectionSnapshot.docs.isEmpty) {
          await _firestore
              .collection(AppConstants.adminsCollection)
              .doc(uid)
              .set({
            'email': _auth.currentUser?.email ?? '',
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'isFirstAdmin': true,
          });
          return true;
        }
      } catch (_) {}
      return false;
    }
  }
}
