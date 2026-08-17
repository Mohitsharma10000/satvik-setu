import '../../models/application_model.dart';

class MockApplicationRepository {
  final List<ApplicationModel> _mockApps = [
    ApplicationModel(
      id: 'app_1',
      name: 'Rahul Sharma',
      phone: '9876543210',
      email: 'rahul.sharma@example.com',
      gender: 'Male',
      dob: '14/05/1992',
      address: '123 MG Road, Sector 14',
      state: 'Maharashtra',
      city: 'Mumbai',
      pincode: '400001',
      category: 'Electrician',
      subcategory: 'House Wiring',
      categoryId: 'cat_1',
      subcategoryId: 'sub_1',
      experience: '5 years',
      description: 'Expert electrician with 5+ years experience in house wiring and MCB repair.',
      profileImage: '',
      aadhaarFront: '',
      aadhaarBack: '',
      verificationStatus: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ApplicationModel(
      id: 'app_2',
      name: 'Priya Verma',
      phone: '9812345678',
      email: 'priya.v@example.com',
      gender: 'Female',
      dob: '22/08/1995',
      address: '45 Park Street',
      state: 'Karnataka',
      city: 'Bangalore',
      pincode: '560001',
      category: 'Plumber',
      subcategory: 'Tap Repair',
      categoryId: 'cat_2',
      subcategoryId: 'sub_2',
      experience: '4 years',
      description: 'Professional plumber specializing in pipe fitting and bathroom fixtures.',
      profileImage: '',
      aadhaarFront: '',
      aadhaarBack: '',
      verificationStatus: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    ApplicationModel(
      id: 'app_3',
      name: 'Amit Patel',
      phone: '9765432109',
      email: 'amit.patel@example.com',
      gender: 'Male',
      dob: '30/11/1988',
      address: '78 Station Road',
      state: 'Gujarat',
      city: 'Ahmedabad',
      pincode: '380001',
      category: 'Mechanic',
      subcategory: 'Car Repair',
      categoryId: 'cat_3',
      subcategoryId: 'sub_3',
      experience: '8 years',
      description: 'Automobile mechanic with expertise in engine repair and battery service.',
      profileImage: '',
      aadhaarFront: '',
      aadhaarBack: '',
      verificationStatus: 'approved',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Stream<List<ApplicationModel>> getApplications({String? status}) async* {
    if (status == null || status == 'all') {
      yield _mockApps;
    } else {
      yield _mockApps.where((a) => a.verificationStatus == status).toList();
    }
  }

  Future<ApplicationModel?> getApplicationById(String id) async {
    try {
      return _mockApps.firstWhere((a) => a.id == id);
    } catch (_) {
      return _mockApps.isNotEmpty ? _mockApps.first : null;
    }
  }

  Future<void> approveApplication(ApplicationModel app) async {
    // Mock approval — in real app this writes to Firestore
  }

  Future<void> rejectApplication(String id) async {
    // Mock rejection
  }

  Future<void> deleteApplication(String id) async {
    _mockApps.removeWhere((a) => a.id == id);
  }

  Future<Map<String, int>> getApplicationCounts() async {
    final total = _mockApps.length;
    final pending = _mockApps.where((a) => a.verificationStatus == 'pending').length;
    final approved = _mockApps.where((a) => a.verificationStatus == 'approved').length;
    final rejected = _mockApps.where((a) => a.verificationStatus == 'rejected').length;
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
