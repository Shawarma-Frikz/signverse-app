import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Translation',
          style: TextStyle(color: AppColors.accent500, fontSize: 24),
        ),
      ),
    );
  }
}
