import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int order;
  final bool isActive;
  final double advanceFee;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
    this.isActive = true,
    this.advanceFee = 10.0,
    this.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      advanceFee: (data['advanceFee'] as num?)?.toDouble() ?? 10.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'order': order,
      'isActive': isActive,
      'advanceFee': advanceFee,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
