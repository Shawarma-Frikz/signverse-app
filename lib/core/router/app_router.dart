import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/translation/screens/translation_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/learning/screens/learning_screen.dart';
import '../../features/learning/screens/sign_detail_screen.dart';
import '../../features/learning/screens/practice_screen.dart';
import '../../features/learning/models/sign_model.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';

// ── Router provider — created once, never recreated ───────────────
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter._build(ref);
});

class AppRouter {
  AppRouter._();

  static GoRouter _build(Ref ref) {
    // Use a ChangeNotifier that listens to auth state smartly.
    // It ignores background refreshes so the router doesn't flash to /splash.
    final authNotifier = _AuthChangeNotifier(ref);

    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isAuth = authState.status == AuthStatus.authenticated;
        final isUnknown = authState.status == AuthStatus.unknown;

        final isOnAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/splash' ||
            state.matchedLocation == '/onboarding';

        // Still checking auth — stay on splash
        if (isUnknown) return '/splash';

        // Not logged in and trying to access protected route
        if (!isAuth && !isOnAuthRoute) return '/login';

        // Logged in and trying to access auth routes
        if (isAuth && isOnAuthRoute && state.matchedLocation != '/splash') {
          return '/home';
        }

        return null;
      },
      routes: [
        // Splash
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SplashScreen()),
        ),

        // Onboarding
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        ),

        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondary, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),

        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RegisterScreen(),
            transitionsBuilder: (context, animation, secondary, child) =>
                SlideTransition(
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
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ForgotPasswordScreen(),
            transitionsBuilder: (context, animation, secondary, child) =>
                SlideTransition(
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
          pageBuilder: (context, state) {
            final email = state.extra as String? ?? '';
            return CustomTransitionPage(
              child: VerifyEmailScreen(email: email),
              transitionsBuilder: (context, animation, secondary, child) =>
                  FadeTransition(opacity: animation, child: child),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ProfileScreen(),
            transitionsBuilder: (context, animation, secondary, child) =>
                SlideTransition(
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
          path: '/change-password',
          pageBuilder: (_, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ChangePasswordScreen(),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
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

        // Main shell with bottom navigation
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: HomeScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/translate',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: TranslationScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: HistoryScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/learn',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: LearningScreen()),
                  routes: [
                    GoRoute(
                      path: ':signId',
                      pageBuilder: (context, state) => CustomTransitionPage(
                        child: SignDetailScreen(
                          signId: state.pathParameters['signId']!,
                        ),
                        transitionsBuilder:
                            (context, animation, secondary, child) =>
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
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: SettingsScreen()),
                ),
              ],
            ),
          ],
        ),

        GoRoute(
          path: '/learn/practice',
          pageBuilder: (context, state) {
            final signs = state.extra as List<SignModel>;
            return CustomTransitionPage(
              child: PracticeScreen(signs: signs),
              transitionsBuilder: (context, animation, secondary, child) =>
                  SlideTransition(
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
            );
          },
        ),
      ],
    );
  }
}

// ── Auth change notifier ──────────────────────────────────────────
// Prevents the router from reloading/flashing to /splash when settings
// changes trigger a background refresh of the authProvider.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      // 🚨 THE FIX: Prevent router reload during background auth refreshes.
      // If settings change and invalidate authProvider, it temporarily
      // becomes 'unknown' (loading). If we already have a user, this is
      // just a background refresh, not a logout. We ignore it so the
      // router doesn't flash to /splash.
      if (next.status == AuthStatus.unknown && previous?.user != null) {
        return;
      }

      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }
}
