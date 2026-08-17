import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_shell.dart';
import 'feature_providers.dart';
import 'feature_form_dialog.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../models/app_feature_model.dart';

class FeaturesManagementPage extends ConsumerWidget {
  const FeaturesManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuresAsync = ref.watch(featuresStreamProvider);

    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🚀 Dynamic App Features & Banners',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add new features, banners & announcements directly to the User App home screen in real-time!',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Feature / Banner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const FeatureFormDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: featuresAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                data: (features) {
                  if (features.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 64, color: Colors.indigo.shade300),
                          const SizedBox(height: 16),
                          const Text('No Dynamic Features Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Click "Add New Feature / Banner" to publish custom cards directly to the user app!'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Dynamic Feature'),
                            onPressed: () {
                              showDialog(context: context, builder: (_) => const FeatureFormDialog());
                            },
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
                            DataColumn(label: Text('Badge')),
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Order')),
                            DataColumn(label: Text('Active')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: features.map((feat) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.shade400),
                                    ),
                                    child: Text(
                                      feat.badgeText,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber.shade900),
                                    ),
                                  ),
                                ),
                                DataCell(Text(feat.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(
                                  SizedBox(
                                    width: 250,
                                    child: Text(feat.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                                DataCell(Text(feat.order.toString())),
                                DataCell(
                                  Switch(
                                    value: feat.isActive,
                                    onChanged: (val) {
                                      final repo = ref.read(featureRepositoryProvider);
                                      repo.updateFeature(
                                        AppFeatureModel(
                                          id: feat.id,
                                          title: feat.title,
                                          description: feat.description,
                                          badgeText: feat.badgeText,
                                          order: feat.order,
                                          isActive: val,
                                          createdAt: feat.createdAt,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => FeatureFormDialog(feature: feat),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => const ConfirmationDialog(
                                              title: 'Delete Feature',
                                              message: 'Are you sure you want to delete this dynamic feature card?',
                                              isDestructive: true,
                                            ),
                                          );
                                          if (confirm == true) {
                                            ref.read(featureRepositoryProvider).deleteFeature(feat.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
