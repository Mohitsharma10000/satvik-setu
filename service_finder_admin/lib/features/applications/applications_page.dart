import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin_shell.dart';
import 'application_providers.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import '../../utils/base64_image_helper.dart';

class ApplicationsPage extends ConsumerStatefulWidget {
  const ApplicationsPage({super.key});

  @override
  ConsumerState<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends ConsumerState<ApplicationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['all', 'pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Applications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () {
                    for (final status in _statuses) {
                      ref.invalidate(applicationsStreamProvider(status));
                    }
                  },
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statuses.map((status) => _ApplicationList(status: status)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationList extends ConsumerWidget {
  final String status;
  const _ApplicationList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(applicationsStreamProvider(status));

    return appsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        final errorMsg = err.toString();
        final isPermission = errorMsg.contains('permission-denied') || errorMsg.contains('PERMISSION_DENIED');

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPermission ? Icons.lock_outline : Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  isPermission ? 'Permission Denied' : 'Error Loading Applications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    isPermission
                        ? 'You don\'t have access to the applications collection.\n\n'
                          'To fix this:\n'
                          '1. Open Firebase Console → Firestore → Rules\n'
                          '2. Paste the updated firestore.rules from your project\n'
                          '3. Click "Publish"\n'
                          '4. Ensure your admin UID has a document in the "admins" collection'
                        : 'Error: $errorMsg',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () => ref.invalidate(applicationsStreamProvider(status)),
                ),
              ],
            ),
          ),
        );
      },
      data: (apps) {
        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No ${status == 'all' ? '' : '$status '}applications found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: app.profileImage.isNotEmpty ? Base64ImageHelper.getImageProvider(app.profileImage) : null,
                  child: app.profileImage.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${app.category} > ${app.subcategory}\nSubmitted: ${DateFormatter.format(app.submittedAt)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge(status: app.verificationStatus),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/applications/${app.id}'),
                      child: const Text('View'),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
