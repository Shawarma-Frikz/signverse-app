import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/auth_models.dart';

// ── Profile provider ──────────────────────────────────────────────
final profileProvider = FutureProvider<UserProfile>((ref) async {
  final response = await ApiClient.instance.get('/auth/me');
  return UserProfile.fromJson(response.data as Map<String, dynamic>);
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarGlow;

  // Edit state
  bool _isEditingName = false;
  bool _isEditingBio = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;

  final _picker = ImagePicker();

  static const _languages = [
    ('en', '🇺🇸', 'English'),
    ('fr', '🇫🇷', 'Français'),
    ('ar', '🇹🇳', 'العربية'),
  ];

  @override
  void initState() {
    super.initState();
    _avatarGlow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _avatarGlow.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  String _fallbackLetter(UserProfile p) =>
      (p.displayName?.isNotEmpty == true ? p.displayName![0] : p.email[0]);

  // ── Avatar upload ─────────────────────────────────────────────
  Future<void> _pickAndUploadAvatar() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

      await ApiClient.instance.post(
        '/users/avatar',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: 'avatar.$ext',
            contentType: MediaType.parse(mime),
          ),
        }),
      );

      ref.invalidate(profileProvider);
      ref.invalidate(authProvider);

      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSnack('Profile picture updated!', isSuccess: true);
      }
    } catch (_) {
      if (mounted) _showSnack('Upload failed. Try again.', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppSpacing.s3),
        padding: const EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: context.bgSurface,
          borderRadius: AppRadius.xl2Border,
          border: Border.all(color: context.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: AppRadius.fullBorder,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text('Change Profile Picture', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.s5),
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.s2,
            ),
          ],
        ),
      ),
    );
  }

  // ── Save name ─────────────────────────────────────────────────
  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _isSaving = true;
      _isEditingName = false;
    });

    try {
      await ApiClient.instance.put('/auth/me', data: {'display_name': name});
      // Reset so the guard re-initialises from fresh profile data
      _nameCtrl.clear();
      ref.invalidate(profileProvider);
      ref.invalidate(authProvider);
      if (mounted) _showSnack('Name updated!', isSuccess: true);
    } catch (_) {
      if (mounted) _showSnack('Failed to update name.', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Save bio ──────────────────────────────────────────────────
  Future<void> _saveBio() async {
    setState(() {
      _isSaving = true;
      _isEditingBio = false;
    });
    try {
      await ApiClient.instance.put(
        '/auth/me',
        data: {'bio': _bioCtrl.text.trim()},
      );
      // Reset so the guard re-initialises from fresh profile data
      _bioCtrl.clear();
      ref.invalidate(profileProvider);
      if (mounted) _showSnack('Bio updated!', isSuccess: true);
    } catch (_) {
      if (mounted) _showSnack('Failed to update bio.', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Save language ─────────────────────────────────────────────
  Future<void> _saveLanguage(String lang) async {
    try {
      await ApiClient.instance.put(
        '/auth/me',
        data: {'preferred_language': lang},
      );
      ref.invalidate(profileProvider);
      if (mounted) _showSnack('Language updated!', isSuccess: true);
    } catch (_) {}
  }

  void _showSnack(String msg, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? AppColors.success400 : AppColors.error400,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.s2),
            Text(msg, style: AppTextStyles.bodyMedium),
          ],
        ),
        backgroundColor: context.bgVariant,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: context.bgPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
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
            child: profileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.accent500),
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => _buildError(),
              data: (profile) {
                // Only initialise from profile when the controller is empty
                // (i.e. freshly loaded or after a save+clear)
                if (_nameCtrl.text.isEmpty) {
                  _nameCtrl.text = profile.displayName ?? '';
                }
                if (_bioCtrl.text.isEmpty) {
                  _bioCtrl.text = profile.bio ?? '';
                }
                return _buildProfile(profile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.s4),
          Text('Failed to load profile', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.s6),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(profileProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(UserProfile profile) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App bar ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s2,
              AppSpacing.s2,
              AppSpacing.s2,
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                ),
                const Spacer(),
                Text('Profile', style: AppTextStyles.headlineMedium),
                const Spacer(),
                _isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.accent500,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(width: 48),
              ],
            ).animate().fadeIn(),
          ),
        ),

        // ── Avatar section ─────────────────────────────────────
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
                // Avatar with upload button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow ring
                    AnimatedBuilder(
                      animation: _avatarGlow,
                      builder: (_, child) => Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent500.withValues(
                                alpha: 0.15 + _avatarGlow.value * 0.15,
                              ),
                              blurRadius: 30 + _avatarGlow.value * 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent500.withValues(alpha: 0.4),
                          width: 3,
                        ),
                      ),
                      child: _isUploadingAvatar
                          ? Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.bgVariant,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.accent500,
                                  ),
                                ),
                              ),
                            )
                          : UserAvatar(
                              avatarUrl: profile.avatarUrl,
                              fallbackLetter: _fallbackLetter(profile),
                              size: 100,
                            ),
                    ),

                    // Camera button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: AppGradients.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.bgPrimary,
                              width: 2,
                            ),
                            // 🚨 UPDATED: Use context.glowCyan so the glow
                            // automatically disables itself in light mode.
                            boxShadow: context.glowCyan,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().scale(
                  delay: 100.ms,
                  curve: Curves.elasticOut,
                  duration: 800.ms,
                ),

                const SizedBox(height: AppSpacing.s4),

                // ── Name ────────────────────────────────────────
                _isEditingName
                    ? _EditField(
                        controller: _nameCtrl,
                        hint: 'Your name',
                        onSave: _saveName,
                        onCancel: () => setState(() => _isEditingName = false),
                      )
                    : GestureDetector(
                        onTap: () => setState(() => _isEditingName = true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.displayName ??
                                  profile.email.split('@').first,
                              style: AppTextStyles.displaySmall.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            const Icon(
                              Icons.edit_rounded,
                              color: AppColors.accent500,
                              size: 16,
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: AppSpacing.s1),
                Text(
                  profile.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textMuted,
                  ),
                ),

                const SizedBox(height: AppSpacing.s2),

                // Verified badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s1,
                  ),
                  decoration: BoxDecoration(
                    color: profile.isVerified
                        ? AppColors.success500.withValues(alpha: 0.1)
                        : AppColors.warning500.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: profile.isVerified
                          ? AppColors.success500.withValues(alpha: 0.3)
                          : AppColors.warning500.withValues(alpha: 0.3),
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
                        profile.isVerified ? 'Verified' : 'Email not verified',
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
                ),
              ],
            ),
          ),
        ),

        // ── Bio section ────────────────────────────────────────
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bio', style: AppTextStyles.headlineMedium),
                    if (!_isEditingBio)
                      TextButton.icon(
                        onPressed: () => setState(() => _isEditingBio = true),
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: AppColors.accent500,
                        ),
                        label: Text(
                          'Edit',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.accent500,
                          ),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s3),

                _isEditingBio
                    ? _EditField(
                        controller: _bioCtrl,
                        hint: 'Tell us about yourself...',
                        maxLines: 4,
                        onSave: _saveBio,
                        onCancel: () => setState(() => _isEditingBio = false),
                      )
                    : GestureDetector(
                        onTap: () => setState(() => _isEditingBio = true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.s4),
                          decoration: BoxDecoration(
                            color: context.bgSurface,
                            borderRadius: AppRadius.lgBorder,
                            border: Border.all(color: context.border),
                          ),
                          child: profile.bio?.isNotEmpty == true
                              ? Text(
                                  profile.bio!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    height: 1.6,
                                  ),
                                )
                              : Text(
                                  'Tap to add a bio...',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: context.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ),
                      ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
        ),

        // ── Language section ───────────────────────────────────
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
                Text('Preferred Language', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.s3),
                Row(
                  children: _languages.map((lang) {
                    final isSelected = profile.preferredLanguage == lang.$1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _saveLanguage(lang.$1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent500.withValues(alpha: 0.12)
                                : context.bgSurface,
                            borderRadius: AppRadius.lgBorder,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent500.withValues(alpha: 0.5)
                                  : context.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                lang.$2,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: AppSpacing.s1),
                              Text(
                                lang.$3,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.accent400
                                      : context.textMuted,
                                  letterSpacing: 0,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ),
        ),

        // ── Account info ───────────────────────────────────────
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
                Text('Account Info', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.s3),
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Member since',
                      value: _formatDate(profile.createdAt),
                    ),
                    _InfoRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Account ID',
                      value: '#${profile.id}',
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ),
        ),

        // ── Action items ───────────────────────────────────────
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
                Text('Security & Privacy', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.s3),
                _InfoCard(
                  children: [
                    _ActionRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      iconColor: AppColors.accent500,
                      onTap: () =>
                          context.push('/change-password'), // ← correct
                    ),
                    _ActionRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      iconColor: AppColors.secondary500,
                      onTap: () => _showNotificationsSheet(),
                    ),
                    _ActionRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      iconColor: AppColors.primary300,
                      onTap: () => _showPrivacyPolicy(),
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
          ),
        ),

        // ── Logout ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s6,
              AppSpacing.s5,
              AppSpacing.s6,
              AppSpacing.s16,
            ),
            child: SizedBox(
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
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                  side: BorderSide(
                    color: AppColors.error400.withValues(alpha: 0.4),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationsSheet(),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PrivacyPolicySheet(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr).toLocal();
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
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ── Edit field ────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _EditField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          autofocus: true,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(hintText: hint),
        ),
        const SizedBox(height: AppSpacing.s3),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.border),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ── Info card / row / action row ──────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.bgSurface,
      borderRadius: AppRadius.xlBorder,
      border: Border.all(color: context.border),
    ),
    child: Column(children: children),
  );
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
                  color: context.bgVariant,
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
            color: context.border,
            indent: AppSpacing.s4,
            endIndent: AppSpacing.s4,
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
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
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
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
            color: context.border,
            indent: AppSpacing.s4,
            endIndent: AppSpacing.s4,
          ),
      ],
    );
  }
}

// ── Image source button ───────────────────────────────────────────
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s5),
        decoration: BoxDecoration(
          color: AppColors.accent500.withValues(alpha: 0.08),
          borderRadius: AppRadius.xlBorder,
          border: Border.all(color: AppColors.accent500.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent500, size: 32),
            const SizedBox(height: AppSpacing.s2),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accent400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notifications sheet ───────────────────────────────────────────
class _NotificationsSheet extends StatefulWidget {
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _practiceReminders = true;
  bool _newSigns = false;
  bool _weeklySummary = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: context.bgSurface,
        borderRadius: AppRadius.xl2Border,
        border: Border.all(color: context.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: AppRadius.fullBorder,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary500.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.secondary500,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Text('Notifications', style: AppTextStyles.headlineMedium),
            ],
          ),

          const SizedBox(height: AppSpacing.s5),

          _NotifToggle(
            label: 'Practice Reminders',
            subtitle: 'Daily reminders to keep your streak',
            value: _practiceReminders,
            onChanged: (v) => setState(() => _practiceReminders = v),
          ),
          const SizedBox(height: AppSpacing.s3),
          _NotifToggle(
            label: 'New Signs Added',
            subtitle: 'When new signs are added to the library',
            value: _newSigns,
            onChanged: (v) => setState(() => _newSigns = v),
          ),
          const SizedBox(height: AppSpacing.s3),
          _NotifToggle(
            label: 'Weekly Summary',
            subtitle: 'Your weekly learning progress report',
            value: _weeklySummary,
            onChanged: (v) => setState(() => _weeklySummary = v),
          ),

          const SizedBox(height: AppSpacing.s5),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              child: const Text('Save Preferences'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _NotifToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
              ),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accent500,
        ),
      ],
    );
  }
}

// ── Privacy policy sheet ──────────────────────────────────────────
class _PrivacyPolicySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.s3,
          right: AppSpacing.s3,
          top: AppSpacing.s3,
        ),
        decoration: BoxDecoration(
          color: context.bgSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl2),
            topRight: Radius.circular(AppRadius.xl2),
          ),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s3),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: AppRadius.fullBorder,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary300.withValues(alpha: 0.1),
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary300,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Text('Privacy Policy', style: AppTextStyles.headlineMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primary300,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.s5),
                children: const [
                  _PolicySection(
                    title: '1. Data We Collect',
                    content:
                        'SignVerse collects your email address, display name, and the ASL landmark data generated during translation sessions. We do not collect raw camera images or video.',
                  ),
                  _PolicySection(
                    title: '2. How We Use Your Data',
                    content:
                        'Your data is used solely to provide the translation service, save your history, and improve model accuracy through anonymized feedback. We do not sell your data to third parties.',
                  ),
                  _PolicySection(
                    title: '3. Data Storage',
                    content:
                        'All data is stored securely on Railway infrastructure using PostgreSQL with encrypted connections. Passwords are hashed using bcrypt and are never stored in plain text.',
                  ),
                  _PolicySection(
                    title: '4. Landmark Data',
                    content:
                        'Hand landmark coordinates submitted as feedback are anonymized before storage. They cannot be used to reconstruct original images.',
                  ),
                  _PolicySection(
                    title: '5. Your Rights',
                    content:
                        'You may request deletion of your account and all associated data at any time by contacting us. Your translation history can be deleted directly from the app.',
                  ),
                  _PolicySection(
                    title: '6. Contact',
                    content:
                        'This app was built as a Projet Fédérateur at Polytech International. For privacy concerns, contact the development team through your institution.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.accent400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.7,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logout dialog ─────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.bgSurface,
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
                color: AppColors.error500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error500.withValues(alpha: 0.3),
                ),
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
              "You'll need to sign in again\nto use SignVerse.",
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textMuted,
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
                      side: BorderSide(color: context.border),
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
