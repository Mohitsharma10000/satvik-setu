import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../models/donation_settings_model.dart';
import '../../repositories/donation_repository.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return DonationRepository(firestore);
});

final donationSettingsProvider = StreamProvider<DonationSettingsModel?>((ref) {
  final repo = ref.watch(donationRepositoryProvider);
  return repo.getDonationSettings();
});
