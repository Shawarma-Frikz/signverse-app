import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/greeting_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final name = user?.displayName ?? user?.email.split('@').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary500.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s6,
                      0,
                    ),
                    child: GreetingHeader(
                      name: name,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                  ),
                ),

                // ── Hero translate card ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s6,
                      0,
                    ),
                    child: _HeroCard()
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.1),
                  ),
                ),

                // ── Stats row ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s5,
                      AppSpacing.s6,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: const StatCard(
                            icon: Icons.translate_rounded,
                            label: 'Translations',
                            value: '0',
                            color: AppColors.accent500,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        ),
                        const SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: const StatCard(
                            icon: Icons.school_rounded,
                            label: 'Signs learned',
                            value: '0',
                            color: AppColors.secondary500,
                          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                        ),
                        const SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: const StatCard(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Day streak',
                            value: '1',
                            color: Color(0xFFFF6B35),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Quick actions ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s6,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: AppTextStyles.headlineMedium,
                        ).animate().fadeIn(delay: 350.ms),
                        const SizedBox(height: AppSpacing.s3),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  QuickActionCard(
                                        icon: Icons.sign_language_rounded,
                                        label: 'Translate',
                                        subtitle: 'ASL → Text',
                                        gradient: AppGradients.accent,
                                        onTap: () => context.go('/translate'),
                                      )
                                      .animate()
                                      .fadeIn(delay: 400.ms)
                                      .slideX(begin: -0.1),
                            ),
                            const SizedBox(width: AppSpacing.s3),
                            Expanded(
                              child:
                                  QuickActionCard(
                                        icon: Icons.abc_rounded,
                                        label: 'Alphabet',
                                        subtitle: 'A to Z',
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF7B2FF7),
                                            Color(0xFF4A90E2),
                                          ],
                                        ),
                                        onTap: () => context.go('/learn'),
                                      )
                                      .animate()
                                      .fadeIn(delay: 450.ms)
                                      .slideX(begin: 0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  QuickActionCard(
                                        icon: Icons.history_rounded,
                                        label: 'History',
                                        subtitle: 'Past sessions',
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF009688),
                                            Color(0xFF26A69A),
                                          ],
                                        ),
                                        onTap: () => context.go('/history'),
                                      )
                                      .animate()
                                      .fadeIn(delay: 500.ms)
                                      .slideX(begin: -0.1),
                            ),
                            const SizedBox(width: AppSpacing.s3),
                            Expanded(
                              child:
                                  QuickActionCard(
                                        icon: Icons.school_rounded,
                                        label: 'Learn',
                                        subtitle: '2,000 signs',
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE91E63),
                                            Color(0xFFFF5722),
                                          ],
                                        ),
                                        onTap: () => context.go('/learn'),
                                      )
                                      .animate()
                                      .fadeIn(delay: 550.ms)
                                      .slideX(begin: 0.1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Recent translations ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s6,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Translations',
                          style: AppTextStyles.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go('/history'),
                          child: Text(
                            'See all',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.accent500,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                  ),
                ),

                // Empty state for now
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s3,
                      AppSpacing.s6,
                      AppSpacing.s8,
                    ),
                    child: _EmptyTranslations().animate().fadeIn(delay: 650.ms),
                  ),
                ),

                // Bottom padding for nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.s16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────
class _HeroCard extends StatefulWidget {
  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glow = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/translate'),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2456), Color(0xFF0F1535)],
              ),
              borderRadius: AppRadius.xl2Border,
              border: Border.all(
                color: AppColors.accent500.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent500.withValues(
                    alpha: _glow.value * 0.15,
                  ),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Row(
            children: [
              // Left content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent500.withValues(alpha: 0.15),
                        borderRadius: AppRadius.fullBorder,
                        border: Border.all(
                          color: AppColors.accent500.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s1),
                          Text(
                            'Ready to translate',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accent500,
                              letterSpacing: 0,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Text(
                      'Start\nTranslating',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontSize: 26,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'Point your camera at any ASL sign',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary200,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s4,
                        vertical: AppSpacing.s2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppGradients.accent,
                        borderRadius: AppRadius.fullBorder,
                        boxShadow: AppShadows.glowCyan,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open Camera',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s1),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.s4),

              // Right illustration
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accent500.withValues(alpha: 0.08),
                  borderRadius: AppRadius.xlBorder,
                  border: Border.all(
                    color: AppColors.accent500.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🤟', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'ASL',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accent300,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty translations ─────────────────────────────────────────────
class _EmptyTranslations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: AppColors.primary400.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'No translations yet',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Start translating ASL signs and your\nhistory will appear here.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s4),
          GestureDetector(
            onTap: () => context.go('/translate'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s5,
                vertical: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent500.withValues(alpha: 0.1),
                borderRadius: AppRadius.fullBorder,
                border: Border.all(
                  color: AppColors.accent500.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Make your first translation',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
