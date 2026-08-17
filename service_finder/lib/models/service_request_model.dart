import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String? requestId;
  final String userId;
  final String userName;
  final String userPhone;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String categoryId;
  final String category;
  final String subcategoryId;
  final String subcategory;
  final String serviceLocation;
  final double? latitude;
  final double? longitude;
  final DateTime requestedAt;
  final DateTime? scheduledDate;
  final double? estimatedCharge;
  final double advancePaid;
  final double? remainingAmount;
  final String status;
  final String paymentId;
  final List<String> completionPhotos;
  final List<String> beforePhotos;
  final List<String> afterPhotos;
  final String? completionNotes;
  final String? invoice;
  final String? providerFcmToken;
  final String? userFcmToken;

  ServiceRequestModel({
    this.requestId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.categoryId,
    required this.category,
    required this.subcategoryId,
    required this.subcategory,
    required this.serviceLocation,
    this.latitude,
    this.longitude,
    required this.requestedAt,
    this.scheduledDate,
    this.estimatedCharge,
    this.advancePaid = 10.0,
    this.remainingAmount,
    required this.status,
    required this.paymentId,
    this.completionPhotos = const [],
    this.beforePhotos = const [],
    this.afterPhotos = const [],
    this.completionNotes,
    this.invoice,
    this.providerFcmToken,
    this.userFcmToken,
  });

  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceRequestModel(
      requestId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerPhone: data['providerPhone'] ?? '',
      categoryId: data['categoryId'] ?? '',
      category: data['category'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      subcategory: data['subcategory'] ?? '',
      serviceLocation: data['serviceLocation'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate(),
      estimatedCharge: (data['estimatedCharge'] as num?)?.toDouble(),
      advancePaid: (data['advancePaid'] ?? 10.0).toDouble(),
      remainingAmount: (data['remainingAmount'] as num?)?.toDouble(),
      status: data['status'] ?? 'requested',
      paymentId: data['paymentId'] ?? '',
      completionPhotos: List<String>.from(data['completionPhotos'] ?? []),
      beforePhotos: List<String>.from(data['beforePhotos'] ?? []),
      afterPhotos: List<String>.from(data['afterPhotos'] ?? []),
      completionNotes: data['completionNotes'],
      invoice: data['invoice'],
      providerFcmToken: data['providerFcmToken'],
      userFcmToken: data['userFcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'categoryId': categoryId,
      'category': category,
      'subcategoryId': subcategoryId,
      'subcategory': subcategory,
      'serviceLocation': serviceLocation,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'requestedAt': Timestamp.fromDate(requestedAt),
      if (scheduledDate != null) 'scheduledDate': Timestamp.fromDate(scheduledDate!),
      if (estimatedCharge != null) 'estimatedCharge': estimatedCharge,
      'advancePaid': advancePaid,
      if (remainingAmount != null) 'remainingAmount': remainingAmount,
      'status': status,
      'paymentId': paymentId,
      'completionPhotos': completionPhotos,
      'beforePhotos': beforePhotos,
      'afterPhotos': afterPhotos,
      if (completionNotes != null) 'completionNotes': completionNotes,
      if (invoice != null) 'invoice': invoice,
      if (providerFcmToken != null) 'providerFcmToken': providerFcmToken,
      if (userFcmToken != null) 'userFcmToken': userFcmToken,
    };
  }

  ServiceRequestModel copyWith({
    String? requestId,
    String? userId,
    String? userName,
    String? userPhone,
    String? providerId,
    String? providerName,
    String? providerPhone,
    String? categoryId,
    String? category,
    String? subcategoryId,
    String? subcategory,
    String? serviceLocation,
    double? latitude,
    double? longitude,
    DateTime? requestedAt,
    DateTime? scheduledDate,
    double? estimatedCharge,
    double? advancePaid,
    double? remainingAmount,
    String? status,
    String? paymentId,
    List<String>? completionPhotos,
    List<String>? beforePhotos,
    List<String>? afterPhotos,
    String? completionNotes,
    String? invoice,
    String? providerFcmToken,
    String? userFcmToken,
  }) {
    return ServiceRequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategory: subcategory ?? this.subcategory,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      requestedAt: requestedAt ?? this.requestedAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      estimatedCharge: estimatedCharge ?? this.estimatedCharge,
      advancePaid: advancePaid ?? this.advancePaid,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      completionPhotos: completionPhotos ?? this.completionPhotos,
      beforePhotos: beforePhotos ?? this.beforePhotos,
      afterPhotos: afterPhotos ?? this.afterPhotos,
      completionNotes: completionNotes ?? this.completionNotes,
      invoice: invoice ?? this.invoice,
      providerFcmToken: providerFcmToken ?? this.providerFcmToken,
      userFcmToken: userFcmToken ?? this.userFcmToken,
    );
  }
}
