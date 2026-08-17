import 'package:cloud_firestore/cloud_firestore.dart';

class SubcategoryModel {
  final String id;
  final String categoryId;
  final String name;
  final int order;
  final bool isActive;
  final DateTime? createdAt;

  SubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.order,
    this.isActive = true,
    this.createdAt,
  });

  factory SubcategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SubcategoryModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
