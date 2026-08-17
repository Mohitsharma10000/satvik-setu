class AppConstants {
  // Firestore Collections
  static const String adminsCollection = 'admins';
  static const String categoriesCollection = 'categories';
  static const String subcategoriesCollection = 'subcategories';
  static const String applicationsCollection = 'applications';
  static const String providersCollection = 'approved_providers';
  static const String settingsCollection = 'settings';
  static const String usersCollection = 'users';
  static const String paymentsCollection = 'payments';
  static const String serviceRequestsCollection = 'service_requests';
  
  static const String donationSettingsDoc = 'donation';

  // Routes
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routeApplications = '/applications';
  static const String routeApplicationDetail = '/applications/:id';
  static const String routeCategories = '/categories';
  static const String routeSubcategories = '/subcategories';
  static const String routeDonationSettings = '/donation-settings';
  static const String routePayments = '/payments';
  static const String routeServiceRequests = '/service-requests';
  static const String routeUsers = '/users';
  static const String routeAnalytics = '/analytics';
  static const String routePaymentSettings = '/payment-settings';
  static const String routeFeatures = '/features';
  static const String routeCustomBuilder = '/custom-builder';
}
