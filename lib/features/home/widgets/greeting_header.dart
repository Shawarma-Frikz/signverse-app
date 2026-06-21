import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GreetingHeader extends StatelessWidget {
  final String name;

  const GreetingHeader({super.key, required this.name});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
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
                      color: AppColors.textMuted,
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
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),

        const SizedBox(width: AppSpacing.s2),

        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            borderRadius: AppRadius.lgBorder,
            boxShadow: AppShadows.glowCyan,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
