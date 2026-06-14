import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/translation/screens/translation_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/learning/screens/learning_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),

          // Tab 1 — Translation (center)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/translate',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TranslationScreen()),
              ),
            ],
          ),

          // Tab 2 — History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HistoryScreen()),
              ),
            ],
          ),

          // Tab 3 — Learning
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LearningScreen()),
              ),
            ],
          ),

          // Tab 4 — Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
