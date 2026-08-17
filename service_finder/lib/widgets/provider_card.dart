import 'package:flutter/material.dart';
import '../utils/base64_image_helper.dart';
import 'verified_badge.dart';

class ProviderCard extends StatelessWidget {
  final String name;
  final String phone;
  final String profileImage;
  final String? address;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final VoidCallback? onPhoneTap;
  final double? distanceKm;
  final double? serviceRate;
  final String? rateDescription;

  const ProviderCard({
    super.key,
    required this.name,
    required this.phone,
    required this.profileImage,
    this.address,
    this.isUnlocked = false,
    this.onTap,
    this.onPhoneTap,
    this.distanceKm,
    this.serviceRate,
    this.rateDescription,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile photo
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profileImage.isNotEmpty 
                        ? Base64ImageHelper.getImageProvider(profileImage) 
                        : null,
                    child: profileImage.isEmpty 
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const VerifiedBadge(),
                      ],
                    ),
                  ),

                  // Call button or Lock badge
                  if (isUnlocked)
                    IconButton(
                      onPressed: onPhoneTap,
                      icon: const Icon(Icons.call),
                      color: Colors.green,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.12),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 14, color: Colors.amber.shade900),
                          const SizedBox(width: 4),
                          Text(
                            'Locked',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Service rate & Distance chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (serviceRate != null && serviceRate! > 0)
                    _buildChip(
                      icon: Icons.currency_rupee,
                      label: '₹${serviceRate!.toInt()} Charge',
                      color: colorScheme.primary,
                    ),
                  if (distanceKm != null)
                    _buildChip(
                      icon: Icons.location_on,
                      label: '${distanceKm!.toStringAsFixed(1)} km away',
                      color: Colors.teal,
                    ),
                ],
              ),

              if (rateDescription != null && rateDescription!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rateDescription!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // UNLOCKED VIEW: Phone & Address
              if (isUnlocked) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone
                      InkWell(
                        onTap: onPhoneTap,
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 18, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Tap to Call',
                              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (address != null && address!.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Divider(height: 1),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home, size: 18, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // LOCKED VIEW: Unlock Prompt Button
              if (!isUnlocked) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to Unlock Phone & Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
