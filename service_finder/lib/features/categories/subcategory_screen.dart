import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'subcategory_providers.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

class SubcategoryScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const SubcategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriesAsync = ref.watch(subcategoriesProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: subcategoriesAsync.when(
        data: (subcategories) {
          if (subcategories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: 'No Subcategories',
              subtitle: 'We are expanding our services soon.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final subcat = subcategories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    subcat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push(
                      '/category/$categoryId/subcategory/${subcat.id}',
                      extra: {
                        'subcategoryName': subcat.name,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(subcategoriesProvider(categoryId)),
        ),
      ),
    );
  }
}
