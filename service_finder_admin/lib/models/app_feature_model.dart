import 'package:cloud_firestore/cloud_firestore.dart';

class AppFeatureModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String badgeText;
  final String actionType;
  final String actionValue;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  AppFeatureModel({
    required this.id,
    required this.title,
    required this.description,
    this.icon = 'star',
    this.badgeText = 'NEW',
    this.actionType = 'notice',
    this.actionValue = '',
    this.isActive = true,
    this.order = 0,
    this.createdAt,
  });

  factory AppFeatureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppFeatureModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'star',
      badgeText: data['badgeText'] ?? 'NEW',
      actionType: data['actionType'] ?? 'notice',
      actionValue: data['actionValue'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'badgeText': badgeText,
      'actionType': actionType,
      'actionValue': actionValue,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
