import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String providerId;
  final String name;
  final String phone;
  final String profileImage;
  final String category;
  final String subcategory;
  final String categoryId;
  final String subcategoryId;
  final DateTime verifiedAt;
  final double? latitude;
  final double? longitude;
  final double? serviceRate;
  final String? rateDescription;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  double? distanceKm; // Calculated at runtime, not stored

  ProviderModel({
    required this.providerId,
    required this.name,
    required this.phone,
    required this.profileImage,
    required this.category,
    required this.subcategory,
    required this.categoryId,
    required this.subcategoryId,
    required this.verifiedAt,
    this.latitude,
    this.longitude,
    this.serviceRate,
    this.rateDescription,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.distanceKm,
  });

  /// Formatted full address string
  String get fullAddress {
    final parts = [
      if (address != null && address!.isNotEmpty) address,
      if (city != null && city!.isNotEmpty) city,
      if (state != null && state!.isNotEmpty) state,
      if (pincode != null && pincode!.isNotEmpty) pincode,
    ];
    return parts.isEmpty ? 'Address not available' : parts.join(', ');
  }

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      providerId: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      categoryId: data['categoryId'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      serviceRate: (data['serviceRate'] ?? data['ratePerVisit'] ?? data['ratePerHour'] as num?)?.toDouble(),
      rateDescription: data['rateDescription'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      pincode: data['pincode'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'category': category,
      'subcategory': subcategory,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'verifiedAt': FieldValue.serverTimestamp(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (serviceRate != null) 'serviceRate': serviceRate,
      if (rateDescription != null) 'rateDescription': rateDescription,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
    };
  }
}
