import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../repositories/service_request_repository.dart';
import '../../models/service_request_model.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/empty_state.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Service Requests')),
        body: const Center(child: Text('Please log in to view your service requests.')),
      );
    }

    final requestsStream = ref.watch(serviceRequestRepositoryProvider).getRequestsByUser(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Service Requests'),
      ),
      body: StreamBuilder<List<ServiceRequestModel>>(
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
              icon: Icons.assignment_outlined,
              title: 'No Requests Yet',
              subtitle: 'When you request a service, it will appear here with live tracking.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return _RequestCard(request: req);
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequestModel request;

  const _RequestCard({required this.request});

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

  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'Waiting for Provider';
      case 'accepted':
        return 'Request Accepted';
      case 'rejected':
        return 'Declined by Provider';
      case 'on_the_way':
        return 'Provider On The Way 🚗';
      case 'work_started':
        return 'Work In Progress 🛠️';
      case 'completed':
        return 'Completed ✅';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(request.requestedAt);
    final urlLauncher = UrlLauncherService();

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
                    request.category,
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
                    _getStatusText(request.status),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              request.subcategory,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Provider: ${request.providerName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                if (request.providerPhone.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green, size: 20),
                    onPressed: () => urlLauncher.makePhoneCall(request.providerPhone),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Advance Paid', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('₹${request.advancePaid.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Remaining to Pay Provider', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        '₹${(request.remainingAmount ?? 0).toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (request.status == 'completed' &&
                (request.completionNotes != null || request.completionPhotos.isNotEmpty)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Work Completion Proof'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (request.completionNotes != null) ...[
                                const Text('Notes from Provider:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(request.completionNotes!),
                                const SizedBox(height: 12),
                              ],
                              if (request.completionPhotos.isNotEmpty) ...[
                                const Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: request.completionPhotos.map((img) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(img),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified, color: Colors.green),
                  label: const Text('View Work Completion Proof'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
