import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_shell.dart';

// Provider for payment config stream
final paymentConfigStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('payment_config')
      .snapshots()
      .map((snap) => snap.data());
});

class PaymentSettingsPage extends ConsumerStatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  ConsumerState<PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends ConsumerState<PaymentSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _feeController = TextEditingController();
  final _validityHoursController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _feeController.dispose();
    _validityHoursController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fee = double.parse(_feeController.text.trim());
      final hours = int.parse(_validityHoursController.text.trim());

      await FirebaseFirestore.instance
          .collection('settings')
          .doc('payment_config')
          .set({
        'advanceFee': fee,
        'validityHours': hours,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(paymentConfigStreamProvider);

    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Payment Settings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () {
                    _initialized = false;
                    ref.invalidate(paymentConfigStreamProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set the advance payment amount that users pay to access category providers.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: configAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Error: $err', style: TextStyle(color: Colors.red.shade700)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () {
                          _initialized = false;
                          ref.invalidate(paymentConfigStreamProvider);
                        },
                      ),
                    ],
                  ),
                ),
                data: (config) {
                  if (!_initialized) {
                    final currentFee = config?['advanceFee']?.toString() ?? '10';
                    final currentHours = config?['validityHours']?.toString() ?? '24';
                    _feeController.text = currentFee;
                    _validityHoursController.text = currentHours;
                    _initialized = true;
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Config Info
                        if (config != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Current: ₹${config['advanceFee'] ?? 10} for ${config['validityHours'] ?? 24} hours access',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (config == null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'No payment config found. Default ₹10 / 24 hours is being used. Save to create config.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Settings Form
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Advance Fee Configuration',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),

                                  // Fee Amount
                                  TextFormField(
                                    controller: _feeController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Advance Fee Amount (₹)',
                                      hintText: 'e.g. 10',
                                      prefixIcon: const Icon(Icons.currency_rupee),
                                      border: const OutlineInputBorder(),
                                      helperText: 'Users pay this amount to access providers in a category.',
                                      helperMaxLines: 2,
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final num = double.tryParse(v);
                                      if (num == null || num <= 0) return 'Enter a valid amount greater than 0';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Validity Hours
                                  TextFormField(
                                    controller: _validityHoursController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Access Validity (Hours)',
                                      hintText: 'e.g. 24',
                                      prefixIcon: const Icon(Icons.access_time),
                                      border: const OutlineInputBorder(),
                                      helperText: 'How many hours the pass remains valid after payment.',
                                      helperMaxLines: 2,
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final num = int.tryParse(v);
                                      if (num == null || num <= 0) return 'Enter valid hours (e.g. 24)';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),

                                  // Preview Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.indigo.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.preview, color: Colors.indigo.shade700),
                                            const SizedBox(width: 8),
                                            Text(
                                              'User App Preview',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Users will see: "₹${_feeController.text.isNotEmpty ? _feeController.text : '10'} '
                                          'gives you a ${_validityHoursController.text.isNotEmpty ? _validityHoursController.text : '24'}-Hour Pass '
                                          'to view all verified service providers in this category."',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.indigo.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  SizedBox(
                                    width: 220,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Icon(Icons.save),
                                      label: Text(_isLoading ? 'Saving...' : 'Save Settings'),
                                      onPressed: _isLoading ? null : _saveSettings,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
