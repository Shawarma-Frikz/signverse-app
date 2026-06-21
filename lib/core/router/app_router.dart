import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/connectivity_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/learning/models/sign_model.dart';
import '../../features/learning/screens/learning_screen.dart';
import '../../features/learning/screens/practice_screen.dart';
import '../../features/learning/screens/sign_detail_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/translation/screens/translation_screen.dart';
import '../../shared/widgets/app_shell.dart';

// ── Router provider — created once, never recreated ───────────────
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter._build(ref);
});

class AppRouter {
  AppRouter._();

  static GoRouter _build(Ref ref) {
    // Use a ChangeNotifier that listens to auth state only —
    // not settings, not connectivity — so only auth changes
    // trigger redirect evaluation.
    final authNotifier = _AuthChangeNotifier(ref);

    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: false,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final connectivity = ref.read(connectivityProvider);
        final isOffline = connectivity == ConnectivityStatus.offline;
        final isAuth = authState.status == AuthStatus.authenticated;
        final isUnknown = authState.status == AuthStatus.unknown;

        final isAuthRoute = const [
          '/login',
          '/register',
          '/forgot-password',
          '/splash',
          '/onboarding',
          '/verify-email',
        ].contains(state.matchedLocation);

        if (isUnknown && !isOffline) return '/splash';

        if (isOffline && isAuthRoute && state.matchedLocation != '/splash') {
          return '/home';
        }

        if (!isAuth && !isAuthRoute && !isOffline) return '/login';

        if (isAuth && isAuthRoute && state.matchedLocation != '/splash') {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (_, __) => const NoTransitionPage(child: SplashScreen()),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        ),
        GoRoute(
          path: '/verify-email',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: VerifyEmailScreen(email: state.extra as String? ?? ''),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          ),
        ),
        GoRoute(
          path: '/learn/practice',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: PracticeScreen(signs: state.extra as List<SignModel>),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          ),
        ),

        // ── Main shell ─────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (_, __, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (_, __) =>
                      const NoTransitionPage(child: HomeScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/translate',
                  pageBuilder: (_, __) =>
                      const NoTransitionPage(child: TranslationScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  pageBuilder: (_, __) =>
                      const NoTransitionPage(child: HistoryScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/learn',
                  pageBuilder: (_, __) =>
                      const NoTransitionPage(child: LearningScreen()),
                  routes: [
                    GoRoute(
                      path: ':signId',
                      pageBuilder: (_, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: SignDetailScreen(
                          signId: state.pathParameters['signId']!,
                        ),
                        transitionsBuilder: (_, animation, __, child) =>
                            SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  pageBuilder: (_, __) =>
                      const NoTransitionPage(child: SettingsScreen()),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ── Auth change notifier ──────────────────────────────────────────
// Only notifies when AUTH state changes — not settings, not anything else.
// This is the key fix: previously the notifier watched the whole ref
// which caused any provider change to rebuild the router.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }
}
