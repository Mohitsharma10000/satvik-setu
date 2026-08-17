import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/animated_button.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _onGetStarted(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.easeOut),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ).animate().scale(delay: 200.ms, duration: 800.ms, curve: Curves.easeOut),
                  ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate().scale(delay: 400.ms, duration: 600.ms, curve: Curves.easeOutBack),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Find Verified Service Providers',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                'Connect with trusted professionals in your area for all your service needs.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
              const Spacer(),
              AnimatedButton(
                text: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _onGetStarted(context),
              ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
