import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/sign_database.dart';
import '../models/sign_model.dart';

class SignDetailScreen extends StatelessWidget {
  final String signId;
  const SignDetailScreen({super.key, required this.signId});

  @override
  Widget build(BuildContext context) {
    final sign = SignDatabase.findById(signId);
    if (sign == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('Sign not found')),
      );
    }
    return _SignDetailView(sign: sign);
  }
}

class _SignDetailView extends StatelessWidget {
  final SignModel sign;
  const _SignDetailView({required this.sign});

  Color get _diffColor => switch (sign.difficulty) {
    1 => AppColors.success400,
    2 => AppColors.warning400,
    _ => AppColors.error400,
  };

  String get _diffLabel => switch (sign.difficulty) {
    1 => 'Easy',
    2 => 'Medium',
    _ => 'Hard',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App bar ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s4,
                      AppSpacing.s2,
                      AppSpacing.s4,
                      0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          sign.category.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.accent400,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => TtsService.instance.speak(sign.word),
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.accent500,
                            size: 22,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),
                ),

                // ── Hero card ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s4,
                      AppSpacing.s6,
                      0,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A2456), Color(0xFF0F1535)],
                        ),
                        borderRadius: AppRadius.xl2Border,
                        border: Border.all(
                          color: AppColors.accent500.withOpacity(0.25),
                        ),
                        boxShadow: AppShadows.glowCyan,
                      ),
                      child: Column(
                        children: [
                          // Sign word large display
                          Text(
                            sign.word,
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: sign.word.length > 5 ? 40 : 64,
                              color: AppColors.accent300,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            sign.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.s5),
                          // Badges row
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppSpacing.s2,
                            children: [
                              _Badge(
                                label: _diffLabel,
                                color: _diffColor,
                                icon: Icons.signal_cellular_alt_rounded,
                              ),
                              if (sign.isDynamic)
                                const _Badge(
                                  label: 'Motion required',
                                  color: AppColors.warning400,
                                  icon: Icons.gesture_rounded,
                                ),
                              _Badge(
                                label: sign.category.label,
                                color: AppColors.accent400,
                                icon: Icons.category_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                ),

                // ── How to sign it ────────────────────────────────
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
                          'How to sign it',
                          style: AppTextStyles.headlineMedium,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: AppSpacing.s3),
                        _InfoCard(
                          children: [
                            _InfoRow(
                              icon: Icons.back_hand_outlined,
                              label: 'Hand shape',
                              value: sign.handShape,
                            ),
                            _InfoRow(
                              icon: Icons.sync_rounded,
                              label: 'Movement',
                              value: sign.movement,
                            ),
                            _InfoRow(
                              icon: Icons.place_outlined,
                              label: 'Location',
                              value: sign.location,
                              isLast: true,
                            ),
                          ],
                        ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                      ],
                    ),
                  ),
                ),

                // ── Tips ──────────────────────────────────────────
                if (sign.tips.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s6,
                        AppSpacing.s5,
                        AppSpacing.s6,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips',
                            style: AppTextStyles.headlineMedium,
                          ).animate().fadeIn(delay: 350.ms),
                          const SizedBox(height: AppSpacing.s3),
                          ...sign.tips.asMap().entries.map(
                            (e) => _TipTile(tip: e.value, index: e.key)
                                .animate()
                                .fadeIn(
                                  delay: Duration(
                                    milliseconds: 400 + e.key * 80,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Practice CTA ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppGradients.accent,
                          borderRadius: AppRadius.lgBorder,
                          boxShadow: AppShadows.glowCyan,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.go('/translate');
                          },
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                          label: Text(
                            'Practice this sign',
                            style: AppTextStyles.buttonLabel,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.lgBorder,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: AppSpacing.s1),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              letterSpacing: 0,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: AppColors.primary400.withOpacity(0.2)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s4,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(icon, color: AppColors.accent500, size: 18),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.primary400.withOpacity(0.2),
            indent: AppSpacing.s4,
            endIndent: AppSpacing.s4,
          ),
      ],
    );
  }
}

class _TipTile extends StatelessWidget {
  final String tip;
  final int index;
  const _TipTile({required this.tip, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.accent500.withOpacity(0.06),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.accent500.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accent500.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accent400,
                  letterSpacing: 0,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
