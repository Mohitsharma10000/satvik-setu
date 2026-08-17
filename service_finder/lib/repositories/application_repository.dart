import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/application_model.dart';
import '../core/constants/app_constants.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore;

  ApplicationRepository(this._firestore);

  Future<void> submitApplication(ApplicationModel application) async {
    await _firestore
        .collection(AppConstants.applicationsCollection)
        .add(application.toFirestore());
  }
}
