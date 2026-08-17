import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../repositories/category_repository.dart';
import '../../models/category_model.dart';
import '../../models/app_feature_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CategoryRepository(firestore);
});

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});

final appFeaturesProvider = StreamProvider<List<AppFeatureModel>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('features')
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs
        .map((doc) => AppFeatureModel.fromFirestore(doc))
        .where((f) => f.isActive)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  });
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
