import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/providers/firebase_providers.dart';
import '../../models/provider_model.dart';
import '../../repositories/provider_repository.dart';
import '../../services/location_service.dart';

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ProviderRepository(firestore);
});

/// User's current location state
final userLocationProvider = StateProvider<Position?>((ref) => null);

/// Selected radius filter (default 7 km)
final radiusFilterProvider = StateProvider<double>((ref) => 7.0);

/// Provider query parameter with value equality for proper Riverpod family caching
class ProviderQueryParam {
  final String categoryId;
  final String subcategoryId;

  const ProviderQueryParam({
    required this.categoryId,
    required this.subcategoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderQueryParam &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          subcategoryId == other.subcategoryId;

  @override
  int get hashCode => categoryId.hashCode ^ subcategoryId.hashCode;
}

/// Location-aware provider stream
final providersProvider = StreamProvider.family<List<ProviderModel>, ProviderQueryParam>((ref, params) {
  final repo = ref.watch(providerRepositoryProvider);
  final userLocation = ref.watch(userLocationProvider);
  final radiusKm = ref.watch(radiusFilterProvider);
  
  return repo.getVerifiedProviders(
    params.categoryId,
    params.subcategoryId,
    userLat: userLocation?.latitude,
    userLng: userLocation?.longitude,
    radiusKm: radiusKm,
  );
});
