import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/subcategory_repository.dart';
import '../../core/providers/firebase_providers.dart';
import '../applications/application_providers.dart';

final applicationCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(applicationRepositoryProvider);
  // Let errors propagate so the dashboard can show them
  return await repo.getApplicationCounts();
});

final categoryCountProvider = FutureProvider<int>((ref) async {
  final repo = CategoryRepository(ref.watch(firestoreProvider));
  return await repo.getCategoryCount();
});

final subcategoryCountProvider = FutureProvider<int>((ref) async {
  final repo = SubcategoryRepository(ref.watch(firestoreProvider));
  return await repo.getSubcategoryCount();
});
