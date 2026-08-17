import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_shell.dart';
import '../../models/dynamic_feature_model.dart';
import 'custom_feature_form_dialog.dart';
import '../../widgets/confirmation_dialog.dart';

class CustomBuilderPage extends ConsumerStatefulWidget {
  const CustomBuilderPage({super.key});

  @override
  ConsumerState<CustomBuilderPage> createState() => _CustomBuilderPageState();
}

class _CustomBuilderPageState extends ConsumerState<CustomBuilderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      '⚡ Dynamic Feature & Form Creator',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Build complete interactive features & custom forms. Instant zero-update deployment to User App!',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Build New Feature'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CustomFeatureFormDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            TabBar(
              controller: _tabController,
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
              tabs: const [
                Tab(icon: Icon(Icons.widgets), text: 'Dynamic Modules & Forms'),
                Tab(icon: Icon(Icons.inbox), text: 'User Submissions & Responses'),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildModulesTab(),
                  _buildSubmissionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dynamic_features').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build_circle_outlined, size: 64, color: Colors.indigo.shade300),
                const SizedBox(height: 16),
                const Text('No Custom Dynamic Features Created Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Click "Build New Feature" to build customized forms & interactive tools for users!'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Build First Custom Feature'),
                  onPressed: () {
                    showDialog(context: context, builder: (_) => const CustomFeatureFormDialog());
                  },
                ),
              ],
            ),
          );
        }

        final features = docs.map((d) => DynamicFeatureModel.fromFirestore(d)).toList();

        return ListView.builder(
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feat = features[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade50,
                  child: Icon(Icons.widgets, color: Colors.indigo.shade700),
                ),
                title: Row(
                  children: [
                    Text(feat.featureName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(feat.badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                    ),
                  ],
                ),
                subtitle: Text('${feat.description}\nFields (${feat.fields.length}): ${feat.fields.map((f) => f.label).join(', ')}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: feat.isActive,
                      onChanged: (val) {
                        FirebaseFirestore.instance.collection('dynamic_features').doc(feat.id).update({'isActive': val});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => CustomFeatureFormDialog(feature: feat));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => const ConfirmationDialog(
                            title: 'Delete Feature',
                            message: 'Delete this dynamic feature module?',
                            isDestructive: true,
                          ),
                        );
                        if (confirm == true) {
                          FirebaseFirestore.instance.collection('dynamic_features').doc(feat.id).delete();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubmissionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('custom_feature_submissions')
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No User Submissions Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final featureName = data['featureName'] ?? 'Custom Request';
            final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate();
            final responseMap = data['responseMap'] as Map<String, dynamic>? ?? {};

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
                title: Text(featureName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Submitted: ${submittedAt != null ? submittedAt.toString().substring(0, 16) : "Just now"}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: responseMap.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(e.value.toString())),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
