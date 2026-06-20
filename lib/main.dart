import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';

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
    return MaterialApp.router(
      title: 'SignVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.createRouter(ref),
    );
  }
}
