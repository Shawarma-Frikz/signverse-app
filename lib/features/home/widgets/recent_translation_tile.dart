import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RecentTranslationTile extends StatelessWidget {
  final String sign;
  final String translation;
  final String time;
  final double confidence;

  const RecentTranslationTile({
    super.key,
    required this.sign,
    required this.translation,
    required this.time,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.primary400.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent500.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: AppColors.accent500.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(
                sign[0].toUpperCase(),
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.accent500,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translation, style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.s1),
                Row(
                  children: [
                    Text(time, style: AppTextStyles.bodySmall),
                    const SizedBox(width: AppSpacing.s2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success500.withValues(alpha: 0.1),
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Text(
                        '${(confidence * 100).toInt()}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success400,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary300,
            size: 18,
          ),
        ],
      ),
    );
  }
}
