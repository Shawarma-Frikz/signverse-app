import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailController.text.trim());
      if (mounted) setState(() => _emailSent = true);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.error500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: context.bgPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s6),
              child: _emailSent
                  ? _buildSuccessState()
                  : _buildFormState(isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormState(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary,
            ),
            padding: EdgeInsets.zero,
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.s4),

          const AuthHeader(
            title: 'Reset password',
            subtitle: 'Enter your email and we\'ll send you a reset link',
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: AppSpacing.s10),

          // Lock illustration
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withValues(alpha: 0.15),
                    AppColors.accent500.withValues(alpha: 0.03),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent500.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('🔐', style: TextStyle(fontSize: 42)),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).scale(),

          const SizedBox(height: AppSpacing.s10),

          AuthTextField(
                label: 'Email',
                hint: 'your@email.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: _sendResetEmail,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: AppSpacing.s6),

          AuthButton(
            label: 'Send Reset Link',
            onPressed: _sendResetEmail,
            isLoading: isLoading,
            icon: Icons.send_rounded,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: AppSpacing.s6),

          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Back to Sign In',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary200,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.success500.withValues(alpha: 0.2),
                AppColors.success500.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: AppColors.success500.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Text('✉️', style: TextStyle(fontSize: 52)),
          ),
        ).animate().scale(
          delay: 100.ms,
          curve: Curves.elasticOut,
          duration: 800.ms,
        ),

        const SizedBox(height: AppSpacing.s8),

        Text(
          'Check your inbox',
          style: AppTextStyles.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

        const SizedBox(height: AppSpacing.s3),

        Text(
          'We sent a password reset link to\n${_emailController.text}',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: AppSpacing.s4),

        Container(
          padding: const EdgeInsets.all(AppSpacing.s3),
          decoration: BoxDecoration(
            color: AppColors.accent500.withValues(alpha: 0.08),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: AppColors.accent500.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.accent300,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                'Link expires in 1 hour',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent300,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: AppSpacing.s10),

        SizedBox(
          width: double.infinity,
          child: AuthButton(
            label: 'Back to Sign In',
            onPressed: () => context.go('/login'),
            icon: Icons.arrow_back_rounded,
          ),
        ).animate().fadeIn(delay: 600.ms),

        const SizedBox(height: AppSpacing.s4),

        TextButton(
          onPressed: _sendResetEmail,
          child: Text(
            "Didn't receive it? Resend",
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary200,
            ),
          ),
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }
}
