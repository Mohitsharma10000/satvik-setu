import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../core/constants/app_constants.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore;

  ApplicationRepository(this._firestore);

  Stream<List<ApplicationModel>> getApplications({String? status}) {
    Query query = _firestore.collection(AppConstants.applicationsCollection);
    
    if (status != null && status != 'all') {
      query = query.where('verificationStatus', isEqualTo: status);
    }

    // Do NOT handleError silently — let errors propagate to UI
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => ApplicationModel.fromFirestore(doc)).toList();
      list.sort((a, b) {
        if (a.submittedAt == null) return 1;
        if (b.submittedAt == null) return -1;
        return b.submittedAt!.compareTo(a.submittedAt!);
      });
      return list;
    });
  }

  Future<ApplicationModel?> getApplicationById(String id) async {
    final doc = await _firestore.collection(AppConstants.applicationsCollection).doc(id).get();
    if (doc.exists) {
      return ApplicationModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    await _firestore.collection(AppConstants.applicationsCollection).doc(id).update({
      'verificationStatus': status,
    });
  }

  Future<void> approveApplication(ApplicationModel app) async {
    final batch = _firestore.batch();
    
    // Update status in applications collection
    final appRef = _firestore.collection(AppConstants.applicationsCollection).doc(app.id);
    batch.update(appRef, {'verificationStatus': 'approved'});
    
    // Create doc in approved_providers
    final providerRef = _firestore.collection(AppConstants.providersCollection).doc(app.id);
    batch.set(providerRef, {
      'name': app.name,
      'phone': app.phone,
      'profileImage': app.profileImage,
      'category': app.category,
      'subcategory': app.subcategory,
      'categoryId': app.categoryId,
      'subcategoryId': app.subcategoryId,
      'verifiedAt': FieldValue.serverTimestamp(),
      if (app.latitude != null) 'latitude': app.latitude,
      if (app.longitude != null) 'longitude': app.longitude,
      if (app.serviceRate != null) 'serviceRate': app.serviceRate,
      if (app.rateDescription != null) 'rateDescription': app.rateDescription,
      'address': app.address,
      'city': app.city,
      'state': app.state,
      'pincode': app.pincode,
    });
    
    await batch.commit();
  }

  Future<void> rejectApplication(String id) async {
    await updateApplicationStatus(id, 'rejected');
  }

  Future<void> suspendApplication(String id) async {
    await updateApplicationStatus(id, 'suspended');
    
    // Remove from approved providers if suspended
    await _firestore.collection(AppConstants.providersCollection).doc(id).delete();
  }

  Future<void> deleteApplication(String id) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection(AppConstants.applicationsCollection).doc(id));
    batch.delete(_firestore.collection(AppConstants.providersCollection).doc(id));
    await batch.commit();
  }

  /// Returns counts for each application status.
  /// Errors propagate naturally so the dashboard can display them.
  Future<Map<String, int>> getApplicationCounts() async {
    final snapshot = await _firestore.collection(AppConstants.applicationsCollection).get();
    
    int total = snapshot.docs.length;
    int pending = 0;
    int approved = 0;
    int rejected = 0;
    
    for (var doc in snapshot.docs) {
      final status = doc.data()['verificationStatus'] as String?;
      if (status == 'pending') pending++;
      else if (status == 'approved') approved++;
      else if (status == 'rejected') rejected++;
    }
    
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
