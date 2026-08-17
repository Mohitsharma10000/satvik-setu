import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_shell.dart';
import '../../core/constants/app_constants.dart';

class UsersManagementPage extends ConsumerStatefulWidget {
  const UsersManagementPage({super.key});

  @override
  ConsumerState<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      child: Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Users by Phone',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection(AppConstants.usersCollection).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    var docs = snapshot.data!.docs;
                    if (_searchQuery.isNotEmpty) {
                      docs = docs.where((doc) {
                        final phone = doc.data() is Map ? (doc.data() as Map)['phone'] ?? '' : '';
                        return phone.toString().contains(_searchQuery);
                      }).toList();
                    }

                    if (docs.isEmpty) {
                      return const Center(child: Text('No registered users found.'));
                    }

                    return Card(
                      child: ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final phone = data['phone'] ?? 'N/A';
                          final name = data['displayName'] ?? 'Customer';
                          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                          final formattedDate = createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt) : 'N/A';

                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Phone: $phone | Registered: $formattedDate'),
                            trailing: Chip(
                              label: const Text('OTP Verified'),
                              backgroundColor: Colors.green.shade50,
                              labelStyle: TextStyle(color: Colors.green.shade800, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
