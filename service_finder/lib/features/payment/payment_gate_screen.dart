import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/payment_service.dart';
import '../../services/guest_id_service.dart';
import '../../repositories/payment_repository.dart';
import '../../models/payment_model.dart';

// Provider to fetch category-specific fee & global validity hours
final categoryPaymentConfigProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, categoryId) async {
  double advanceFee = 10.0;
  int validityHours = 24;

  // 1. Fetch category specific advanceFee from categories/{categoryId}
  if (categoryId.isNotEmpty) {
    try {
      final catDoc = await FirebaseFirestore.instance.collection('categories').doc(categoryId).get();
      if (catDoc.exists && catDoc.data() != null) {
        final fee = (catDoc.data()!['advanceFee'] as num?)?.toDouble();
        if (fee != null && fee > 0) {
          advanceFee = fee;
        }
      }
    } catch (_) {}
  }

  // 2. Fetch validityHours from settings/payment_config
  try {
    final settingsDoc = await FirebaseFirestore.instance.collection('settings').doc('payment_config').get();
    if (settingsDoc.exists && settingsDoc.data() != null) {
      final hours = (settingsDoc.data()!['validityHours'] as num?)?.toInt();
      if (hours != null && hours > 0) {
        validityHours = hours;
      }
    }
  } catch (_) {}

  return {'advanceFee': advanceFee, 'validityHours': validityHours};
});

class PaymentGateScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String subcategoryId;
  final String categoryName;
  final String subcategoryName;

  const PaymentGateScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.categoryName,
    required this.subcategoryName,
  });

  @override
  ConsumerState<PaymentGateScreen> createState() => _PaymentGateScreenState();
}

class _PaymentGateScreenState extends ConsumerState<PaymentGateScreen> {
  bool _isLoading = false;

  Future<void> _processPayment(double accessFee, int validityHours) async {
    setState(() {
      _isLoading = true;
    });

    final guestId = await GuestIdService.getGuestId();
    final paymentService = ref.read(paymentServiceProvider);
    
    paymentService.openCheckout(
      amount: accessFee,
      description: '$validityHours-Hour Access Pass for ${widget.categoryName}',
      onSuccess: (response) async {
        try {
          final paymentRepository = PaymentRepository();
          
          final payment = PaymentModel(
            userId: guestId,
            userPhone: '',
            amount: accessFee,
            paymentStatus: 'successful',
            categoryId: widget.categoryId,
            subcategoryId: widget.subcategoryId,
            category: widget.categoryName,
            subcategory: widget.subcategoryName,
            razorpayOrderId: response['orderId'],
            razorpayPaymentId: response['paymentId'],
            razorpaySignature: response['signature'],
            createdAt: DateTime.now(),
          );
          
          await paymentRepository.createPayment(payment);
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showSuccess('Payment Successful! $validityHours-hour access activated.');
            context.go('/category/${widget.categoryId}/subcategory/${widget.subcategoryId}');
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showError('Failed to save payment record: $e');
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showError(error);
        }
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configAsync = ref.watch(categoryPaymentConfigProvider(widget.categoryId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Service Providers'),
        centerTitle: true,
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildPaymentBody(theme, 10.0, 24),
        data: (config) {
          final fee = (config['advanceFee'] as num?)?.toDouble() ?? 10.0;
          final hours = (config['validityHours'] as num?)?.toInt() ?? 24;
          return _buildPaymentBody(theme, fee, hours);
        },
      ),
    );
  }

  Widget _buildPaymentBody(ThemeData theme, double accessFee, int validityHours) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_open_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unlock Category Access',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.categoryName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₹${accessFee.toStringAsFixed(0)}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid for $validityHours Hours',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Notice Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.tertiary,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pay ₹${accessFee.toStringAsFixed(0)} to unlock phone numbers and addresses of all verified providers in ${widget.categoryName} for $validityHours hours.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // What you get
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'What you get:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureRow(Icons.phone_in_talk, 'Unlock direct phone numbers', theme),
                          const SizedBox(height: 8),
                          _buildFeatureRow(Icons.location_on, 'View full addresses & areas', theme),
                          const SizedBox(height: 8),
                          _buildFeatureRow(Icons.timer, '$validityHours-hour unlimited access', theme),
                          const SizedBox(height: 8),
                          _buildFeatureRow(Icons.category, 'Applies to all ${widget.categoryName} subcategories', theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            FilledButton.icon(
              onPressed: _isLoading ? null : () => _processPayment(accessFee, validityHours),
              icon: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ) 
                  : const Icon(Icons.payment_rounded),
              label: Text(
                _isLoading ? 'Processing...' : 'Pay ₹${accessFee.toStringAsFixed(0)} & Unlock Details',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '100% Secure Payments via Razorpay',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
