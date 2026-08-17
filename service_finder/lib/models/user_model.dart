import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? photoUrl;
  final bool isVerified;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.userId,
    this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
    this.isVerified = true,
    this.fcmToken,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['userId'] ?? doc.id,
      email: data['email'],
      phone: data['phone'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      isVerified: data['isVerified'] ?? true,
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isVerified': isVerified,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }
}
