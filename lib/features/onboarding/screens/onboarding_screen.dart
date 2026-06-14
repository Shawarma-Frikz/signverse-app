import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      emoji: '🤟',
      title: 'Real-Time ASL\nTranslation',
      subtitle:
          'Point your camera at any ASL sign and watch it transform into text and speech instantly. No delay, no guesswork.',
      accentColor: Color(0xFF00BCD4),
      features: [
        '26 ASL alphabet letters',
        'Instant recognition',
        'Text & speech output',
      ],
    ),
    _OnboardingPage(
      emoji: '📚',
      title: 'Learn at\nYour Pace',
      subtitle:
          'Browse our complete ASL sign library organized by category. Practice each sign with real-time feedback.',
      accentColor: Color(0xFF009688),
      features: ['2,000+ ASL words', 'Category browsing', 'Practice mode'],
    ),
    _OnboardingPage(
      emoji: '📜',
      title: 'Every Word\nRemembered',
      subtitle:
          'Your translation history is saved automatically. Review, share, and build on past conversations.',
      accentColor: Color(0xFF26C6DA),
      features: [
        'Auto-saved history',
        'Search past sessions',
        'Export & share',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  void _skip() => context.go('/home');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0E27), Color(0xFF0F1535)],
              ),
            ),
          ),

          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPageView(page: _pages[index], size: size);
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.s4,
            right: AppSpacing.s6,
            child: _currentPage < _pages.length - 1
                ? TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary200,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLast = _currentPage == _pages.length - 1;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.s6,
        right: AppSpacing.s6,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.s8,
        top: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withOpacity(0), AppColors.background],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.accent500,
              dotColor: AppColors.primary400,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 4,
              spacing: 6,
            ),
          ),

          const SizedBox(height: AppSpacing.s6),

          // Next / Get Started button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: AppRadius.lgBorder,
                boxShadow: AppShadows.glowCyan,
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Get Started' : 'Next',
                      style: AppTextStyles.buttonLabel.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Icon(
                      isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single onboarding page data ───────────────────────────────────
class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<String> features;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.features,
  });
}

// ── Single onboarding page UI ─────────────────────────────────────
class _OnboardingPageView extends StatefulWidget {
  final _OnboardingPage page;
  final Size size;

  const _OnboardingPageView({required this.page, required this.size});

  @override
  State<_OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<_OnboardingPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _emojiScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _emojiScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),

          // Big emoji illustration
          ScaleTransition(
            scale: _emojiScale,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.page.accentColor.withOpacity(0.15),
                    widget.page.accentColor.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  color: widget.page.accentColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.page.accentColor.withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.page.emoji,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s10),

          // Title
          FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Text(
                widget.page.title,
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 30,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s4),

          // Subtitle
          FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Text(
                widget.page.subtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s8),

          // Feature chips
          FadeTransition(
            opacity: _fadeIn,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: widget.page.features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.page.accentColor.withOpacity(0.1),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: widget.page.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: widget.page.accentColor,
                      ),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        feature,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: widget.page.accentColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 180),
        ],
      ),
    );
  }
}
