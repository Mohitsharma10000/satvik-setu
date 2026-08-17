import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subcategory_model.dart';
import '../home/home_providers.dart';

final subcategoriesProvider = StreamProvider.family<List<SubcategoryModel>, String>((ref, categoryId) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getSubcategories(categoryId);
});
