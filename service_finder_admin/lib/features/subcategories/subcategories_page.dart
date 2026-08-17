import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_shell.dart';
import 'subcategory_providers.dart';
import 'subcategory_form_dialog.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../models/subcategory_model.dart';

class SubcategoriesPage extends ConsumerWidget {
  const SubcategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(null));

    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subcategories', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subcategory'),
                  onPressed: () {
                    showDialog(context: context, builder: (_) => const SubcategoryFormDialog());
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: subcategoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (subcategories) {
                  return Card(
                    child: ListView(
                      children: [
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Category ID')),
                            DataColumn(label: Text('Order')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: subcategories.map((subcat) {
                            return DataRow(
                              cells: [
                                DataCell(Text(subcat.name)),
                                DataCell(Text(subcat.categoryId)),
                                DataCell(Text(subcat.order.toString())),
                                DataCell(
                                  Switch(
                                    value: subcat.isActive,
                                    onChanged: (val) {
                                      final repo = ref.read(subcategoryRepositoryProvider);
                                      repo.updateSubcategory(
                                        SubcategoryModel(id: subcat.id, categoryId: subcat.categoryId, name: subcat.name, order: subcat.order, isActive: val, createdAt: subcat.createdAt)
                                      );
                                    },
                                  )
                                ),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => showDialog(context: context, builder: (_) => SubcategoryFormDialog(subcategory: subcat)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => const ConfirmationDialog(title: 'Delete Subcategory', message: 'Delete this subcategory?', isDestructive: true),
                                        );
                                        if (confirm == true) {
                                          ref.read(subcategoryRepositoryProvider).deleteSubcategory(subcat.id);
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
