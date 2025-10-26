import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// 타임라인 배경을 그리는 CustomPainter
class TimelinePainter extends CustomPainter {
  final double hourHeight;
  final double timelineWidth;
  final BuildContext context;

  TimelinePainter({
    required this.hourHeight,
    required this.timelineWidth,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primaryBrown.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..color = AppColors.primaryBrown.withValues(alpha: 0.4);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const textStyle = TextStyle(
      color: AppColors.primaryBrown,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i < 24; i++) {
      final y = i * hourHeight;

      // Draw hour label (00, 01, ...)
      textPainter.text = TextSpan(
        text: i.toString().padLeft(2, '0'),
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (timelineWidth - textPainter.width) / 2,
          y - (textPainter.height / 2),
        ),
      );

      // Draw horizontal line for the hour
      canvas.drawLine(
        Offset(timelineWidth, y),
        Offset(size.width, y),
        linePaint,
      );

      // Draw dot for the half-hour
      final yHalf = y + hourHeight / 2;
      canvas.drawCircle(
        Offset(timelineWidth, yHalf),
        2.0,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.hourHeight != hourHeight ||
        oldDelegate.timelineWidth != timelineWidth ||
        oldDelegate.context != context;
  }
}
