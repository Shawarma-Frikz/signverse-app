import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.primary400.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s2,
            vertical: AppSpacing.s2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                currentIndex: navigationShell.currentIndex,
                onTap: () => _onTap(0),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                index: 2,
                currentIndex: navigationShell.currentIndex,
                onTap: () => _onTap(2),
              ),
              _CenterNavItem(
                onTap: () => _onTap(1),
                isActive: navigationShell.currentIndex == 1,
              ),
              _NavItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school,
                label: 'Learn',
                index: 3,
                currentIndex: navigationShell.currentIndex,
                onTap: () => _onTap(3),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                index: 4,
                currentIndex: navigationShell.currentIndex,
                onTap: () => _onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

// ── Regular nav item ──────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s3,
                vertical: AppSpacing.s1,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent500.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: AppRadius.fullBorder,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.accent500 : AppColors.primary300,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.s1),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.accent500 : AppColors.primary300,
                letterSpacing: 0,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Center translate button ───────────────────────────────────────
class _CenterNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const _CenterNavItem({required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: AppRadius.lgBorder,
          boxShadow: isActive ? AppShadows.glowCyan : AppShadows.md,
        ),
        child: const Icon(
          Icons.sign_language,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }
}
