import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/subcategory_repository.dart';
import '../../core/providers/firebase_providers.dart';
import '../../models/subcategory_model.dart';

final subcategoryRepositoryProvider = Provider<SubcategoryRepository>((ref) {
  return SubcategoryRepository(ref.watch(firestoreProvider));
});

final subcategoriesStreamProvider = StreamProvider.family<List<SubcategoryModel>, String?>((ref, categoryId) {
  return ref.watch(subcategoryRepositoryProvider).getSubcategories(categoryId: categoryId);
});
