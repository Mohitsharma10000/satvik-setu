import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'donation_providers.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/error_state.dart';

class DonationScreen extends ConsumerWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationSettingsAsync = ref.watch(donationSettingsProvider);
    final urlLauncher = UrlLauncherService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Us'),
      ),
      body: donationSettingsAsync.when(
        data: (settings) {
          if (settings == null) {
            return const Center(child: Text('Donation info not available.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.volunteer_activism, size: 80, color: Colors.redAccent),
                const SizedBox(height: 24),
                Text(
                  'Support Our Platform',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  settings.donationMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (settings.qrCodeUrl.isNotEmpty) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CachedNetworkImage(
                        imageUrl: settings.qrCodeUrl,
                        width: 200,
                        height: 200,
                        placeholder: (context, url) => const SizedBox(
                          width: 200, height: 200, 
                          child: Center(child: CircularProgressIndicator())
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          width: 200, height: 200,
                          child: Icon(Icons.error)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'UPI ID: ${settings.upiId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          await urlLauncher.copyToClipboard(settings.upiId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UPI ID copied to clipboard')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => urlLauncher.shareText('Support Service Finder by donating to ${settings.upiId}'),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AnimatedButton(
                  text: "I've Donated",
                  icon: Icons.favorite,
                  gradientColors: const [Colors.redAccent, Colors.pink],
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Thank You!'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 64),
                            SizedBox(height: 16),
                            Text('Your support helps us keep the platform running and free for everyone.', textAlign: TextAlign.center),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(donationSettingsProvider),
        ),
      ),
    );
  }
}
