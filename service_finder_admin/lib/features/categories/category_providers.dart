import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/category_repository.dart';
import '../../core/providers/firebase_providers.dart';
import '../../models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(firestoreProvider));
});

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});
