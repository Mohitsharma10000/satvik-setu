import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../repositories/feature_repository.dart';
import '../../models/app_feature_model.dart';

final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FeatureRepository(firestore);
});

final featuresStreamProvider = StreamProvider<List<AppFeatureModel>>((ref) {
  final repo = ref.watch(featureRepositoryProvider);
  return repo.getFeatures();
});
