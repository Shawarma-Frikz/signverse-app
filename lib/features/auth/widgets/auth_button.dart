import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppGradients.accent
              : LinearGradient(
                  colors: [
                    AppColors.primary400.withOpacity(0.5),
                    AppColors.primary400.withOpacity(0.5),
                  ],
                ),
          borderRadius: AppRadius.lgBorder,
          boxShadow: onPressed != null ? AppShadows.glowCyan : [],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.lgBorder,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.white, size: 20),
                      const SizedBox(width: AppSpacing.s2),
                    ],
                    Text(label, style: AppTextStyles.buttonLabel),
                  ],
                ),
        ),
      ),
    );
  }
}
