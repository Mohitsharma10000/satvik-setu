import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/application_repository.dart';
import '../../core/providers/firebase_providers.dart';
import '../../models/application_model.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ref.watch(firestoreProvider));
});

final applicationsStreamProvider = StreamProvider.family<List<ApplicationModel>, String>((ref, status) {
  return ref.watch(applicationRepositoryProvider).getApplications(status: status);
});

final applicationDetailProvider = FutureProvider.family<ApplicationModel?, String>((ref, id) {
  return ref.watch(applicationRepositoryProvider).getApplicationById(id);
});
