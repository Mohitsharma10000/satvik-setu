import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_providers.dart';
import '../constants/app_constants.dart';

/// When Firebase is not configured, this provider will emit an error.
/// The router handles this by treating errors as "authenticated" in demo mode.
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    return ref.watch(firebaseAuthProvider).authStateChanges();
  } catch (e) {
    // Firebase not configured — return a stream that emits null
    return Stream.value(null);
  }
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  
  try {
    final doc = await ref
        .watch(firestoreProvider)
        .collection(AppConstants.adminsCollection)
        .doc(user.uid)
        .get();
    return doc.exists;
  } catch (e) {
    return false;
  }
});
