import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_feature_model.dart';

class FeatureRepository {
  final FirebaseFirestore _firestore;

  FeatureRepository(this._firestore);

  Stream<List<AppFeatureModel>> getFeatures() {
    return _firestore
        .collection('features')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => AppFeatureModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> addFeature(AppFeatureModel feature) async {
    await _firestore.collection('features').add(feature.toFirestore());
  }

  Future<void> updateFeature(AppFeatureModel feature) async {
    await _firestore.collection('features').doc(feature.id).update(feature.toFirestore());
  }

  Future<void> deleteFeature(String id) async {
    await _firestore.collection('features').doc(id).delete();
  }
}
