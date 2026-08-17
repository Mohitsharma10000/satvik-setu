import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/stat_card.dart';
import '../../core/constants/app_constants.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminShell(
      child: Scaffold(
        appBar: AppBar(title: const Text('Analytics & Platform Reports')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Platform Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(AppConstants.paymentsCollection).snapshots(),
                builder: (context, paySnap) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection(AppConstants.serviceRequestsCollection).snapshots(),
                    builder: (context, reqSnap) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection(AppConstants.usersCollection).snapshots(),
                        builder: (context, userSnap) {
                          final paymentsCount = paySnap.data?.docs.length ?? 0;
                          final revenue = paymentsCount * 10;
                          final requestsCount = reqSnap.data?.docs.length ?? 0;
                          final completedCount = reqSnap.data?.docs
                                  .where((d) => (d.data() as Map)['status'] == 'completed')
                                  .length ??
                              0;
                          final usersCount = userSnap.data?.docs.length ?? 0;

                          return Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: [
                                  StatCard(
                                    title: 'Total Advance Revenue',
                                    value: '₹$revenue',
                                    icon: Icons.currency_rupee,
                                    color: Colors.green,
                                  ),
                                  StatCard(
                                    title: 'Successful Advance Payments',
                                    value: '$paymentsCount',
                                    icon: Icons.payments,
                                    color: Colors.blue,
                                  ),
                                  StatCard(
                                    title: 'Total Service Requests',
                                    value: '$requestsCount',
                                    icon: Icons.build,
                                    color: Colors.purple,
                                  ),
                                  StatCard(
                                    title: 'Completed Jobs',
                                    value: '$completedCount',
                                    icon: Icons.check_circle,
                                    color: Colors.teal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'System Performance Metrics',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.people, color: Colors.blue),
                                        title: const Text('Registered Verified Users'),
                                        trailing: Text('$usersCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.verified, color: Colors.teal),
                                        title: const Text('Advance Access Fee Model'),
                                        subtitle: const Text('₹10 advance fee deducted from provider final payment'),
                                        trailing: const Chip(label: Text('Active ✅'), backgroundColor: Colors.greenAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
