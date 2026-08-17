import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/auth_providers.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    
    int getSelectedIndex() {
      if (location.startsWith(AppConstants.routeDashboard)) return 0;
      if (location.startsWith(AppConstants.routeApplications)) return 1;
      if (location.startsWith(AppConstants.routeServiceRequests)) return 2;
      if (location.startsWith(AppConstants.routePayments)) return 3;
      if (location.startsWith(AppConstants.routeUsers)) return 4;
      if (location.startsWith(AppConstants.routeCategories)) return 5;
      if (location.startsWith(AppConstants.routeSubcategories)) return 6;
      if (location.startsWith(AppConstants.routeDonationSettings)) return 7;
      if (location.startsWith(AppConstants.routeAnalytics)) return 8;
      if (location.startsWith(AppConstants.routePaymentSettings)) return 9;
      if (location.startsWith(AppConstants.routeFeatures)) return 10;
      if (location.startsWith(AppConstants.routeCustomBuilder)) return 11;
      return 0;
    }

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          context.go(AppConstants.routeDashboard);
          break;
        case 1:
          context.go(AppConstants.routeApplications);
          break;
        case 2:
          context.go(AppConstants.routeServiceRequests);
          break;
        case 3:
          context.go(AppConstants.routePayments);
          break;
        case 4:
          context.go(AppConstants.routeUsers);
          break;
        case 5:
          context.go(AppConstants.routeCategories);
          break;
        case 6:
          context.go(AppConstants.routeSubcategories);
          break;
        case 7:
          context.go(AppConstants.routeDonationSettings);
          break;
        case 8:
          context.go(AppConstants.routeAnalytics);
          break;
        case 9:
          context.go(AppConstants.routePaymentSettings);
          break;
        case 10:
          context.go(AppConstants.routeFeatures);
          break;
        case 11:
          context.go(AppConstants.routeCustomBuilder);
          break;
      }
    }

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final destinations = const [
      NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
      NavigationRailDestination(icon: Icon(Icons.assignment), label: Text('Applications')),
      NavigationRailDestination(icon: Icon(Icons.home_repair_service), label: Text('Service Requests')),
      NavigationRailDestination(icon: Icon(Icons.payments), label: Text('Payments')),
      NavigationRailDestination(icon: Icon(Icons.people), label: Text('Users')),
      NavigationRailDestination(icon: Icon(Icons.category), label: Text('Categories')),
      NavigationRailDestination(icon: Icon(Icons.account_tree), label: Text('Subcategories')),
      NavigationRailDestination(icon: Icon(Icons.monetization_on), label: Text('Donations')),
      NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Analytics')),
      NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Payment Settings')),
      NavigationRailDestination(icon: Icon(Icons.auto_awesome), label: Text('Dynamic Features')),
      NavigationRailDestination(icon: Icon(Icons.build_circle), label: Text('Custom Builder')),
    ];

    return Scaffold(
      appBar: !isDesktop ? AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/app_logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('SATVIKSETU Admin'),
          ],
        ),
      ) : null,
      drawer: !isDesktop
          ? Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF1A237E)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/app_logo.png', height: 48),
                        const SizedBox(height: 8),
                        const Text('SATVIKSETU Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ...destinations.asMap().entries.map((e) => ListTile(
                        leading: e.value.icon,
                        title: e.value.label,
                        selected: getSelectedIndex() == e.key,
                        onTap: () {
                          Navigator.pop(context);
                          onDestinationSelected(e.key);
                        },
                      )),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      ref.read(authNotifierProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              extended: true,
              backgroundColor: Colors.white,
              selectedIndex: getSelectedIndex(),
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
              leading: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset('assets/images/app_logo.png', height: 40),
                    const SizedBox(width: 8),
                    const Text('SATVIKSETU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).logout();
                      },
                    ),
                  ),
                ),
              ),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
