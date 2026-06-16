import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/auth_models.dart';

// ── Profile provider ───────────────────────────────────────────────
final profileProvider = FutureProvider<UserProfile>((ref) async {
  final response = await ApiClient.instance.get('/auth/me');
  return UserProfile.fromJson(response.data);
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      await ApiClient.instance.put(
        '/auth/me',
        data: {'display_name': _nameController.text.trim()},
      );
      ref.invalidate(profileProvider);
      ref.invalidate(authProvider);
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success400,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.s2),
                Text('Profile updated!', style: AppTextStyles.bodyMedium),
              ],
            ),
            backgroundColor: AppColors.surfaceVariant,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.lgBorder,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _LogoutDialog(),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final authUser = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: profileAsync.when(
              loading: () => _buildLoading(),
              error: (e, _) => _buildError(e),
              data: (profile) => _buildProfile(profile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent500),
            strokeWidth: 2,
          ),
          SizedBox(height: AppSpacing.s4),
          Text('Loading profile...'),
        ],
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.s4),
            Text('Failed to load profile', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.s2),
            Text(
              'Check your connection and try again.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s6),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(profileProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(UserProfile profile) {
    _nameController.text = profile.displayName ?? '';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App bar ──────────────────────────────────────────────
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
                Text('Profile', style: AppTextStyles.headlineMedium),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        _nameController.text = profile.displayName ?? '';
                      }
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_outlined,
                    color: _isEditing
                        ? AppColors.error400
                        : AppColors.accent500,
                    size: 20,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),

        // ── Avatar + name ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s6,
              AppSpacing.s6,
              AppSpacing.s6,
              0,
            ),
            child: Column(
              children: [
                // Avatar
                AnimatedBuilder(
                  animation: _avatarController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent500.withOpacity(
                              0.2 + _avatarController.value * 0.15,
                            ),
                            blurRadius: 30 + _avatarController.value * 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.accent,
                      border: Border.all(
                        color: AppColors.accent500.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (profile.displayName?.isNotEmpty == true
                                ? profile.displayName![0]
                                : profile.email[0])
                            .toUpperCase(),
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(
                  delay: 100.ms,
                  curve: Curves.elasticOut,
                  duration: 800.ms,
                ),

                const SizedBox(height: AppSpacing.s4),

                // Name
                if (_isEditing)
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: AppTextStyles.displaySmall.copyWith(fontSize: 22),
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                          vertical: AppSpacing.s3,
                        ),
                        suffixIcon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.accent500,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.accent500,
                                ),
                                onPressed: _saveProfile,
                              ),
                      ),
                    ),
                  ).animate().fadeIn().scale()
                else
                  Text(
                    profile.displayName ?? profile.email.split('@').first,
                    style: AppTextStyles.displaySmall.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSpacing.s2),

                Text(
                  profile.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: AppSpacing.s3),

                // Verified badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s1,
                  ),
                  decoration: BoxDecoration(
                    color: profile.isVerified
                        ? AppColors.success500.withOpacity(0.1)
                        : AppColors.warning500.withOpacity(0.1),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: profile.isVerified
                          ? AppColors.success500.withOpacity(0.3)
                          : AppColors.warning500.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profile.isVerified
                            ? Icons.verified_rounded
                            : Icons.warning_rounded,
                        size: 14,
                        color: profile.isVerified
                            ? AppColors.success400
                            : AppColors.warning400,
                      ),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        profile.isVerified
                            ? 'Verified account'
                            : 'Email not verified',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: profile.isVerified
                              ? AppColors.success400
                              : AppColors.warning400,
                          letterSpacing: 0,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),

        // ── Info cards ────────────────────────────────────────────
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
                  'Account Info',
                  style: AppTextStyles.headlineMedium,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: AppSpacing.s3),

                _InfoCard(
                  items: [
                    _InfoItem(
                      icon: Icons.person_outlined,
                      label: 'Display Name',
                      value: profile.displayName ?? 'Not set',
                    ),
                    _InfoItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email,
                    ),
                    _InfoItem(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      value: profile.preferredLanguage.toUpperCase(),
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Member since',
                      value: _formatDate(profile.createdAt),
                      isLast: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),

        // ── Actions ───────────────────────────────────────────────
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
                  'Account Actions',
                  style: AppTextStyles.headlineMedium,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: AppSpacing.s3),

                _ActionCard(
                  items: [
                    _ActionItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () => context.push('/forgot-password'),
                      color: AppColors.accent500,
                    ),
                    _ActionItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {},
                      color: AppColors.secondary500,
                    ),
                    _ActionItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                      color: AppColors.primary300,
                      isLast: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),

                const SizedBox(height: AppSpacing.s4),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error400,
                      size: 18,
                    ),
                    label: Text(
                      'Sign Out',
                      style: AppTextStyles.buttonLabel.copyWith(
                        color: AppColors.error400,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s4,
                      ),
                      side: BorderSide(
                        color: AppColors.error400.withOpacity(0.4),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lgBorder,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ── Info card ─────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: AppColors.primary400.withOpacity(0.2)),
      ),
      child: Column(children: items),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoItem({
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

// ── Action card ───────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final List<_ActionItem> items;
  const _ActionCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: AppColors.primary400.withOpacity(0.2)),
      ),
      child: Column(children: items),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isLast;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                )
              : BorderRadius.zero,
          child: Padding(
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
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary300,
                  size: 18,
                ),
              ],
            ),
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

// ── Logout dialog ─────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xl2Border),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error500.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error500.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error400,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text('Sign out?', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.s2),
            Text(
              'You\'ll need to sign in again\nto use SignVerse.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s3,
                      ),
                      side: BorderSide(
                        color: AppColors.primary400.withOpacity(0.4),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lgBorder,
                      ),
                    ),
                    child: Text('Cancel', style: AppTextStyles.labelLarge),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error500,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s3,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lgBorder,
                      ),
                    ),
                    child: Text('Sign Out', style: AppTextStyles.buttonLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().scale(curve: Curves.elasticOut, duration: 400.ms);
  }
}
