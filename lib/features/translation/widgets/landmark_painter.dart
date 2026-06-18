import 'package:flutter/material.dart';
import 'package:hand_detection/hand_detection.dart';
import '../../../core/theme/app_theme.dart';

class LandmarkPainter extends CustomPainter {
  final List<Hand> hands;
  final Size imageSize;

  LandmarkPainter({required this.hands, required this.imageSize});

  static const fingertips = {4, 8, 12, 16, 20};

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final linePaint = Paint()
      ..color = AppColors.accent400.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()..color = AppColors.white;
    final tipPaint = Paint()..color = AppColors.accent300;
    final glowPaint = Paint()
      ..color = AppColors.accent500.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (final hand in hands) {
      // TEMP DEBUG — remove after verifying
      debugPrint(
        'Landmark types: ${hand.landmarks.map((l) => l.type.name).toList()}',
      );

      // Build a lookup by landmark type instead of relying on list order
      final byType = <HandLandmarkType, Offset>{};
      for (final lm in hand.landmarks) {
        byType[lm.type] = Offset(lm.x * scaleX, lm.y * scaleY);
      }

      // Skeleton connections
      for (final c in handLandmarkConnections) {
        final start = byType[c[0]];
        final end = byType[c[1]];
        if (start != null && end != null) {
          canvas.drawLine(start, end, linePaint);
        }
      }

      // Joints + fingertip glow
      for (final lm in hand.landmarks) {
        final point = byType[lm.type]!;
        final isTip = fingertips.contains(lm.type.index);
        if (isTip) {
          canvas.drawCircle(point, 10, glowPaint);
          canvas.drawCircle(point, 5, tipPaint);
        } else {
          canvas.drawCircle(point, 3.5, jointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LandmarkPainter old) =>
      old.hands != hands || old.imageSize != imageSize;
}
