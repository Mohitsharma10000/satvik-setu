import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/stat_card.dart';

final paymentsStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('payments')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsStreamProvider);

    return AdminShell(
      child: paymentsAsync.when(
        data: (payments) {
          final successfulPayments = payments.where((p) => p['status'] == 'Success' || p['status'] == 'successful').toList();
          final pendingPayments = payments.where((p) => p['status'] == 'Pending' || p['status'] == 'pending').toList();
          final failedPayments = payments.where((p) => p['status'] == 'Failed' || p['status'] == 'failed').toList();

          final totalRevenue = successfulPayments.length * 10.0; // ₹10 per successful payment

          final filteredPayments = _statusFilter == 'All'
              ? payments
              : payments.where((p) => (p['status'] ?? '').toString().toLowerCase() == _statusFilter.toLowerCase()).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Revenue',
                      value: '₹${totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Successful',
                      value: successfulPayments.length.toString(),
                      icon: Icons.check_circle,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Pending',
                      value: pendingPayments.length.toString(),
                      icon: Icons.pending,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Failed',
                      value: failedPayments.length.toString(),
                      icon: Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payments History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'Success', label: Text('Success')),
                      ButtonSegment(value: 'Pending', label: Text('Pending')),
                      ButtonSegment(value: 'Failed', label: Text('Failed')),
                    ],
                    selected: {_statusFilter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _statusFilter = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // DataTable
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        columns: const [
                          DataColumn(label: Text('User ID / Phone')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Transaction ID')),
                          DataColumn(label: Text('Date & Time')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: filteredPayments.map((payment) {
                          final createdAt = payment['createdAt'] as Timestamp?;
                          final dateStr = createdAt != null
                              ? DateFormat('MMM dd, yyyy HH:mm').format(createdAt.toDate())
                              : 'N/A';
                          
                          final status = (payment['status'] ?? 'Unknown').toString();
                          
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(payment['userPhone'] ?? 'No Phone'),
                                    Text(
                                      payment['userId'] ?? 'No ID',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text('₹${payment['amount'] ?? '10.0'}')),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(payment['category'] ?? 'N/A'),
                                    Text(
                                      payment['subcategory'] ?? 'N/A',
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
                                    Text(payment['razorpayPaymentId'] ?? payment['transactionId'] ?? 'N/A'),
                                  ],
                                ),
                              ),
                              DataCell(Text(dateStr)),
                              DataCell(_buildStatusChip(status)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading payments: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'success' || lowerStatus == 'successful') {
      color = Colors.green;
    } else if (lowerStatus == 'pending') {
      color = Colors.amber;
    } else if (lowerStatus == 'failed') {
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
}
