import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/donation_repository.dart';
import '../../core/providers/firebase_providers.dart';
import '../../models/donation_settings_model.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository(ref.watch(firestoreProvider), ref.watch(firebaseStorageProvider));
});

final donationSettingsStreamProvider = StreamProvider<DonationSettingsModel?>((ref) {
  return ref.watch(donationRepositoryProvider).getDonationSettings();
});
