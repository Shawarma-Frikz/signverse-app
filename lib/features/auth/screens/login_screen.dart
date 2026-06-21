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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go('/home');
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
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
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
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s6),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s8),

                    const AuthHeader(
                      title: 'Welcome back',
                      subtitle: 'Sign in to continue translating',
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s10),

                    // Email field
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
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s4),

                    // Password field
                    AuthTextField(
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outlined,
                          controller: _passwordController,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _login,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) return 'Password too short';
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s2),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.accent500,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: AppSpacing.s2),

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

                    // Login button
                    AuthButton(
                          label: 'Sign In',
                          onPressed: _login,
                          isLoading: isLoading,
                          icon: Icons.login_rounded,
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: AppSpacing.s8),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.primary400.withValues(alpha: 0.4),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s3,
                          ),
                          child: Text('or', style: AppTextStyles.bodySmall),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.primary400.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: AppSpacing.s6),

                    // Register link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              'Sign Up',
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
