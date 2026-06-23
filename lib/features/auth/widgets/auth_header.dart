import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.mdBorder,
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
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
        ),

        const SizedBox(height: AppSpacing.s8),

        Text(title, style: AppTextStyles.displaySmall),
        const SizedBox(height: AppSpacing.s2),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
