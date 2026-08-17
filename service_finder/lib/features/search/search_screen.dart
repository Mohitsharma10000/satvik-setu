import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'search_providers.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/empty_state.dart';
import '../../services/url_launcher_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final UrlLauncherService _urlLauncher = UrlLauncherService();

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for providers...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? const EmptyState(
              icon: Icons.search,
              title: 'Search Providers',
              subtitle: 'Type a name or category to find services',
            )
          : searchResultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No Results Found',
                    subtitle: 'Try adjusting your search terms',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final provider = results[index];
                    return ProviderCard(
                      name: provider.name,
                      phone: provider.phone,
                      profileImage: provider.profileImage,
                      address: provider.fullAddress,
                      serviceRate: provider.serviceRate,
                      rateDescription: provider.rateDescription,
                      isUnlocked: false,
                      onTap: () {
                        context.push(
                          '/payment-gate',
                          extra: {
                            'categoryId': provider.categoryId,
                            'subcategoryId': provider.subcategoryId,
                            'categoryName': provider.category,
                            'subcategoryName': provider.subcategory,
                          },
                        );
                      },
                      onPhoneTap: () {
                        context.push(
                          '/payment-gate',
                          extra: {
                            'categoryId': provider.categoryId,
                            'subcategoryId': provider.subcategoryId,
                            'categoryName': provider.category,
                            'subcategoryName': provider.subcategory,
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }
}
