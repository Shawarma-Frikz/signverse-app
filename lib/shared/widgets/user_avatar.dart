import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fallbackLetter;
  final double size;
  final bool showGlow;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.fallbackLetter,
    this.size = 52,
    this.showGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: avatarUrl == null ? AppGradients.accent : null,
          // 🚨 UPDATED: Use context.glowCyan so the glow automatically
          // disables itself in light mode.
          boxShadow: showGlow ? context.glowCyan : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: avatarUrl != null
            ? _buildImage()
            : Center(
                child: Text(
                  fallbackLetter.toUpperCase(),
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors
                        .white, // White is correct here since it sits on the cyan gradient
                    fontSize: size * 0.4,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildImage() {
    // Base64 data URI from our backend
    if (avatarUrl!.startsWith('data:image')) {
      final b64 = avatarUrl!.split(',').last;
      final bytes = base64Decode(b64);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // Regular URL
    return Image.network(
      avatarUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.accent),
      child: Center(
        child: Text(
          fallbackLetter.toUpperCase(),
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
