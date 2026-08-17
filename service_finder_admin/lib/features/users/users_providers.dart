import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

final usersQueryProvider = StateProvider<String>((ref) => '');

final usersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(usersQueryProvider).toLowerCase();
  
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .snapshots()
      .map((snapshot) {
    final users = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
    
    if (query.isEmpty) return users;
    
    return users.where((user) {
      final phone = (user['phoneNumber'] as String?)?.toLowerCase() ?? '';
      final name = (user['displayName'] as String?)?.toLowerCase() ?? '';
      return phone.contains(query) || name.contains(query);
    }).toList();
  });
});

final userPaymentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(AppConstants.paymentsCollection)
      .where('userId', isEqualTo: userId)
      .get();
      
  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }).toList();
});
