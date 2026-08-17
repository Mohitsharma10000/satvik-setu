import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/applications/applications_page.dart';
import '../../features/applications/application_detail_page.dart';
import '../../features/categories/categories_page.dart';
import '../../features/subcategories/subcategories_page.dart';
import '../../features/donation/donation_settings_page.dart';
import '../../features/payments/payments_page.dart';
import '../../features/requests/requests_management_page.dart';
import '../../features/users/users_management_page.dart';
import '../../features/analytics/analytics_page.dart';
import '../../features/settings/payment_settings_page.dart';
import '../../features/features_mgmt/features_management_page.dart';
import '../../features/custom_builder/custom_builder_page.dart';

const bool kDemoMode = false;

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppConstants.routeDashboard,
    redirect: (context, state) {
      if (kDemoMode) return null;

      if (authState.isLoading) return null;
      
      final isAuth = authState.value != null;
      final isLoggingIn = state.uri.path == AppConstants.routeLogin;

      if (!isAuth && !isLoggingIn) return AppConstants.routeLogin;
      if (isAuth && isLoggingIn) return AppConstants.routeDashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeDashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppConstants.routeApplications,
        builder: (context, state) => const ApplicationsPage(),
      ),
      GoRoute(
        path: AppConstants.routeApplicationDetail,
        builder: (context, state) => ApplicationDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppConstants.routeCategories,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: AppConstants.routeSubcategories,
        builder: (context, state) => const SubcategoriesPage(),
      ),
      GoRoute(
        path: AppConstants.routeDonationSettings,
        builder: (context, state) => const DonationSettingsPage(),
      ),
      GoRoute(
        path: AppConstants.routePayments,
        builder: (context, state) => const PaymentsPage(),
      ),
      GoRoute(
        path: AppConstants.routeServiceRequests,
        builder: (context, state) => const RequestsManagementPage(),
      ),
      GoRoute(
        path: AppConstants.routeUsers,
        builder: (context, state) => const UsersManagementPage(),
      ),
      GoRoute(
        path: AppConstants.routeAnalytics,
        builder: (context, state) => const AnalyticsPage(),
      ),
      GoRoute(
        path: AppConstants.routePaymentSettings,
        builder: (context, state) => const PaymentSettingsPage(),
      ),
      GoRoute(
        path: AppConstants.routeFeatures,
        builder: (context, state) => const FeaturesManagementPage(),
      ),
      GoRoute(
        path: AppConstants.routeCustomBuilder,
        builder: (context, state) => const CustomBuilderPage(),
      ),
    ],
  );
});
