import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authProvider).user;
    final notifier = ref.read(settingsProvider.notifier);

    if (settings.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent500),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgPrimary,
      body: Stack(
        children: [
          // Subtle background glow
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withValues(alpha: 0.06),
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
                // ── Header ──────────────────────────────────────
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

                // ── Profile card ─────────────────────────────────
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
                              width: 52,
                              height: 52,
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
                                    fontSize: 22,
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
                                    style: AppTextStyles.headlineMedium
                                        .copyWith(color: AppColors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.email ?? '',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary200,
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

                // ── Appearance ───────────────────────────────────
                const _SectionHeader(
                  title: 'Appearance',
                  icon: Icons.palette_outlined,
                  delay: 200,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      0,
                      AppSpacing.s6,
                      0,
                    ),
                    child: _SettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.dark_mode_outlined,
                          iconColor: AppColors.accent500,
                          title: 'Theme',
                          subtitle: [
                            'Dark',
                            'Light',
                            'System',
                          ][settings.themeMode],
                          trailing: _ThemeToggle(
                            value: settings.themeMode,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              notifier.setThemeMode(v);
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                  ),
                ),

                // ── Language ─────────────────────────────────────
                const _SectionHeader(
                  title: 'Language',
                  icon: Icons.language_rounded,
                  delay: 300,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      0,
                      AppSpacing.s6,
                      0,
                    ),
                    child: _SettingsCard(
                      children: [
                        _LanguageSelector(
                          value: settings.language,
                          onChanged: (lang) {
                            HapticFeedback.lightImpact();
                            notifier.setLanguage(lang);
                          },
                        ),
                      ],
                    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
                  ),
                ),

                // ── Text to Speech ────────────────────────────────
                const _SectionHeader(
                  title: 'Text to Speech',
                  icon: Icons.record_voice_over_rounded,
                  delay: 400,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      0,
                      AppSpacing.s6,
                      0,
                    ),
                    child: _SettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.volume_up_rounded,
                          iconColor: AppColors.secondary500,
                          title: 'Text to Speech',
                          subtitle: settings.ttsEnabled
                              ? 'Enabled'
                              : 'Disabled',
                          trailing: Switch(
                            value: settings.ttsEnabled,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              notifier.setTtsEnabled(v);
                            },
                            activeThumbColor: AppColors.accent500,
                          ),
                        ),

                        if (settings.ttsEnabled) ...[
                          _SliderItem(
                            icon: Icons.speed_rounded,
                            iconColor: AppColors.accent400,
                            title: 'Speech Speed',
                            value: settings.ttsSpeed,
                            min: 0.2,
                            max: 0.9,
                            divisions: 7,
                            valueLabel: _speedLabel(settings.ttsSpeed),
                            onChanged: notifier.setTtsSpeed,
                            onPreview: () =>
                                TtsService.instance.speak('SignVerse'),
                          ),
                          _SliderItem(
                            icon: Icons.music_note_rounded,
                            iconColor: AppColors.accent300,
                            title: 'Speech Pitch',
                            value: settings.ttsPitch,
                            min: 0.5,
                            max: 2.0,
                            divisions: 6,
                            valueLabel: _pitchLabel(settings.ttsPitch),
                            onChanged: notifier.setTtsPitch,
                            onPreview: () =>
                                TtsService.instance.speak('SignVerse'),
                            isLast: true,
                          ),
                        ],
                      ],
                    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                  ),
                ),

                // ── Camera ───────────────────────────────────────
                const _SectionHeader(
                  title: 'Camera',
                  icon: Icons.camera_alt_outlined,
                  delay: 500,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      0,
                      AppSpacing.s6,
                      0,
                    ),
                    child: _SettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.flip_camera_ios_rounded,
                          iconColor: AppColors.accent500,
                          title: 'Default Camera',
                          subtitle: settings.useFrontCamera
                              ? 'Front camera'
                              : 'Back camera',
                          trailing: Switch(
                            value: settings.useFrontCamera,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              notifier.setFrontCamera(v);
                            },
                            activeThumbColor: AppColors.accent500,
                          ),
                        ),
                        _SettingsItem(
                          icon: Icons.account_tree_outlined,
                          iconColor: AppColors.secondary500,
                          title: 'Show Landmarks',
                          subtitle: 'Skeleton overlay on hand',
                          trailing: Switch(
                            value: settings.showLandmarks,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              notifier.setShowLandmarks(v);
                            },
                            activeThumbColor: AppColors.accent500,
                          ),
                        ),
                        _SliderItem(
                          icon: Icons.tune_rounded,
                          iconColor: AppColors.accent400,
                          title: 'Confidence Threshold',
                          value: settings.confThreshold,
                          min: 0.50,
                          max: 0.95,
                          divisions: 9,
                          valueLabel:
                              '${(settings.confThreshold * 100).toInt()}%',
                          onChanged: notifier.setConfThreshold,
                          isLast: true,
                        ),
                      ],
                    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),
                  ),
                ),

                // ── Accessibility ────────────────────────────────
                const _SectionHeader(
                  title: 'Accessibility',
                  icon: Icons.accessibility_new_rounded,
                  delay: 600,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      0,
                      AppSpacing.s6,
                      0,
                    ),
                    child: _SettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.vibration_rounded,
                          iconColor: AppColors.accent500,
                          title: 'Haptic Feedback',
                          subtitle: 'Vibrate on interactions',
                          trailing: Switch(
                            value: settings.hapticEnabled,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              notifier.setHaptic(v);
                            },
                            activeThumbColor: AppColors.accent500,
                          ),
                          isLast: true,
                        ),
                      ],
                    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),
                  ),
                ),

                // ── About ────────────────────────────────────────
                const _SectionHeader(
                  title: 'About',
                  icon: Icons.info_outline_rounded,
                  delay: 700,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      0,
                      AppSpacing.s6,
                      0,
                    ),
                    child: const _SettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.tag_rounded,
                          iconColor: AppColors.primary300,
                          title: 'Version',
                          subtitle: '1.0.0 (Sprint 7)',
                          trailing: SizedBox.shrink(),
                        ),
                        _SettingsItem(
                          icon: Icons.school_rounded,
                          iconColor: AppColors.primary300,
                          title: 'Built at',
                          subtitle: 'Polytech International',
                          trailing: SizedBox.shrink(),
                        ),
                        _SettingsItem(
                          icon: Icons.code_rounded,
                          iconColor: AppColors.accent400,
                          title: 'Stack',
                          subtitle: 'Flutter • FastAPI • MediaPipe',
                          trailing: SizedBox.shrink(),
                          isLast: true,
                        ),
                      ],
                    ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.1),
                  ),
                ),

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

  String _speedLabel(double v) {
    if (v <= 0.3) return 'Slow';
    if (v <= 0.6) return 'Normal';
    return 'Fast';
  }

  String _pitchLabel(double v) {
    if (v <= 0.8) return 'Low';
    if (v <= 1.2) return 'Normal';
    return 'High';
  }
}

// ── Section header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int delay;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s6,
          AppSpacing.s5,
          AppSpacing.s6,
          AppSpacing.s3,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent500, size: 16),
            const SizedBox(width: AppSpacing.s2),
            Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent500,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)),
    );
  }
}

// ── Settings card ─────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: context.border),
      ),
      child: Column(children: children),
    );
  }
}

// ── Settings item ─────────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isLast;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.primary400.withValues(alpha: 0.15),
            indent: AppSpacing.s4,
            endIndent: AppSpacing.s4,
          ),
      ],
    );
  }
}

// ── Slider item ───────────────────────────────────────────────────
class _SliderItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final void Function(double) onChanged;
  final VoidCallback? onPreview;
  final bool isLast;

  const _SliderItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
    this.onPreview,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s3,
            AppSpacing.s4,
            0,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smBorder,
                ),
                child: Text(
                  valueLabel,
                  style: AppTextStyles.mono.copyWith(
                    color: iconColor,
                    fontSize: 11,
                  ),
                ),
              ),
              if (onPreview != null) ...[
                const SizedBox(width: AppSpacing.s2),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPreview!();
                  },
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: iconColor.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: iconColor,
          inactiveColor: iconColor.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.primary400.withValues(alpha: 0.15),
            indent: AppSpacing.s4,
            endIndent: AppSpacing.s4,
          ),
      ],
    );
  }
}

// ── Theme toggle ──────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final int value; // 0=dark 1=light 2=system
  final void Function(int) onChanged;

  const _ThemeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeOption(
          icon: Icons.dark_mode_rounded,
          label: 'Dark',
          isSelected: value == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: AppSpacing.s1),
        _ThemeOption(
          icon: Icons.light_mode_rounded,
          label: 'Light',
          isSelected: value == 1,
          onTap: () => onChanged(1),
        ),
        const SizedBox(width: AppSpacing.s1),
        _ThemeOption(
          icon: Icons.phone_android_rounded,
          label: 'Auto',
          isSelected: value == 2,
          onTap: () => onChanged(2),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s1,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent500.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: AppRadius.smBorder,
          border: Border.all(
            color: isSelected
                ? AppColors.accent500.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accent500 : AppColors.primary300,
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 9,
                color: isSelected ? AppColors.accent500 : AppColors.primary300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language selector ─────────────────────────────────────────────
class _LanguageSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const _LanguageSelector({required this.value, required this.onChanged});

  static const _languages = [
    ('en', '🇺🇸', 'English'),
    ('fr', '🇫🇷', 'Français'),
    ('ar', '🇹🇳', 'العربية'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.s1,
              bottom: AppSpacing.s3,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent500.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.accent500,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Text(
                  'App Language',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            children: _languages.map((lang) {
              final isSelected = value == lang.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChanged(lang.$1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s3,
                      horizontal: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent500.withValues(alpha: 0.12)
                          : AppColors.surfaceVariant,
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent500.withValues(alpha: 0.5)
                            : context.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(lang.$2, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: AppSpacing.s1),
                        Text(
                          lang.$3,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.accent400
                                : AppColors.primary300,
                            letterSpacing: 0,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
