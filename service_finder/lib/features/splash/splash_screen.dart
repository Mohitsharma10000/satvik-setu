import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (hasSeenOnboarding) {
        context.go('/home');
      } else {
        context.go('/welcome');
      }
    } catch (_) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Deep navy
              Color(0xFF0D47A1), // Royal blue
              Color(0xFF1565C0), // Medium blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing ring behind logo
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(
                            alpha: 0.3 + (_pulseController.value * 0.3),
                          ),
                          blurRadius: 30 + (_pulseController.value * 20),
                          spreadRadius: 5 + (_pulseController.value * 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(
                            alpha: 0.1 + (_pulseController.value * 0.1),
                          ),
                          blurRadius: 50,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 40),

              // App Name "SevaConnect"
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  fontSize: 36,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 12),

              // Tagline
              Text(
                'सेवा ही हमारा धर्म',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange.shade200,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Verified Local Service Providers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.0,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.orange.shade300,
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),

              const SizedBox(height: 16),

              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(delay: 1400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
