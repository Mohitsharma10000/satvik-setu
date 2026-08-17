import 'package:cloud_firestore/cloud_firestore.dart';

class DonationSettingsModel {
  final String qrCodeUrl;
  final String upiId;
  final String donationMessage;
  final bool isDonationVisible;
  final DateTime updatedAt;

  DonationSettingsModel({
    required this.qrCodeUrl,
    required this.upiId,
    required this.donationMessage,
    this.isDonationVisible = true,
    required this.updatedAt,
  });

  factory DonationSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return DonationSettingsModel(
        qrCodeUrl: '',
        upiId: '',
        donationMessage: 'Thank you for your support!',
        isDonationVisible: true,
        updatedAt: DateTime.now(),
      );
    }
    return DonationSettingsModel(
      qrCodeUrl: data['qrCodeUrl'] ?? '',
      upiId: data['upiId'] ?? '',
      donationMessage: data['donationMessage'] ?? 'Thank you for your support!',
      isDonationVisible: data['isDonationVisible'] ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'qrCodeUrl': qrCodeUrl,
      'upiId': upiId,
      'donationMessage': donationMessage,
      'isDonationVisible': isDonationVisible,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
