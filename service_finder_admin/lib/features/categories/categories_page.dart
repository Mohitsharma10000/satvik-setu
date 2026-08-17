import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_shell.dart';
import 'category_providers.dart';
import 'category_form_dialog.dart';
import '../../models/category_model.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/seed_helper.dart';
import '../../core/providers/firebase_providers.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  bool _isSeeding = false;

  void _seedDefaultData() async {
    setState(() => _isSeeding = true);
    try {
      final firestore = ref.read(firestoreProvider);
      await SeedHelper.seedDefaultCategories(firestore);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 21 Default Categories & Subcategories created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Categories', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
                      icon: _isSeeding ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.dataset),
                      label: Text(_isSeeding ? 'Seeding...' : 'Seed 21 Categories'),
                      onPressed: _isSeeding ? null : _seedDefaultData,
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const CategoryFormDialog());
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $err', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(categoriesStreamProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (categories) {
                  if (categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No Categories Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Click "Seed 21 Categories" above to automatically create all default categories.', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                            icon: const Icon(Icons.flash_on),
                            label: const Text('Auto-Populate 21 Categories'),
                            onPressed: _seedDefaultData,
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    child: ListView(
                      children: [
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Icon')),
                            DataColumn(label: Text('Category Name')),
                            DataColumn(label: Text('Advance Fee')),
                            DataColumn(label: Text('Order')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: categories.map((cat) {
                            return DataRow(
                              cells: [
                                const DataCell(Icon(Icons.category, color: Color(0xFF1A237E))),
                                DataCell(Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: Text(
                                      '₹${cat.advanceFee.toInt()}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                    ),
                                  ),
                                ),
                                DataCell(Text(cat.order.toString())),
                                DataCell(
                                  Switch(
                                    value: cat.isActive,
                                    onChanged: (val) {
                                      final repo = ref.read(categoryRepositoryProvider);
                                      repo.updateCategory(
                                        CategoryModel(id: cat.id, name: cat.name, icon: cat.icon, order: cat.order, advanceFee: cat.advanceFee, isActive: val, createdAt: cat.createdAt)
                                      );
                                    },
                                  )
                                ),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit Category & Fee',
                                      onPressed: () => showDialog(context: context, builder: (_) => CategoryFormDialog(category: cat)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => const ConfirmationDialog(title: 'Delete Category', message: 'Delete this category?', isDestructive: true),
                                        );
                                        if (confirm == true) {
                                          ref.read(categoryRepositoryProvider).deleteCategory(cat.id);
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ]
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
