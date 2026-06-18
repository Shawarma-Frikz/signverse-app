import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _resent = false;

  Future<void> _resend() async {
    await ref.read(authRepositoryProvider).resendVerification(widget.email);
    setState(() => _resent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent500.withValues(alpha: 0.2),
                      AppColors.accent500.withValues(alpha: 0.03),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accent500.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text('✉️', style: TextStyle(fontSize: 52)),
                ),
              ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

              const SizedBox(height: AppSpacing.s8),

              Text(
                'Verify your email',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: AppSpacing.s3),

              Text(
                'We sent a verification link to\n${widget.email}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppSpacing.s3),

              Container(
                padding: const EdgeInsets.all(AppSpacing.s3),
                decoration: BoxDecoration(
                  color: AppColors.warning500.withValues(alpha: 0.08),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: AppColors.warning500.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.warning400,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      'Link expires in 24 hours',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.warning400,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSpacing.s10),

              SizedBox(
                width: double.infinity,
                child: AuthButton(
                  label: 'I verified my email',
                  onPressed: () => context.go('/login'),
                  icon: Icons.check_circle_rounded,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: AppSpacing.s4),

              TextButton(
                onPressed: _resent ? null : _resend,
                child: Text(
                  _resent
                      ? '✅ Verification email resent!'
                      : "Didn't receive it? Resend",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: _resent
                        ? AppColors.success400
                        : AppColors.primary200,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: AppSpacing.s4),

              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Back to Sign In',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary300,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
