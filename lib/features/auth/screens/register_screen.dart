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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'Please agree to the terms to continue');
      return;
    }
    setState(() => _errorMessage = null);

    try {
      await ref
          .read(authProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );

      // --- UPDATED NAVIGATION LOGIC ---
      if (mounted) {
        context.push('/verify-email', extra: _emailController.text.trim());
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: context.bgPrimary,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary500.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s6),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
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
                      title: 'Create account',
                      subtitle: 'Join SignVerse and start translating',
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s8),

                    // Name
                    AuthTextField(
                          label: 'Display Name',
                          hint: 'Your name',
                          prefixIcon: Icons.person_outlined,
                          controller: _nameController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Name is required';
                            }
                            if (v.length < 2) return 'Name too short';
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s4),

                    // Email
                    AuthTextField(
                          label: 'Email',
                          hint: 'your@email.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s4),

                    // Password
                    AuthTextField(
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outlined,
                          controller: _passwordController,
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s4),

                    // Confirm password
                    AuthTextField(
                          label: 'Confirm Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outlined,
                          controller: _confirmController,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _register,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s4),

                    // Terms checkbox
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _agreedToTerms
                                  ? AppColors.accent500
                                  : Colors.transparent,
                              borderRadius: AppRadius.xsBorder,
                              border: Border.all(
                                color: _agreedToTerms
                                    ? AppColors.accent500
                                    : AppColors.primary300,
                                width: 1.5,
                              ),
                            ),
                            child: _agreedToTerms
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.s3),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodySmall,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.accent500,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.accent500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: AppSpacing.s4),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s3),
                        decoration: BoxDecoration(
                          color: AppColors.error500.withValues(alpha: 0.1),
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(
                            color: AppColors.error500.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error400,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().shake(),

                    const SizedBox(height: AppSpacing.s6),

                    // Register button
                    AuthButton(
                      label: 'Create Account',
                      onPressed: _register,
                      isLoading: isLoading,
                      icon: Icons.person_add_rounded,
                    ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                    const SizedBox(height: AppSpacing.s6),

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.accent500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: AppSpacing.s8),
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
