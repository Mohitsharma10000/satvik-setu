import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? paymentId;
  final String userId;
  final String userPhone;
  final double amount;
  final String paymentStatus; // 'pending', 'success', 'failed'
  final String categoryId;
  final String subcategoryId;
  final String category;
  final String subcategory;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final DateTime createdAt;

  PaymentModel({
    this.paymentId,
    required this.userId,
    required this.userPhone,
    this.amount = 10.0,
    required this.paymentStatus,
    required this.categoryId,
    required this.subcategoryId,
    required this.category,
    required this.subcategory,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    required this.createdAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      paymentId: doc.id,
      userId: data['userId'] ?? '',
      userPhone: data['userPhone'] ?? '',
      amount: (data['amount'] ?? 10.0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      categoryId: data['categoryId'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      razorpayOrderId: data['razorpayOrderId'],
      razorpayPaymentId: data['razorpayPaymentId'],
      razorpaySignature: data['razorpaySignature'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userPhone': userPhone,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'category': category,
      'subcategory': subcategory,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PaymentModel copyWith({
    String? paymentId,
    String? userId,
    String? userPhone,
    double? amount,
    String? paymentStatus,
    String? categoryId,
    String? subcategoryId,
    String? category,
    String? subcategory,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      userId: userId ?? this.userId,
      userPhone: userPhone ?? this.userPhone,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
