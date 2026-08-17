class AppConstants {
  AppConstants._();

  static const String appName = 'SATVIKSETU';
  
  // Firestore Collections
  static const String categoriesCollection = 'categories';
  static const String subcategoriesCollection = 'subcategories';
  static const String approvedProvidersCollection = 'approved_providers';
  static const String applicationsCollection = 'applications';
  static const String donationSettingsDoc = 'donation/settings';
  static const String usersCollection = 'users';
  static const String paymentsCollection = 'payments';
  static const String serviceRequestsCollection = 'service_requests';
  
  // Fee Constants
  static const double defaultAdvanceFee = 10.0;
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String aadhaarImagesPath = 'aadhaar_images';
}
