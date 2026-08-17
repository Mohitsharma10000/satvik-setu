import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../core/constants/app_constants.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository();
});

class PaymentRepository {
  final FirebaseFirestore _firestore;

  PaymentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore.collection(AppConstants.paymentsCollection).add(payment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<void> updatePayment(String paymentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.paymentsCollection).doc(paymentId).update(data);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore.collection(AppConstants.paymentsCollection).doc(paymentId).get();
      if (doc.exists && doc.data() != null) {
        return PaymentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  Stream<List<PaymentModel>> getUserPayments(String userId) {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    });
  }

  Future<bool> hasValidPayment(String userId, String categoryId, [String? subcategoryId, int validityHours = 24]) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('userId', isEqualTo: userId)
          .where('categoryId', isEqualTo: categoryId)
          .where('paymentStatus', isEqualTo: 'successful')
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) {
          final difference = DateTime.now().difference(createdAt);
          if (difference.inHours < validityHours) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
