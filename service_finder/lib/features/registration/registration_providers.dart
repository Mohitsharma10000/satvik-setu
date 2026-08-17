import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../repositories/application_repository.dart';
import '../../repositories/storage_repository.dart';
import '../../services/camera_service.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ref.watch(firebaseFirestoreProvider));
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

class RegistrationState {
  final bool isLoading;
  final String? error;

  RegistrationState({this.isLoading = false, this.error});
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final ApplicationRepository _appRepo;
  final StorageRepository _storageRepo;

  RegistrationNotifier(this._appRepo, this._storageRepo) : super(RegistrationState());

  Future<bool> submitRegistration(
    dynamic applicationModel,
    dynamic selfieFile,
    dynamic aadhaarFrontFile,
    dynamic aadhaarBackFile,
  ) async {
    try {
      state = RegistrationState(isLoading: true);
      
      // Convert images to Base64 strings (stored directly in Firestore)
      final profileBase64 = await _storageRepo.uploadProfileImage(selfieFile);
      final aadhaarFrontBase64 = await _storageRepo.uploadAadhaarFront(aadhaarFrontFile);
      final aadhaarBackBase64 = await _storageRepo.uploadAadhaarBack(aadhaarBackFile);
      
      // Update model with base64 strings
      final finalApplication = applicationModel.copyWith(
        profileImage: profileBase64,
        aadhaarFront: aadhaarFrontBase64,
        aadhaarBack: aadhaarBackBase64,
      );
      
      await _appRepo.submitApplication(finalApplication);
      state = RegistrationState(isLoading: false);
      return true;
    } catch (e) {
      state = RegistrationState(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier(
    ref.watch(applicationRepositoryProvider),
    ref.watch(storageRepositoryProvider),
  );
});
