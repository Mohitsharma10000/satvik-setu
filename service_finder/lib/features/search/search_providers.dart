import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/provider_model.dart';
import '../providers/provider_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<ProviderModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  
  final repo = ref.watch(providerRepositoryProvider);
  return repo.searchProviders(query);
});
