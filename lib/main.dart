import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  await ConnectivityService.instance.initialize();
  runApp(const ProviderScope(child: SignVerseApp()));
}

class SignVerseApp extends ConsumerWidget {
  const SignVerseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch ONLY theme — the smallest possible slice of state.
    // This widget only rebuilds when the theme integer changes (0/1/2).
    // It does NOT watch the router, auth, connectivity, or anything else.
    final themeMode = switch (ref.watch(
      settingsProvider.select((s) => s.themeMode),
    )) {
      1 => ThemeMode.light,
      2 => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    // Router is read, not watched — it never causes a rebuild here.
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      title: 'SignVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
