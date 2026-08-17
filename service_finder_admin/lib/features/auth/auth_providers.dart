import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repository.dart';
import '../../core/providers/firebase_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(false);

  Future<String?> login(String email, String password) async {
    state = true;
    try {
      final userCred = await _repository.signIn(email, password);
      final uid = userCred.user?.uid;
      
      if (uid == null) {
        state = false;
        return 'Authentication Failed: User ID is null.';
      }

      final isAdmin = await _repository.isAdmin(uid);
      if (!isAdmin) {
        await _repository.signOut();
        state = false;
        return 'Access Denied: UID "$uid" is not registered in the "admins" collection.';
      }
      
      state = false;
      return null; // success
    } catch (e) {
      state = false;
      final msg = e.toString();
      if (msg.contains('invalid-credential') || msg.contains('wrong-password') || msg.contains('user-not-found')) {
        return 'Invalid email or password. Please check your credentials.';
      }
      return 'Login Error: $e';
    }
  }

  Future<void> logout() async {
    try {
      await _repository.signOut();
    } catch (_) {}
  }
}
