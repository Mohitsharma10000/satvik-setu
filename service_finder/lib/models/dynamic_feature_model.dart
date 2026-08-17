import 'package:cloud_firestore/cloud_firestore.dart';

class CustomFormFieldModel {
  final String id;
  final String label;
  final String type; // 'text', 'number', 'phone', 'date', 'dropdown', 'multiline'
  final List<String> options; // For dropdown
  final bool isRequired;

  CustomFormFieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
    this.isRequired = true,
  });

  factory CustomFormFieldModel.fromMap(Map<String, dynamic> map) {
    return CustomFormFieldModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      type: map['type'] ?? 'text',
      options: List<String>.from(map['options'] ?? []),
      isRequired: map['isRequired'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'options': options,
      'isRequired': isRequired,
    };
  }
}

class DynamicFeatureModel {
  final String id;
  final String featureName;
  final String description;
  final String icon;
  final String badgeText;
  final double fee;
  final bool isActive;
  final List<CustomFormFieldModel> fields;
  final DateTime? createdAt;

  DynamicFeatureModel({
    required this.id,
    required this.featureName,
    required this.description,
    this.icon = 'star',
    this.badgeText = 'NEW',
    this.fee = 0.0,
    this.isActive = true,
    required this.fields,
    this.createdAt,
  });

  factory DynamicFeatureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final fieldsList = (data['fields'] as List<dynamic>? ?? [])
        .map((f) => CustomFormFieldModel.fromMap(Map<String, dynamic>.from(f)))
        .toList();

    return DynamicFeatureModel(
      id: doc.id,
      featureName: data['featureName'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'star',
      badgeText: data['badgeText'] ?? 'NEW',
      fee: (data['fee'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] ?? true,
      fields: fieldsList,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'featureName': featureName,
      'description': description,
      'icon': icon,
      'badgeText': badgeText,
      'fee': fee,
      'isActive': isActive,
      'fields': fields.map((f) => f.toMap()).toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
