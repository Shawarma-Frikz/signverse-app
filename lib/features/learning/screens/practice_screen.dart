import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/sign_model.dart';
import '../providers/learning_provider.dart';

class PracticeScreen extends ConsumerWidget {
  final List<SignModel> signs;
  const PracticeScreen({super.key, required this.signs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider(signs));
    final notifier = ref.read(practiceProvider(signs).notifier);

    if (state.isFinished) {
      return _ResultScreen(state: state, onRestart: notifier.restart);
    }

    final sign = state.current!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, state),
            _buildProgressBar(state),
            Expanded(child: _buildCard(sign, state)),
            _buildButtons(context, sign, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PracticeState state) {
    return Padding(
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
              Icons.close_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${state.currentIndex + 1} of ${state.total}',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s3,
              vertical: AppSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: AppColors.success500.withOpacity(0.1),
              borderRadius: AppRadius.fullBorder,
              border: Border.all(color: AppColors.success500.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.success400,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.correct}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildProgressBar(PracticeState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s3,
        AppSpacing.s6,
        0,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.fullBorder,
        child: LinearProgressIndicator(
          value: state.progress,
          backgroundColor: AppColors.primary400.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation(AppColors.accent500),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildCard(SignModel sign, PracticeState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2456), Color(0xFF0F1535)],
          ),
          borderRadius: AppRadius.xl2Border,
          border: Border.all(color: AppColors.accent500.withOpacity(0.25)),
          boxShadow: AppShadows.glowCyan,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category + difficulty
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sign.category.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Text(
                    sign.category.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.s6),

              // Big sign word
              Text(
                sign.word,
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: sign.word.length > 6 ? 40 : 72,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().scale(
                begin: const Offset(0.8, 0.8),
                curve: Curves.elasticOut,
                duration: 600.ms,
              ),

              const SizedBox(height: AppSpacing.s6),

              // Description
              Text(
                sign.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: AppSpacing.s4),

              // Hand shape chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s4,
                  vertical: AppSpacing.s2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withOpacity(0.1),
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                    color: AppColors.accent500.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.back_hand_outlined,
                      color: AppColors.accent400,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      sign.handShape,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.accent300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              if (sign.isDynamic) ...[
                const SizedBox(height: AppSpacing.s2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning500.withOpacity(0.1),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: AppColors.warning500.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.gesture_rounded,
                        color: AppColors.warning400,
                        size: 12,
                      ),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        'Motion required',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning300,
                          letterSpacing: 0,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms),
              ],

              if (sign.tips.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s5),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s3),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.04),
                    borderRadius: AppRadius.lgBorder,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.warning400,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Expanded(
                        child: Text(
                          sign.tips.first,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    SignModel sign,
    PracticeNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        0,
        AppSpacing.s6,
        AppSpacing.s6,
      ),
      child: Column(
        children: [
          Text('Did you sign it correctly?', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Expanded(
                child: _AnswerButton(
                  label: 'Not yet',
                  icon: Icons.close_rounded,
                  color: AppColors.error400,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    notifier.markIncorrect();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: _AnswerButton(
                  label: 'Got it!',
                  icon: Icons.check_rounded,
                  color: AppColors.success400,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.markCorrect();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          TextButton(
            onPressed: () => context.go('/learn/${sign.id}'),
            child: Text(
              'View details',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary200,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}

// ── Answer button ─────────────────────────────────────────────────
class _AnswerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: widget.color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: AppSpacing.s2),
              Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(color: widget.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Result screen ─────────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final PracticeState state;
  final VoidCallback onRestart;

  const _ResultScreen({required this.state, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final pct = state.total == 0 ? 0.0 : state.correct / state.total;
    final emoji = pct >= 0.8
        ? '🎉'
        : pct >= 0.5
        ? '👍'
        : '💪';
    final message = pct >= 0.8
        ? 'Excellent work!'
        : pct >= 0.5
        ? 'Good effort!'
        : 'Keep practicing!';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 72),
              ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
              const SizedBox(height: AppSpacing.s5),
              Text(
                message,
                style: AppTextStyles.displaySmall,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Session complete',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppSpacing.s8),

              // Score card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.xl2Border,
                  border: Border.all(
                    color: AppColors.accent500.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ScoreStat(
                          value: '${state.correct}',
                          label: 'Correct',
                          color: AppColors.success400,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.primary400.withOpacity(0.3),
                        ),
                        _ScoreStat(
                          value: '${state.incorrect}',
                          label: 'Missed',
                          color: AppColors.error400,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.primary400.withOpacity(0.3),
                        ),
                        _ScoreStat(
                          value: '${(pct * 100).toInt()}%',
                          label: 'Score',
                          color: AppColors.accent400,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    ClipRRect(
                      borderRadius: AppRadius.fullBorder,
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.primary400.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(
                          pct >= 0.8
                              ? AppColors.success400
                              : pct >= 0.5
                              ? AppColors.accent400
                              : AppColors.error400,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: AppSpacing.s8),

              SizedBox(
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
                      onRestart();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.white,
                    ),
                    label: Text(
                      'Practice again',
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
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: AppSpacing.s3),

              TextButton(
                onPressed: () => context.go('/learn'),
                child: Text(
                  'Back to library',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary200,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ScoreStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(
            color: color,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
