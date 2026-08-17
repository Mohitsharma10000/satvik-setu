import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/donation_settings_model.dart';

class DonationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DonationRepository(this._firestore, this._storage);

  /// Collection: 'donation', Doc: 'settings' (Matches User App)
  Stream<DonationSettingsModel?> getDonationSettings() {
    return _firestore
        .collection('donation')
        .doc('settings')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DonationSettingsModel.fromFirestore(doc);
    });
  }

  Future<void> updateDonationSettings(DonationSettingsModel settings) async {
    // Write to 'donation/settings' (Primary for user app)
    await _firestore
        .collection('donation')
        .doc('settings')
        .set(settings.toFirestore(), SetOptions(merge: true));

    // Also write to 'settings/donation' (Secondary for compatibility)
    try {
      await _firestore
          .collection('settings')
          .doc('donation')
          .set(settings.toFirestore(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<String> uploadQrCode(Uint8List bytes, String filename) async {
    final ref = _storage.ref().child('settings/qr_codes/$filename');
    final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
