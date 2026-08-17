import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

// Analytics Providers

final totalRevenueProvider = FutureProvider<double>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.paymentsCollection)
      .where('status', isEqualTo: 'success')
      .get();
      
  double total = 0;
  for (var doc in snap.docs) {
    total += (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
  }
  return total;
});

final totalCompletedJobsProvider = FutureProvider<int>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.serviceRequestsCollection)
      .where('status', isEqualTo: 'completed')
      .count()
      .get();
  return snap.count ?? 0;
});

final activeProvidersProvider = FutureProvider<int>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.providersCollection)
      .where('isActive', isEqualTo: true)
      .count()
      .get();
  return snap.count ?? 0;
});

final verifiedUsersProvider = FutureProvider<int>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .where('isVerified', isEqualTo: true)
      .count()
      .get();
  return snap.count ?? 0;
});

final categoryDemandProvider = FutureProvider<Map<String, int>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.serviceRequestsCollection)
      .get();
      
  final Map<String, int> counts = {};
  for (var doc in snap.docs) {
    final category = doc.data()['category'] as String? ?? 'Unknown';
    counts[category] = (counts[category] ?? 0) + 1;
  }
  
  // Sort by count descending
  final sortedEntries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
    
  return Map.fromEntries(sortedEntries.take(5)); // Top 5
});

final weeklyServiceRequestsProvider = FutureProvider<Map<String, int>>((ref) async {
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.serviceRequestsCollection)
      .where('createdAt', isGreaterThanOrEqualTo: weekAgo)
      .get();
      
  final Map<String, int> dailyCounts = {
    for (int i = 0; i < 7; i++)
      "${now.subtract(Duration(days: i)).day}/${now.subtract(Duration(days: i)).month}": 0
  };
  
  for (var doc in snap.docs) {
    final data = doc.data();
    if (data['createdAt'] is Timestamp) {
      final date = (data['createdAt'] as Timestamp).toDate();
      final key = "${date.day}/${date.month}";
      if (dailyCounts.containsKey(key)) {
        dailyCounts[key] = dailyCounts[key]! + 1;
      }
    }
  }
  
  return dailyCounts;
});
