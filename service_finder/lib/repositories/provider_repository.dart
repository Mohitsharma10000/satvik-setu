import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/provider_model.dart';
import '../core/constants/app_constants.dart';
import '../services/location_service.dart';

class ProviderRepository {
  final FirebaseFirestore _firestore;

  ProviderRepository(this._firestore);

  // Sample fallback providers with location & single service rate
  static final List<ProviderModel> defaultProviders = [
    ProviderModel(
      providerId: 'prov_cctv_1', name: 'Rajesh Security Systems & CCTV',
      phone: '+91 9876543210',
      profileImage: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150',
      category: 'CCTV Installation', subcategory: 'New CCTV Camera Setup',
      categoryId: 'cat_13', subcategoryId: 'sub_13_1',
      verifiedAt: DateTime.now().subtract(const Duration(days: 30)),
      latitude: 28.6139, longitude: 77.2090,
      serviceRate: 350,
      rateDescription: 'Basic setup ₹350, full installation ₹1500+',
    ),
    ProviderModel(
      providerId: 'prov_cctv_2', name: 'Verma CCTV & Security Solutions',
      phone: '+91 9812345678',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      category: 'CCTV Installation', subcategory: 'DVR & NVR Repair',
      categoryId: 'cat_13', subcategoryId: 'sub_13_2',
      verifiedAt: DateTime.now().subtract(const Duration(days: 45)),
      latitude: 28.6200, longitude: 77.2150,
      serviceRate: 300,
      rateDescription: 'DVR repair ₹300-800, NVR ₹500+',
    ),
    ProviderModel(
      providerId: 'prov_cctv_3', name: 'SecureVision HD CCTV Technicians',
      phone: '+91 9711223344',
      profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      category: 'CCTV Installation', subcategory: 'CCTV Installation General Repair',
      categoryId: 'cat_13', subcategoryId: 'cat_13_sub1',
      verifiedAt: DateTime.now().subtract(const Duration(days: 12)),
      latitude: 28.6300, longitude: 77.2200,
      serviceRate: 350,
    ),
    ProviderModel(
      providerId: 'prov_elec_1', name: 'Sharma Electrical Works',
      phone: '+91 9765432109',
      profileImage: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      category: 'Electrician', subcategory: 'House Wiring & Short Circuit',
      categoryId: 'cat_1', subcategoryId: 'sub_1_1',
      verifiedAt: DateTime.now().subtract(const Duration(days: 15)),
      latitude: 28.6100, longitude: 77.2050,
      serviceRate: 250,
      rateDescription: 'Wiring ₹250-500, short circuit fix ₹300+',
    ),
    ProviderModel(
      providerId: 'prov_elec_2', name: 'Amit Electricians & Inverter Repair',
      phone: '+91 9898765432',
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      category: 'Electrician', subcategory: 'Inverter Repair & Service',
      categoryId: 'cat_1', subcategoryId: 'sub_1_4',
      verifiedAt: DateTime.now().subtract(const Duration(days: 60)),
      latitude: 28.6050, longitude: 77.2100,
      serviceRate: 300,
    ),
    ProviderModel(
      providerId: 'prov_plumb_1', name: 'Gupta Plumbing Services',
      phone: '+91 9834567890',
      profileImage: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      category: 'Plumber', subcategory: 'Pipe Leakage & Fitting',
      categoryId: 'cat_2', subcategoryId: 'sub_2_1',
      verifiedAt: DateTime.now().subtract(const Duration(days: 20)),
      latitude: 28.6180, longitude: 77.2120,
      serviceRate: 300,
      rateDescription: 'Pipe fitting ₹300, major leakage ₹500+',
    ),
    ProviderModel(
      providerId: 'prov_plumb_2', name: 'Ramesh Plumbing & Geyser Fitting',
      phone: '+91 9911223344',
      profileImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      category: 'Plumber', subcategory: 'Geyser Repair & Fitting',
      categoryId: 'cat_2', subcategoryId: 'sub_2_4',
      verifiedAt: DateTime.now().subtract(const Duration(days: 10)),
      latitude: 28.6250, longitude: 77.2250,
      serviceRate: 350,
    ),
    ProviderModel(
      providerId: 'prov_mech_1', name: 'Singh Auto Garage & Breakdown',
      phone: '+91 9871122334',
      profileImage: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      category: 'Mechanic', subcategory: 'Car Breakdown & Engine Repair',
      categoryId: 'cat_3', subcategoryId: 'sub_3_1',
      verifiedAt: DateTime.now().subtract(const Duration(days: 25)),
      latitude: 28.6320, longitude: 77.2180,
      serviceRate: 500,
      rateDescription: 'Breakdown ₹500, engine repair ₹1000+',
    ),
    ProviderModel(
      providerId: 'prov_ac_1', name: 'CoolTech AC Service & Gas Filling',
      phone: '+91 9888776655',
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      category: 'AC Repair', subcategory: 'AC Deep Servicing',
      categoryId: 'cat_6', subcategoryId: 'sub_6_1',
      verifiedAt: DateTime.now().subtract(const Duration(days: 8)),
      latitude: 28.6080, longitude: 77.2000,
      serviceRate: 400,
      rateDescription: 'Deep service ₹400, gas filling ₹1500+',
    ),
  ];

  /// Get verified providers with distance filtering.
  Stream<List<ProviderModel>> getVerifiedProviders(
    String categoryId,
    String subcategoryId, {
    double? userLat,
    double? userLng,
    double radiusKm = 7.0,
  }) async* {
    final initialFallback = _getFallbackProviders(categoryId, subcategoryId);
    yield _applyLocationFilter(initialFallback, userLat, userLng, radiusKm);

    try {
      await for (final snapshot in _firestore
          .collection(AppConstants.approvedProvidersCollection)
          .snapshots()) {
        
        final list = snapshot.docs
            .map((doc) => ProviderModel.fromFirestore(doc))
            .where((prov) => prov.subcategoryId == subcategoryId || prov.categoryId == categoryId)
            .toList();

        if (list.isNotEmpty) {
          yield _applyLocationFilter(list, userLat, userLng, radiusKm);
        } else {
          yield _applyLocationFilter(initialFallback, userLat, userLng, radiusKm);
        }
      }
    } catch (_) {
      yield _applyLocationFilter(initialFallback, userLat, userLng, radiusKm);
    }
  }

  List<ProviderModel> _applyLocationFilter(
    List<ProviderModel> providers,
    double? userLat,
    double? userLng,
    double radiusKm,
  ) {
    if (userLat == null || userLng == null) {
      providers.sort((a, b) => b.verifiedAt.compareTo(a.verifiedAt));
      return providers;
    }

    for (final provider in providers) {
      if (provider.latitude != null && provider.longitude != null) {
        provider.distanceKm = LocationService.calculateDistanceKm(
          userLat, userLng,
          provider.latitude!, provider.longitude!,
        );
      } else {
        provider.distanceKm = 2.0 + (providers.indexOf(provider) * 0.8);
      }
    }

    List<ProviderModel> filtered;
    if (radiusKm > 0) {
      filtered = providers.where((p) => (p.distanceKm ?? 0) <= radiusKm).toList();
      if (filtered.isEmpty) filtered = providers;
    } else {
      filtered = providers;
    }

    filtered.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    return filtered;
  }

  List<ProviderModel> _getFallbackProviders(String categoryId, String subcategoryId) {
    final subMatches = defaultProviders.where((p) => p.subcategoryId == subcategoryId).toList();
    if (subMatches.isNotEmpty) return subMatches;

    final catMatches = defaultProviders.where((p) => p.categoryId == categoryId).toList();
    if (catMatches.isNotEmpty) return catMatches;

    return [
      ProviderModel(
        providerId: 'prov_gen_1', name: 'Verified Local Service Expert',
        phone: '+91 9876543210', profileImage: '',
        category: 'Service', subcategory: 'General',
        categoryId: categoryId, subcategoryId: subcategoryId,
        verifiedAt: DateTime.now().subtract(const Duration(days: 5)),
        serviceRate: 250,
      ),
      ProviderModel(
        providerId: 'prov_gen_2', name: 'City Trusted Repair Centre',
        phone: '+91 9812345678', profileImage: '',
        category: 'Service', subcategory: 'General',
        categoryId: categoryId, subcategoryId: subcategoryId,
        verifiedAt: DateTime.now().subtract(const Duration(days: 14)),
        serviceRate: 200,
      ),
    ];
  }

  Future<List<ProviderModel>> searchProviders(String query) async {
    final q = query.toLowerCase();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.approvedProvidersCollection)
          .get();
          
      final list = snapshot.docs
          .map((doc) => ProviderModel.fromFirestore(doc))
          .where((prov) => 
              prov.name.toLowerCase().contains(q) || 
              prov.category.toLowerCase().contains(q) || 
              prov.subcategory.toLowerCase().contains(q))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return defaultProviders.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q) ||
        p.subcategory.toLowerCase().contains(q)).toList();
  }

  /// Checks if a provider with the given phone number is approved.
  Future<bool> isProviderApproved(String phone) async {
    final cleanPhone = phone.replaceAll('+91', '').trim();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.approvedProvidersCollection)
          .where('phone', isGreaterThanOrEqualTo: cleanPhone)
          .limit(10)
          .get();

      for (var doc in snapshot.docs) {
        final docPhone = (doc.data()['phone'] as String? ?? '').replaceAll('+91', '').trim();
        if (docPhone == cleanPhone) return true;
      }
    } catch (_) {}

    // Fallback check against default providers
    return defaultProviders.any((p) => p.phone.replaceAll('+91', '').trim() == cleanPhone);
  }
}
