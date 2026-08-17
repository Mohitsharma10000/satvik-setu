import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';
import '../../models/subcategory_model.dart';
import '../core/constants/app_constants.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  // Default 21 Categories Fallback
  static final List<CategoryModel> defaultCategories = [
    CategoryModel(id: 'cat_1', name: 'Electrician', icon: 'electrical_services', order: 1, isActive: true),
    CategoryModel(id: 'cat_2', name: 'Plumber', icon: 'plumbing', order: 2, isActive: true),
    CategoryModel(id: 'cat_3', name: 'Mechanic', icon: 'build', order: 3, isActive: true),
    CategoryModel(id: 'cat_4', name: 'Carpenter', icon: 'construction', order: 4, isActive: true),
    CategoryModel(id: 'cat_5', name: 'Painter', icon: 'format_paint', order: 5, isActive: true),
    CategoryModel(id: 'cat_6', name: 'AC Repair', icon: 'ac_unit', order: 6, isActive: true),
    CategoryModel(id: 'cat_7', name: 'RO Service', icon: 'water_drop', order: 7, isActive: true),
    CategoryModel(id: 'cat_8', name: 'Refrigerator Repair', icon: 'kitchen', order: 8, isActive: true),
    CategoryModel(id: 'cat_9', name: 'Washing Machine Repair', icon: 'local_laundry_service', order: 9, isActive: true),
    CategoryModel(id: 'cat_10', name: 'TV Repair', icon: 'tv', order: 10, isActive: true),
    CategoryModel(id: 'cat_11', name: 'Mobile Repair', icon: 'smartphone', order: 11, isActive: true),
    CategoryModel(id: 'cat_12', name: 'Laptop Repair', icon: 'laptop', order: 12, isActive: true),
    CategoryModel(id: 'cat_13', name: 'CCTV Installation', icon: 'videocam', order: 13, isActive: true),
    CategoryModel(id: 'cat_14', name: 'Driver', icon: 'directions_car', order: 14, isActive: true),
    CategoryModel(id: 'cat_15', name: 'Gardener', icon: 'grass', order: 15, isActive: true),
    CategoryModel(id: 'cat_16', name: 'House Cleaning', icon: 'cleaning_services', order: 16, isActive: true),
    CategoryModel(id: 'cat_17', name: 'Pest Control', icon: 'bug_report', order: 17, isActive: true),
    CategoryModel(id: 'cat_18', name: 'Mason', icon: 'foundation', order: 18, isActive: true),
    CategoryModel(id: 'cat_19', name: 'Welder', icon: 'precision_manufacturing', order: 19, isActive: true),
    CategoryModel(id: 'cat_20', name: 'Internet Technician', icon: 'wifi', order: 20, isActive: true),
    CategoryModel(id: 'cat_21', name: 'Computer Repair', icon: 'desktop_windows', order: 21, isActive: true),
    CategoryModel(id: 'cat_22', name: 'Rent of houses', icon: 'house', order: 22, isActive: true),
    CategoryModel(id: 'cat_23', name: 'Home Tuitions', icon: 'school', order: 23, isActive: true),
  ];

  // Default Subcategories Fallback Map
  static final Map<String, List<SubcategoryModel>> defaultSubcategories = {
    'cat_1': [
      SubcategoryModel(id: 'sub_1_1', categoryId: 'cat_1', name: 'House Wiring & Short Circuit', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_1_2', categoryId: 'cat_1', name: 'Fan & Light Repair', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_1_3', categoryId: 'cat_1', name: 'Switchboard & MCB Fitting', order: 3, isActive: true),
      SubcategoryModel(id: 'sub_1_4', categoryId: 'cat_1', name: 'Inverter Repair & Service', order: 4, isActive: true),
    ],
    'cat_2': [
      SubcategoryModel(id: 'sub_2_1', categoryId: 'cat_2', name: 'Pipe Leakage & Fitting', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_2_2', categoryId: 'cat_2', name: 'Tap & Shower Repair', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_2_3', categoryId: 'cat_2', name: 'Water Tank Cleaning', order: 3, isActive: true),
      SubcategoryModel(id: 'sub_2_4', categoryId: 'cat_2', name: 'Geyser Repair & Fitting', order: 4, isActive: true),
    ],
    'cat_3': [
      SubcategoryModel(id: 'sub_3_1', categoryId: 'cat_3', name: 'Car Breakdown & Engine Repair', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_3_2', categoryId: 'cat_3', name: 'Bike & Scooter Servicing', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_3_3', categoryId: 'cat_3', name: 'Battery Service & Jumpstart', order: 3, isActive: true),
    ],
    'cat_6': [
      SubcategoryModel(id: 'sub_6_1', categoryId: 'cat_6', name: 'AC Deep Servicing', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_6_2', categoryId: 'cat_6', name: 'AC Gas Refilling', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_6_3', categoryId: 'cat_6', name: 'AC Installation & Uninstallation', order: 3, isActive: true),
    ],
    'cat_13': [
      SubcategoryModel(id: 'sub_13_1', categoryId: 'cat_13', name: 'New CCTV Camera Setup', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_13_2', categoryId: 'cat_13', name: 'DVR & NVR Repair', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_13_3', categoryId: 'cat_13', name: 'CCTV Cable & Power Repair', order: 3, isActive: true),
    ],
    'cat_22': [
      SubcategoryModel(id: 'sub_22_1', categoryId: 'cat_22', name: '1 BHK House for Rent', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_22_2', categoryId: 'cat_22', name: '2 BHK House for Rent', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_22_3', categoryId: 'cat_22', name: '3 BHK / Independent House', order: 3, isActive: true),
      SubcategoryModel(id: 'sub_22_4', categoryId: 'cat_22', name: 'Commercial / Shop Space', order: 4, isActive: true),
    ],
    'cat_23': [
      SubcategoryModel(id: 'sub_23_1', categoryId: 'cat_23', name: 'Class 1 to 5 (All Subjects)', order: 1, isActive: true),
      SubcategoryModel(id: 'sub_23_2', categoryId: 'cat_23', name: 'Class 6 to 10 (Maths & Science)', order: 2, isActive: true),
      SubcategoryModel(id: 'sub_23_3', categoryId: 'cat_23', name: 'Class 11 & 12 (Physics/Chemistry/Maths)', order: 3, isActive: true),
      SubcategoryModel(id: 'sub_23_4', categoryId: 'cat_23', name: 'Competitive Exam Coaching', order: 4, isActive: true),
    ],
  };

  Stream<List<CategoryModel>> getCategories() async* {
    yield defaultCategories;
    try {
      await for (final snapshot in _firestore
          .collection(AppConstants.categoriesCollection)
          .snapshots()) {
        final list = snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .where((cat) => cat.isActive)
            .toList();
        list.sort((a, b) => a.order.compareTo(b.order));
        if (list.isNotEmpty) {
          yield list;
        } else {
          yield defaultCategories;
        }
      }
    } catch (_) {
      yield defaultCategories;
    }
  }

  Stream<List<SubcategoryModel>> getSubcategories(String categoryId) async* {
    final fallbacks = _getDefaultSubcategories(categoryId);
    yield fallbacks;
    try {
      await for (final snapshot in _firestore
          .collection(AppConstants.subcategoriesCollection)
          .snapshots()) {
        final list = snapshot.docs
            .map((doc) => SubcategoryModel.fromFirestore(doc))
            .where((sub) => sub.isActive && sub.categoryId == categoryId)
            .toList();
        list.sort((a, b) => a.order.compareTo(b.order));
        if (list.isNotEmpty) {
          yield list;
        } else {
          yield fallbacks;
        }
      }
    } catch (_) {
      yield fallbacks;
    }
  }

  List<SubcategoryModel> _getDefaultSubcategories(String categoryId) {
    if (defaultSubcategories.containsKey(categoryId)) {
      return defaultSubcategories[categoryId]!;
    }
    final cat = defaultCategories.firstWhere((c) => c.id == categoryId, orElse: () => defaultCategories[0]);
    return [
      SubcategoryModel(id: '${categoryId}_sub1', categoryId: categoryId, name: '${cat.name} General Repair', order: 1, isActive: true),
      SubcategoryModel(id: '${categoryId}_sub2', categoryId: categoryId, name: '${cat.name} Maintenance & Service', order: 2, isActive: true),
      SubcategoryModel(id: '${categoryId}_sub3', categoryId: categoryId, name: '${cat.name} Inspection & Consultation', order: 3, isActive: true),
    ];
  }

  Future<List<CategoryModel>> searchCategories(String query) async {
    final q = query.toLowerCase();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();
          
      final list = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .where((cat) => cat.isActive && cat.name.toLowerCase().contains(q))
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return defaultCategories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }
}
