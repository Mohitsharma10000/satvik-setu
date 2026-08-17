import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subcategory_model.dart';
import '../core/constants/app_constants.dart';

class SubcategoryRepository {
  final FirebaseFirestore _firestore;

  SubcategoryRepository(this._firestore);

  Stream<List<SubcategoryModel>> getSubcategories({String? categoryId}) {
    Query query = _firestore.collection(AppConstants.subcategoriesCollection);
    
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => SubcategoryModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> addSubcategory(SubcategoryModel subcategory) async {
    await _firestore.collection(AppConstants.subcategoriesCollection).add(subcategory.toFirestore());
  }

  Future<void> updateSubcategory(SubcategoryModel subcategory) async {
    await _firestore.collection(AppConstants.subcategoriesCollection).doc(subcategory.id).update(subcategory.toFirestore());
  }

  Future<void> deleteSubcategory(String id) async {
    await _firestore.collection(AppConstants.subcategoriesCollection).doc(id).delete();
  }

  Future<int> getSubcategoryCount() async {
    final snapshot = await _firestore.collection(AppConstants.subcategoriesCollection).count().get();
    return snapshot.count ?? 0;
  }
}
