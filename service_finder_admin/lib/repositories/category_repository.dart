import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection(AppConstants.categoriesCollection).add(category.toFirestore());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore.collection(AppConstants.categoriesCollection).doc(category.id).update(category.toFirestore());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(AppConstants.categoriesCollection).doc(id).delete();
  }

  Future<int> getCategoryCount() async {
    final snapshot = await _firestore.collection(AppConstants.categoriesCollection).count().get();
    return snapshot.count ?? 0;
  }
}
