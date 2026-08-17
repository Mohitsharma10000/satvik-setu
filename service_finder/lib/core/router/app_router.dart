import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/categories/subcategory_screen.dart';
import '../../features/providers/provider_list_screen.dart';
import '../../features/registration/registration_screen.dart';
import '../../features/donation/donation_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/payment/payment_gate_screen.dart';
import '../../features/requests/my_requests_screen.dart';
import '../../features/provider_dashboard/provider_login_screen.dart';
import '../../features/provider_dashboard/provider_dashboard_screen.dart';
import '../../features/provider_dashboard/completion_proof_screen.dart';
import '../../features/custom_features/dynamic_form_screen.dart';
import '../../models/dynamic_feature_model.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/category/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final categoryName = extra?['categoryName'] ?? 'Subcategories';
        return SubcategoryScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    ),
    GoRoute(
      path: '/category/:categoryId/subcategory/:subcategoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        final subcategoryId = state.pathParameters['subcategoryId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final subcategoryName = extra?['subcategoryName'] ?? 'Providers';
        return ProviderListScreen(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          subcategoryName: subcategoryName,
        );
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/donation',
      builder: (context, state) => const DonationScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/payment-gate',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentGateScreen(
          categoryId: extra['categoryId'] ?? '',
          subcategoryId: extra['subcategoryId'] ?? '',
          categoryName: extra['categoryName'] ?? 'Service',
          subcategoryName: extra['subcategoryName'] ?? 'Service Detail',
        );
      },
    ),
    GoRoute(
      path: '/my-requests',
      builder: (context, state) => const MyRequestsScreen(),
    ),
    GoRoute(
      path: '/provider-login',
      builder: (context, state) => const ProviderLoginScreen(),
    ),
    GoRoute(
      path: '/provider-dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: '/completion-proof/:requestId',
      builder: (context, state) {
        final requestId = state.pathParameters['requestId']!;
        return CompletionProofScreen(requestId: requestId);
      },
    ),
    GoRoute(
      path: '/dynamic-feature/:featureId',
      builder: (context, state) {
        final featureId = state.pathParameters['featureId']!;
        final model = state.extra as DynamicFeatureModel?;
        return DynamicFormScreen(
          featureId: featureId,
          featureModel: model,
        );
      },
    ),
  ],
);
