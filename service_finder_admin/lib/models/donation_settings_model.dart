import 'package:cloud_firestore/cloud_firestore.dart';

class DonationSettingsModel {
  final String qrCodeUrl;
  final String upiId;
  final String donationMessage;
  final bool isDonationVisible;
  final DateTime? updatedAt;

  DonationSettingsModel({
    required this.qrCodeUrl,
    required this.upiId,
    required this.donationMessage,
    this.isDonationVisible = true,
    this.updatedAt,
  });

  factory DonationSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DonationSettingsModel(
      qrCodeUrl: data['qrCodeUrl'] ?? '',
      upiId: data['upiId'] ?? '',
      donationMessage: data['donationMessage'] ?? '',
      isDonationVisible: data['isDonationVisible'] ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
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
