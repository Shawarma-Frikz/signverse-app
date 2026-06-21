import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../settings/screens/profile_screen.dart';

class GreetingHeader extends ConsumerWidget {
  final String name;
  const GreetingHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch profile for avatar updates
    final profile = ref.watch(profileProvider).valueOrNull;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s1),
                  const Text('👋', style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                name,
                style: AppTextStyles.displaySmall.copyWith(fontSize: 26),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Notification bell
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.bgSurface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: context.border),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.primary300,
            size: 20,
          ),
        ),

        const SizedBox(width: AppSpacing.s2),

        // Avatar — synced from profile
        UserAvatar(
          avatarUrl: profile?.avatarUrl,
          fallbackLetter: name.isNotEmpty ? name[0] : 'S',
          size: 44,
          showGlow: true,
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
