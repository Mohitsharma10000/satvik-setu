import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'provider_providers.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/verified_badge.dart';
import '../../utils/base64_image_helper.dart';
import '../../services/url_launcher_service.dart';
import '../../services/location_service.dart';
import '../../services/guest_id_service.dart';
import '../../repositories/payment_repository.dart';
import '../../models/provider_model.dart';

class ProviderListScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String subcategoryId;
  final String subcategoryName;

  const ProviderListScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  ConsumerState<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends ConsumerState<ProviderListScreen> {
  bool _isGettingLocation = false;
  bool _isUnlocked = false;
  bool _isCheckingPayment = true;

  @override
  void initState() {
    super.initState();
    _checkCategoryPaymentPass();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(userLocationProvider) == null) {
        _requestUserLocation();
      }
    });
  }

  /// Check if current device/guest has an active 24-hour pass for this category
  Future<void> _checkCategoryPaymentPass() async {
    setState(() => _isCheckingPayment = true);
    try {
      final guestId = await GuestIdService.getGuestId();
      final paymentRepo = PaymentRepository();
      final hasPass = await paymentRepo.hasValidPayment(guestId, widget.categoryId);
      if (mounted) {
        setState(() {
          _isUnlocked = hasPass;
          _isCheckingPayment = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCheckingPayment = false);
    }
  }

  Future<void> _requestUserLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      ref.read(userLocationProvider.notifier).state = position;
    } catch (_) {
      // Permission denied or GPS off
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _onProviderTap(ProviderModel provider) {
    if (_isUnlocked) {
      _showUnlockedProviderDetails(provider);
    } else {
      _navigateToPaymentGate();
    }
  }

  void _navigateToPaymentGate() {
    context.push(
      '/payment-gate',
      extra: {
        'categoryId': widget.categoryId,
        'subcategoryId': widget.subcategoryId,
        'categoryName': providerCategoryName(widget.categoryId),
        'subcategoryName': widget.subcategoryName,
      },
    );
  }

  String providerCategoryName(String catId) {
    return widget.subcategoryName;
  }

  void _showUnlockedProviderDetails(ProviderModel provider) {
    final urlLauncher = UrlLauncherService();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: provider.profileImage.isNotEmpty
                        ? Base64ImageHelper.getImageProvider(provider.profileImage)
                        : null,
                    child: provider.profileImage.isEmpty
                        ? const Icon(Icons.person, size: 36, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const VerifiedBadge(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Rate
              if (provider.serviceRate != null) ...[
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service Rate: ₹${provider.serviceRate!.toInt()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (provider.rateDescription != null && provider.rateDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 4),
                    child: Text(
                      provider.rateDescription!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // Phone Number
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    provider.phone,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          provider.fullAddress,
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Call Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => urlLauncher.makePhoneCall(provider.phone),
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text('Call Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final queryParam = ProviderQueryParam(
      categoryId: widget.categoryId,
      subcategoryId: widget.subcategoryId,
    );
    final providersAsync = ref.watch(providersProvider(queryParam));
    final userLocation = ref.watch(userLocationProvider);
    final selectedRadius = ref.watch(radiusFilterProvider);
    final urlLauncher = UrlLauncherService();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subcategoryName),
        actions: [
          PopupMenuButton<double>(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter Radius',
            initialValue: selectedRadius,
            onSelected: (radius) {
              ref.read(radiusFilterProvider.notifier).state = radius;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 5.0, child: Text('5 km radius')),
              const PopupMenuItem(value: 7.0, child: Text('7 km radius (Default)')),
              const PopupMenuItem(value: 10.0, child: Text('10 km radius')),
              const PopupMenuItem(value: 15.0, child: Text('15 km radius')),
              const PopupMenuItem(value: 0.0, child: Text('All distances')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Access Pass Banner / Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: _isUnlocked ? Colors.green.shade50 : Colors.amber.shade50,
            child: Row(
              children: [
                Icon(
                  _isUnlocked ? Icons.verified : Icons.lock,
                  size: 18,
                  color: _isUnlocked ? Colors.green.shade800 : Colors.amber.shade900,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isUnlocked
                        ? '🎉 24-Hour Access Active! Phone numbers & addresses unlocked.'
                        : '🔒 Phone numbers & addresses locked. Tap any card to unlock.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isUnlocked ? Colors.green.shade900 : Colors.amber.shade900,
                    ),
                  ),
                ),
                if (!_isUnlocked)
                  TextButton(
                    onPressed: _navigateToPaymentGate,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      'Unlock Access',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Provider List View
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _checkCategoryPaymentPass();
                ref.refresh(providersProvider(queryParam));
              },
              child: providersAsync.when(
                data: (providers) {
                  if (providers.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: EmptyState(
                          icon: Icons.person_off,
                          title: 'No Nearby Providers Found',
                          subtitle: userLocation != null
                              ? 'No verified providers within ${selectedRadius.toInt()} km. Try increasing radius.'
                              : 'There are no verified providers in this category yet.',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      return ProviderCard(
                        name: provider.name,
                        phone: provider.phone,
                        profileImage: provider.profileImage,
                        address: provider.fullAddress,
                        isUnlocked: _isUnlocked,
                        onTap: () => _onProviderTap(provider),
                        onPhoneTap: () {
                          if (_isUnlocked) {
                            urlLauncher.makePhoneCall(provider.phone);
                          } else {
                            _navigateToPaymentGate();
                          }
                        },
                        distanceKm: provider.distanceKm,
                        serviceRate: provider.serviceRate,
                        rateDescription: provider.rateDescription,
                      );
                    },
                  );
                },
                loading: () => const ProviderSkeletonLoader(),
                error: (err, stack) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ErrorState(
                      message: err.toString(),
                      onRetry: () => ref.refresh(providersProvider(queryParam)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
