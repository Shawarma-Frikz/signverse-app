import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_theme.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider);
    final isOffline = status == ConnectivityStatus.offline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? 36 : 0,
      child: isOffline
          ? Container(
              color: AppColors.warning600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.white,
                    size: 14,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Text(
                    'No internet connection',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms)
          : const SizedBox.shrink(),
    );
  }
}
