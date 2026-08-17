import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/donation_settings_model.dart';
import '../core/constants/app_constants.dart';

class DonationRepository {
  final FirebaseFirestore _firestore;

  DonationRepository(this._firestore);

  static final defaultSettings = DonationSettingsModel(
    qrCodeUrl: '',
    upiId: 'seconnect@upi',
    donationMessage: 'Thank you for supporting SevaConnect! Your contributions help us keep service provider verification free for local workers.',
    updatedAt: DateTime.now(),
  );

  Stream<DonationSettingsModel?> getDonationSettings() {
    return _firestore
        .doc(AppConstants.donationSettingsDoc)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return defaultSettings;
          return DonationSettingsModel.fromFirestore(snapshot);
        })
        .handleError((_) => defaultSettings);
  }
}
