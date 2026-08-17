import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../repositories/service_request_repository.dart';
import '../../models/service_request_model.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/empty_state.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provider Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to access your provider dashboard.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/provider-login'),
                child: const Text('Provider Login'),
              ),
            ],
          ),
        ),
      );
    }

    final requestsStream = ref.watch(serviceRequestRepositoryProvider).getRequestsByProvider(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) context.go('/home');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.displayName ?? "Service Provider"} 👋',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Phone: ${user.phoneNumber ?? "N/A"}'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Service Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ServiceRequestModel>>(
              stream: requestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No Incoming Requests',
                    subtitle: 'New customer requests in your category will appear here in real-time.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return _ProviderRequestCard(request: req);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderRequestCard extends ConsumerWidget {
  final ServiceRequestModel request;

  const _ProviderRequestCard({required this.request});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.amber.shade800;
      case 'accepted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'on_the_way':
        return Colors.purple;
      case 'work_started':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(request.status);
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(request.requestedAt);
    final urlLauncher = UrlLauncherService();
    final repo = ref.read(serviceRequestRepositoryProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${request.category} - ${request.subcategory}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Customer: ${request.userName}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(request.userPhone.isEmpty ? 'N/A' : request.userPhone),
                const Spacer(),
                if (request.userPhone.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () => urlLauncher.makePhoneCall(request.userPhone),
                  ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(request.serviceLocation, style: const TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Advance Access Fee Paid:'),
                const Text('₹10.00 ✅', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining Amount to Collect:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '₹${(request.remainingAmount ?? 0).toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons Based on Status
            if (request.status == 'requested') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await repo.updateRequestStatus(request.requestId!, 'rejected');
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await repo.updateRequestStatus(request.requestId!, 'accepted');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Accept Request'),
                    ),
                  ),
                ],
              ),
            ] else if (request.status == 'accepted') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await repo.updateRequestStatus(request.requestId!, 'on_the_way');
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Mark "On the Way" 🚗'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                ),
              ),
            ] else if (request.status == 'on_the_way') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await repo.updateRequestStatus(request.requestId!, 'work_started');
                  },
                  icon: const Icon(Icons.build),
                  label: const Text('Mark "Work Started" 🛠️'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
              ),
            ] else if (request.status == 'work_started') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/completion-proof/${request.requestId}');
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Complete Work & Upload Proof 📸'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ),
            ] else if (request.status == 'completed') ...[
              const Center(
                child: Text('Service Completed & Proof Uploaded ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
