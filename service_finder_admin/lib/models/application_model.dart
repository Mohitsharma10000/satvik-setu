import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final String dob;
  final String address;
  final String state;
  final String city;
  final String pincode;
  final String category;
  final String subcategory;
  final String categoryId;
  final String subcategoryId;
  final String experience;
  final String description;
  final String profileImage;
  final String aadhaarFront;
  final String aadhaarBack;
  final String verificationStatus;
  final DateTime? submittedAt;
  final double? latitude;
  final double? longitude;
  final double? serviceRate;
  final String? rateDescription;

  ApplicationModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
    required this.address,
    required this.state,
    required this.city,
    required this.pincode,
    required this.category,
    required this.subcategory,
    required this.categoryId,
    required this.subcategoryId,
    required this.experience,
    required this.description,
    required this.profileImage,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.verificationStatus,
    this.submittedAt,
    this.latitude,
    this.longitude,
    this.serviceRate,
    this.rateDescription,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ApplicationModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      dob: data['dob'] ?? '',
      address: data['address'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      pincode: data['pincode'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      categoryId: data['categoryId'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      experience: data['experience'] ?? '',
      description: data['description'] ?? '',
      profileImage: data['profileImage'] ?? '',
      aadhaarFront: data['aadhaarFront'] ?? '',
      aadhaarBack: data['aadhaarBack'] ?? '',
      verificationStatus: data['verificationStatus'] ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      serviceRate: (data['serviceRate'] ?? data['ratePerVisit'] ?? data['ratePerHour'] as num?)?.toDouble(),
      rateDescription: data['rateDescription'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dob': dob,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pincode,
      'category': category,
      'subcategory': subcategory,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'experience': experience,
      'description': description,
      'profileImage': profileImage,
      'aadhaarFront': aadhaarFront,
      'aadhaarBack': aadhaarBack,
      'verificationStatus': verificationStatus,
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : FieldValue.serverTimestamp(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (serviceRate != null) 'serviceRate': serviceRate,
      if (rateDescription != null) 'rateDescription': rateDescription,
    };
  }
}
