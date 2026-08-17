import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_shell.dart';
import 'donation_providers.dart';
import '../../models/donation_settings_model.dart';

class DonationSettingsPage extends ConsumerStatefulWidget {
  const DonationSettingsPage({super.key});

  @override
  ConsumerState<DonationSettingsPage> createState() => _DonationSettingsPageState();
}

class _DonationSettingsPageState extends ConsumerState<DonationSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _upiIdController = TextEditingController();
  final _messageController = TextEditingController();
  String _qrCodeUrl = '';
  bool _isDonationVisible = true;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _upiIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(donationRepositoryProvider);
        await repo.updateDonationSettings(DonationSettingsModel(
          qrCodeUrl: _qrCodeUrl,
          upiId: _upiIdController.text.trim(),
          donationMessage: _messageController.text.trim(),
          isDonationVisible: _isDonationVisible,
        ));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Settings saved! Donation button is now ${_isDonationVisible ? "VISIBLE" : "HIDDEN"} in User App.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(donationSettingsStreamProvider);

    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Donation Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () {
                    _initialized = false;
                    ref.invalidate(donationSettingsStreamProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: settingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) {
                  final errorMsg = err.toString();
                  final isPermission = errorMsg.contains('permission-denied') || errorMsg.contains('PERMISSION_DENIED');

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPermission ? Icons.lock_outline : Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isPermission ? 'Permission Denied' : 'Error Loading Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              isPermission
                                  ? 'Cannot access donation settings.\n\n'
                                    'Make sure your Firestore rules are published in Firebase Console.'
                                  : 'Error: $errorMsg',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            onPressed: () {
                              _initialized = false;
                              ref.invalidate(donationSettingsStreamProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                data: (settings) {
                  if (!_initialized && settings != null) {
                    _upiIdController.text = settings.upiId;
                    _messageController.text = settings.donationMessage;
                    _qrCodeUrl = settings.qrCodeUrl;
                    _isDonationVisible = settings.isDonationVisible;
                    _initialized = true;
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (settings == null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'No donation settings exist yet. Fill in the form below and save to create them.',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // VISIBILITY TOGGLE SWITCH FOR USER APP
                              Container(
                                decoration: BoxDecoration(
                                  color: _isDonationVisible ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isDonationVisible ? Colors.green.shade300 : Colors.red.shade300,
                                  ),
                                ),
                                child: SwitchListTile(
                                  title: Text(
                                    'Show "Support Us / Donation" Button in User App',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isDonationVisible ? Colors.green.shade900 : Colors.red.shade900,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _isDonationVisible
                                        ? 'Button is VISIBLE in User App home screen.'
                                        : 'Button is HIDDEN (Invisible) in User App home screen.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isDonationVisible ? Colors.green.shade800 : Colors.red.shade800,
                                    ),
                                  ),
                                  value: _isDonationVisible,
                                  activeColor: Colors.green,
                                  onChanged: (val) {
                                    setState(() => _isDonationVisible = val);
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              const Text('QR Code Image', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (_qrCodeUrl.isNotEmpty)
                                Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                  child: Image.network(_qrCodeUrl, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48)),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.upload),
                                label: const Text('Upload New QR Code'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('File picker preview: Enter image URL directly if needed.'),
                                  ));
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _upiIdController,
                                decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder()),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 4,
                                decoration: const InputDecoration(labelText: 'Donation Message', border: OutlineInputBorder()),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: 200,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveSettings,
                                  child: _isLoading ? const CircularProgressIndicator() : const Text('Save Settings'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
