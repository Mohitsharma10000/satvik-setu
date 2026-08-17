import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_request_model.dart';
import '../core/constants/app_constants.dart';

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((ref) {
  return ServiceRequestRepository();
});

class ServiceRequestRepository {
  final FirebaseFirestore _firestore;

  ServiceRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createRequest(ServiceRequestModel request) async {
    try {
      final docRef = await _firestore.collection(AppConstants.serviceRequestsCollection).add(request.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service request: $e');
    }
  }

  Future<ServiceRequestModel?> getRequest(String requestId) async {
    try {
      final doc = await _firestore.collection(AppConstants.serviceRequestsCollection).doc(requestId).get();
      if (doc.exists && doc.data() != null) {
        return ServiceRequestModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service request: $e');
    }
  }

  Stream<List<ServiceRequestModel>> getRequestsByUser(String userId) {
    return _firestore
        .collection(AppConstants.serviceRequestsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceRequestModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<ServiceRequestModel>> getRequestsByProvider(String providerId) {
    return _firestore
        .collection(AppConstants.serviceRequestsCollection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceRequestModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection(AppConstants.serviceRequestsCollection).doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  Future<void> addCompletionProof(
    String requestId, {
    List<String>? beforePhotos,
    List<String>? afterPhotos,
    List<String>? completionPhotos,
    String? completionNotes,
    String? invoice,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (beforePhotos != null) updateData['beforePhotos'] = beforePhotos;
      if (afterPhotos != null) updateData['afterPhotos'] = afterPhotos;
      if (completionPhotos != null) updateData['completionPhotos'] = completionPhotos;
      if (completionNotes != null) updateData['completionNotes'] = completionNotes;
      if (invoice != null) updateData['invoice'] = invoice;

      if (updateData.isNotEmpty) {
        await _firestore.collection(AppConstants.serviceRequestsCollection).doc(requestId).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to add completion proof: $e');
    }
  }

  Future<void> markCompleted(String requestId) async {
    try {
      await _firestore.collection(AppConstants.serviceRequestsCollection).doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark request as completed: $e');
    }
  }
}
