import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Learning',
          style: TextStyle(color: AppColors.accent500, fontSize: 24),
        ),
      ),
    );
  }
}
