import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/stat_card.dart';
import 'dashboard_providers.dart';
import '../applications/application_providers.dart';
import '../../widgets/status_badge.dart';
import '../../utils/base64_image_helper.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Widget _buildErrorBanner(String title, Object error, WidgetRef ref) {
    final errorMsg = error.toString();
    final isPermission = errorMsg.contains('permission-denied') || errorMsg.contains('PERMISSION_DENIED');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Retry',
                onPressed: () {
                  ref.invalidate(applicationCountsProvider);
                  ref.invalidate(categoryCountProvider);
                  ref.invalidate(subcategoryCountProvider);
                  ref.invalidate(applicationsStreamProvider('all'));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPermission
                ? 'Permission Denied. Please ensure:\n'
                  '1. You are logged in as an admin\n'
                  '2. Firestore rules are published in Firebase Console\n'
                  '3. Your UID has a document in the "admins" collection'
                : 'Error: $errorMsg',
            style: TextStyle(color: Colors.red.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(applicationCountsProvider);
    final catCountAsync = ref.watch(categoryCountProvider);
    final subcatCountAsync = ref.watch(subcategoryCountProvider);
    final recentAppsAsync = ref.watch(applicationsStreamProvider('all'));

    // Check if ANY provider has a permission error
    final hasPermissionError = countsAsync.hasError || catCountAsync.hasError || subcatCountAsync.hasError;

    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(applicationCountsProvider);
            ref.invalidate(categoryCountProvider);
            ref.invalidate(subcategoryCountProvider);
            ref.invalidate(applicationsStreamProvider('all'));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Dashboard Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Dashboard',
                      onPressed: () {
                        ref.invalidate(applicationCountsProvider);
                        ref.invalidate(categoryCountProvider);
                        ref.invalidate(subcategoryCountProvider);
                        ref.invalidate(applicationsStreamProvider('all'));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Show error banner if any provider failed
                if (hasPermissionError)
                  _buildErrorBanner(
                    'Data Loading',
                    countsAsync.error ?? catCountAsync.error ?? subcatCountAsync.error ?? 'Unknown error',
                    ref,
                  ),

                // Stats grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 600) crossAxisCount = 1;
                    else if (constraints.maxWidth < 1000) crossAxisCount = 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: 'Total Applications',
                          value: countsAsync.when(
                            data: (c) => c['total']?.toString() ?? '0',
                            loading: () => '...',
                            error: (_, __) => '–',
                          ),
                          icon: Icons.assignment,
                          color: countsAsync.hasError ? Colors.grey : Colors.blue,
                        ),
                        StatCard(
                          title: 'Pending',
                          value: countsAsync.when(
                            data: (c) => c['pending']?.toString() ?? '0',
                            loading: () => '...',
                            error: (_, __) => '–',
                          ),
                          icon: Icons.pending,
                          color: countsAsync.hasError ? Colors.grey : Colors.amber,
                        ),
                        StatCard(
                          title: 'Approved',
                          value: countsAsync.when(
                            data: (c) => c['approved']?.toString() ?? '0',
                            loading: () => '...',
                            error: (_, __) => '–',
                          ),
                          icon: Icons.check_circle,
                          color: countsAsync.hasError ? Colors.grey : Colors.green,
                        ),
                        StatCard(
                          title: 'Rejected',
                          value: countsAsync.when(
                            data: (c) => c['rejected']?.toString() ?? '0',
                            loading: () => '...',
                            error: (_, __) => '–',
                          ),
                          icon: Icons.cancel,
                          color: countsAsync.hasError ? Colors.grey : Colors.red,
                        ),
                        StatCard(
                          title: 'Categories',
                          value: catCountAsync.when(
                            data: (c) => c.toString(),
                            loading: () => '...',
                            error: (_, __) => '–',
                          ),
                          icon: Icons.category,
                          color: catCountAsync.hasError ? Colors.grey : Colors.purple,
                        ),
                        StatCard(
                          title: 'Subcategories',
                          value: subcatCountAsync.when(
                            data: (c) => c.toString(),
                            loading: () => '...',
                            error: (_, __) => '–',
                          ),
                          icon: Icons.account_tree,
                          color: subcatCountAsync.hasError ? Colors.grey : Colors.indigo,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text('Recent Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                recentAppsAsync.when(
                  loading: () => const Center(
                    child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => _buildErrorBanner('Recent Applications', err, ref),
                  data: (apps) {
                    if (apps.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No applications found yet.',
                                style: TextStyle(fontSize: 16, color: Colors.grey)),
                              SizedBox(height: 4),
                              Text('Applications submitted via the user app will appear here.',
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }
                    final recent = apps.take(5).toList();
                    return Card(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recent.length,
                        itemBuilder: (context, index) {
                          final app = recent[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: app.profileImage.isNotEmpty ? Base64ImageHelper.getImageProvider(app.profileImage) : null,
                              child: app.profileImage.isEmpty ? const Icon(Icons.person) : null,
                            ),
                            title: Text(app.name),
                            subtitle: Text('${app.category} > ${app.subcategory}'),
                            trailing: StatusBadge(status: app.verificationStatus),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
