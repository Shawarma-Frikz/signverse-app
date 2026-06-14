import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;
import '../../../core/services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _hexController;
  late AnimationController _textController;
  late AnimationController _glowController;

  late Animation<double> _hexScale;
  late Animation<double> _hexRotation;
  late Animation<double> _hexOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _hexController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Hex animations
    _hexScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _hexController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _hexRotation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _hexController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _hexOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _hexController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Glow pulse
    _glowPulse = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _hexController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check if onboarding has been completed before
    final onboardingDone = await PreferencesService.isOnboardingComplete();

    if (!mounted) return;

    if (onboardingDone) {
      context.go('/home'); // returning user — skip onboarding
    } else {
      context.go('/onboarding'); // first time — show onboarding
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF0F1535),
                  Color(0xFF0A0E27),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Ambient glow behind logo
          Center(
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (context, child) {
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent500.withOpacity(
                          _glowPulse.value * 0.15,
                        ),
                        blurRadius: 120,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hexagon logo mark
                AnimatedBuilder(
                  animation: _hexController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _hexOpacity.value,
                      child: Transform.scale(
                        scale: _hexScale.value,
                        child: Transform.rotate(
                          angle: _hexRotation.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildHexLogo(),
                ),

                const SizedBox(height: AppSpacing.s8),

                // Wordmark + tagline
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        // SignVerse wordmark
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Sign',
                                style: AppTextStyles.logoDisplay.copyWith(
                                  fontSize: 36,
                                  color: AppColors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'Verse',
                                style: AppTextStyles.logoDisplay.copyWith(
                                  fontSize: 36,
                                  color: AppColors.accent500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s2),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineOpacity,
                          child: Text(
                            'BRIDGING THE SILENCE',
                            style: AppTextStyles.tagline.copyWith(
                              letterSpacing: 4,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accent500.withOpacity(0.6),
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

  Widget _buildHexLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer hex ring
          CustomPaint(
            size: const Size(120, 120),
            painter: _HexPainter(
              color: AppColors.accent500.withOpacity(0.15),
              strokeColor: AppColors.accent500.withOpacity(0.4),
              strokeWidth: 1.5,
            ),
          ),

          // Inner hex filled
          CustomPaint(
            size: const Size(80, 80),
            painter: _HexPainter(
              color: AppColors.accent500.withOpacity(0.1),
              strokeColor: AppColors.accent500,
              strokeWidth: 2,
            ),
          ),

          // Hand emoji / icon
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (context, child) {
              return Text(
                '🤟',
                style: TextStyle(
                  fontSize: 36,
                  shadows: [
                    Shadow(
                      color: AppColors.accent500.withOpacity(_glowPulse.value),
                      blurRadius: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Hex painter ───────────────────────────────────────────────────
class _HexPainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  _HexPainter({
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = cx + r * 0.9 * math.cos(angle);
      final y = cy + r * 0.9 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_HexPainter old) => false;
}

double cos(double angle) => angle == 0 ? 1 : _cos(angle);
double sin(double angle) => _sin(angle);
double _cos(double x) {
  double result = 1;
  double term = 1;
  for (int i = 1; i <= 10; i++) {
    term *= -x * x / (2 * i * (2 * i - 1));
    result += term;
  }
  return result;
}

double _sin(double x) {
  double result = x;
  double term = x;
  for (int i = 1; i <= 10; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}
