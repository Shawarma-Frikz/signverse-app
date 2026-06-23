import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _error;

  // Password strength
  double _strength = 0;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  double _calcStrength(String v) {
    if (v.isEmpty) return 0;
    double s = 0;
    if (v.length >= 8) s += 0.25;
    if (v.length >= 12) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v)) s += 0.25;
    {
      if (RegExp(r'[0-9]').hasMatch(v) || RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
        s += 0.25;
      }
      return s;
    }
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return AppColors.error400;
    if (s <= 0.50) return AppColors.warning400;
    if (s <= 0.75) return AppColors.accent400;
    return AppColors.success400;
  }

  String _strengthLabel(double s) {
    if (s <= 0.25) return 'Weak';
    if (s <= 0.50) return 'Fair';
    if (s <= 0.75) return 'Good';
    return 'Strong';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiClient.instance.post(
        '/auth/change-password',
        data: {
          'current_password': _currentCtrl.text,
          'new_password': _newCtrl.text,
        },
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      }
      HapticFeedback.mediumImpact();
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      setState(() {
        _isLoading = false;
        _error = detail is String
            ? detail
            : 'Something went wrong. Please try again.';
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPrimary,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
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

          SafeArea(child: _isSuccess ? _buildSuccess() : _buildForm()),
        ],
      ),
    );
  }

  // ── Form ───────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s6),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              padding: EdgeInsets.zero,
            ).animate().fadeIn(),

            const SizedBox(height: AppSpacing.s4),

            // Logo + header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.accent,
                    borderRadius: AppRadius.mdBorder,
                    boxShadow: context.glowCyan,
                  ),
                  child: const Center(
                    child: Text('🤟', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Sign',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'Verse',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.accent500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.s8),

            Text(
              'Change password',
              style: AppTextStyles.displaySmall,
            ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.2),

            const SizedBox(height: AppSpacing.s2),

            Text(
              'Enter your current password and choose a strong new one.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.textSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.s8),

            // Current password
            AuthTextField(
              label: 'Current Password',
              hint: '••••••••',
              prefixIcon: Icons.lock_outlined,
              controller: _currentCtrl,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Current password is required';
                }
                return null;
              },
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),

            const SizedBox(height: AppSpacing.s4),

            // New password
            AuthTextField(
              label: 'New Password',
              hint: '••••••••',
              prefixIcon: Icons.lock_reset_rounded,
              controller: _newCtrl,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'New password is required';
                }
                if (v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (v == _currentCtrl.text) {
                  return 'New password must be different';
                }
                return null;
              },
              onSubmitted: null,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            // Strength meter
            const SizedBox(height: AppSpacing.s2),
            ValueListenableBuilder(
              valueListenable: _newCtrl,
              builder: (_, __, ___) {
                final s = _calcStrength(_newCtrl.text);
                if (_newCtrl.text.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.fullBorder,
                      child: LinearProgressIndicator(
                        value: s,
                        backgroundColor: AppColors.primary400.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation(_strengthColor(s)),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _strengthLabel(s),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _strengthColor(s),
                          letterSpacing: 0,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn();
              },
            ),

            const SizedBox(height: AppSpacing.s4),

            // Confirm new password
            AuthTextField(
              label: 'Confirm New Password',
              hint: '••••••••',
              prefixIcon: Icons.check_circle_outline_rounded,
              controller: _confirmCtrl,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (v != _newCtrl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),

            const SizedBox(height: AppSpacing.s4),

            // Error
            if (_error != null)
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
                        _error!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error400,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().shake(),

            if (_error != null) const SizedBox(height: AppSpacing.s4),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: context.glowCyan,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorder,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : Text(
                          'Update Password',
                          style: AppTextStyles.buttonLabel,
                        ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: AppSpacing.s5),

            // Forgot current password link
            Center(
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text(
                  "Forgot your current password?",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: context.textMuted,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────
  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.success500.withValues(alpha: 0.2),
                  AppColors.success500.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                color: AppColors.success500.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text('🔒', style: TextStyle(fontSize: 44)),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

          const SizedBox(height: AppSpacing.s8),

          Text(
            'Password updated!',
            style: AppTextStyles.displaySmall,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

          const SizedBox(height: AppSpacing.s3),

          Text(
            'Your password has been changed\nsuccessfully.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: context.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.s4),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            decoration: BoxDecoration(
              color: AppColors.success500.withValues(alpha: 0.08),
              borderRadius: AppRadius.lgBorder,
              border: Border.all(
                color: AppColors.success500.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success400,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.s2),
                Text(
                  'Your account is secure',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success400,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: AppSpacing.s10),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: AppRadius.lgBorder,
                boxShadow: context.glowCyan,
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.white,
                ),
                label: Text(
                  'Back to Profile',
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
        ],
      ),
    );
  }
}
