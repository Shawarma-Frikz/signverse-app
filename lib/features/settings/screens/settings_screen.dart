import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s6,
                  AppSpacing.s6,
                  AppSpacing.s6,
                  0,
                ),
                child: Text(
                  'Settings',
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 28),
                ).animate().fadeIn(),
              ),
            ),

            // Profile card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s6,
                  AppSpacing.s5,
                  AppSpacing.s6,
                  0,
                ),
                child: GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A2456), Color(0xFF0F1535)],
                      ),
                      borderRadius: AppRadius.xl2Border,
                      border: Border.all(
                        color: AppColors.accent500.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0]
                                      : user?.email[0] ?? 'S')
                                  .toUpperCase(),
                              style: AppTextStyles.displaySmall.copyWith(
                                color: AppColors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ??
                                    user?.email.split('@').first ??
                                    'User',
                                style: AppTextStyles.headlineMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.accent500,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              ),
            ),

            // Settings groups
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
                      'Preferences',
                      style: AppTextStyles.headlineMedium,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.s3),
                    _SettingsGroup(
                      items: [
                        _SettingsTile(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          trailing: Switch(
                            value: true,
                            onChanged: (_) {},
                            activeThumbColor: AppColors.accent500,
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.volume_up_outlined,
                          label: 'Text to Speech',
                          trailing: Switch(
                            value: true,
                            onChanged: (_) {},
                            activeThumbColor: AppColors.accent500,
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.vibration_rounded,
                          label: 'Haptic Feedback',
                          trailing: Switch(
                            value: true,
                            onChanged: (_) {},
                            activeThumbColor: AppColors.accent500,
                          ),
                          isLast: true,
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),

                    const SizedBox(height: AppSpacing.s5),

                    Text(
                      'About',
                      style: AppTextStyles.headlineMedium,
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: AppSpacing.s3),
                    _SettingsGroup(
                      items: [
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          label: 'App Version',
                          trailing: Text(
                            '1.0.0',
                            style: AppTextStyles.bodySmall,
                          ),
                          isLast: true,
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsTile> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: AppColors.primary400.withValues(alpha: 0.2)),
      ),
      child: Column(children: items),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(icon, color: AppColors.accent500, size: 18),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.primary400.withValues(alpha: 0.2),
            indent: AppSpacing.s4,
            endIndent: AppSpacing.s4,
          ),
      ],
    );
  }
}
