import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_shell.dart';

final requestsStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('service_requests')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

class RequestsManagementPage extends ConsumerStatefulWidget {
  const RequestsManagementPage({super.key});

  @override
  ConsumerState<RequestsManagementPage> createState() => _RequestsManagementPageState();
}

class _RequestsManagementPageState extends ConsumerState<RequestsManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Requested', 'In Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(requestsStreamProvider);

    return AdminShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            onTap: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                final currentTab = _tabs[_tabController.index];
                
                final filteredRequests = currentTab == 'All'
                    ? requests
                    : requests.where((r) {
                        final status = (r['status'] ?? '').toString().toLowerCase();
                        if (currentTab == 'In Progress') return status == 'in progress' || status == 'inprogress';
                        return status == currentTab.toLowerCase();
                      }).toList();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        columns: const [
                          DataColumn(label: Text('Customer Info')),
                          DataColumn(label: Text('Provider Info')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Date Requested')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredRequests.map((request) {
                          final createdAt = request['createdAt'] as Timestamp?;
                          final dateStr = createdAt != null
                              ? DateFormat('MMM dd, yyyy HH:mm').format(createdAt.toDate())
                              : 'N/A';
                          
                          final status = (request['status'] ?? 'Unknown').toString();
                          
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(request['customerName'] ?? 'Unknown'),
                                    Text(
                                      request['customerPhone'] ?? 'No Phone',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(request['providerName'] ?? 'Unknown'),
                                    Text(
                                      request['providerPhone'] ?? 'No Phone',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(request['category'] ?? 'N/A'),
                                    Text(
                                      request['subcategory'] ?? 'N/A',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(dateStr)),
                              DataCell(_buildStatusChip(status)),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _showDetailsDialog(context, request),
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('View Details & Proof'),
                                  style: ElevatedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading requests: $error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'completed') {
      color = Colors.green;
    } else if (lowerStatus == 'in progress' || lowerStatus == 'inprogress') {
      color = Colors.blue;
    } else if (lowerStatus == 'requested') {
      color = Colors.amber;
    } else if (lowerStatus == 'cancelled') {
      color = Colors.red;
    } else {
      color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) {
        final status = (request['status'] ?? '').toString().toLowerCase();
        final isCompleted = status == 'completed';

        return AlertDialog(
          title: const Text('Service Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionTitle('Customer Information'),
                Text('Name: ${request['customerName'] ?? 'N/A'}'),
                Text('Phone: ${request['customerPhone'] ?? 'N/A'}'),
                Text('Location: ${request['location'] ?? 'N/A'}'),
                const Divider(),
                
                _buildSectionTitle('Provider Information'),
                Text('Name: ${request['providerName'] ?? 'N/A'}'),
                Text('Phone: ${request['providerPhone'] ?? 'N/A'}'),
                const Divider(),

                _buildSectionTitle('Payment Details'),
                Text('Advance Paid: ₹${request['advancePaid'] ?? '10.0'}'),
                Text('Estimated Charge: ₹${request['estimatedCharge'] ?? 'N/A'}'),
                const Divider(),

                if (isCompleted) ...[
                  _buildSectionTitle('Completion Details'),
                  if (request['completionNotes'] != null) ...[
                    Text('Notes: ${request['completionNotes']}'),
                    const SizedBox(height: 8),
                  ],
                  if (request['beforePhotos'] != null && (request['beforePhotos'] as List).isNotEmpty) ...[
                    const Text('Before Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildImageRow(context, List<String>.from(request['beforePhotos'])),
                    const SizedBox(height: 16),
                  ],
                  if (request['afterPhotos'] != null && (request['afterPhotos'] as List).isNotEmpty) ...[
                    const Text('After Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildImageRow(context, List<String>.from(request['afterPhotos'])),
                    const SizedBox(height: 16),
                  ],
                  if (request['invoiceImage'] != null) ...[
                    const Text('Invoice:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildImageRow(context, [request['invoiceImage'] as String]),
                  ],
                ] else ...[
                  const Text('Completion details will be available once the request is completed.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildImageRow(BuildContext context, List<String> imageUrls) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: imageUrls.map((url) {
        return GestureDetector(
          onTap: () {
            // Check if ImageViewerDialog exists, otherwise just open it in a simpler dialog
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Stack(
                  children: [
                    Image.network(url, fit: BoxFit.contain),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
