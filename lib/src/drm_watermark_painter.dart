import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'drm_watermark_config.dart';

/// High-performance [CustomPainter] that renders a hardware-accelerated,
/// rotatable forensic watermark grid across any canvas or video surface.
class DrmWatermarkPainter extends CustomPainter {
  /// Configuration specifying typography, opacity, rotation angle, and spacing.
  final DrmWatermarkConfig config;

  /// Formatted watermark text string to render repeatedly.
  final String text;

  /// Creates an instance of [DrmWatermarkPainter].
  DrmWatermarkPainter({
    required this.config,
    required this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || text.isEmpty) return;

    final baseColor = config.textStyle.color ?? Colors.white;
    final effectiveOpacity = (baseColor.a * config.opacity).clamp(0.0, 1.0);

    final textSpan = TextSpan(
      text: text,
      style: config.textStyle.copyWith(
        color: baseColor.withValues(alpha: effectiveOpacity),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    if (textWidth <= 0 || textHeight <= 0) return;

    final cellWidth = textWidth + config.horizontalSpacing;
    final cellHeight = textHeight + config.verticalSpacing;

    // Radius of circumscribed circle guarantees complete screen coverage under any rotation
    final radius = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    final cols = (radius * 2 / cellWidth).ceil() + 2;
    final rows = (radius * 2 / cellHeight).ceil() + 2;

    final startX = -cols * cellWidth / 2;
    final startY = -rows * cellHeight / 2;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(config.angle);

    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        final x = startX + c * cellWidth;
        final y = startY + r * cellHeight;
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrmWatermarkPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.config != config;
  }
}
