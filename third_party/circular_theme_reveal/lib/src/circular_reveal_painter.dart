import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularRevealPainter extends CustomPainter {
  CircularRevealPainter({
    required this.image,
    required this.center,
    required this.progress,
    required this.isReverse,
  });

  final ui.Image image;
  final Offset center;
  final double progress;
  final bool isReverse;

  @override
  void paint(Canvas canvas, Size size) {
    final double maxRadius = _calculateMaxRadius(center, size);
    final double currentRadius = maxRadius * progress;
    final Rect imageRect = Offset.zero & size;

    if (isReverse) {
      // DARK → LIGHT:
      // Snapshot gelap hanya digambar di dalam lingkaran.
      // Lingkaran mengecil dari penuh menjadi hilang.
      canvas.save();

      canvas.clipPath(
        Path()
          ..addOval(
            Rect.fromCircle(
              center: center,
              radius: currentRadius,
            ),
          ),
      );

      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: image,
        fit: BoxFit.cover,
      );

      canvas.restore();
    } else {
      // LIGHT → DARK:
      // Snapshot terang menutupi layar.
      // Lingkaran transparan membesar memperlihatkan tema gelap.
      canvas.saveLayer(imageRect, Paint());

      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: image,
        fit: BoxFit.cover,
      );

      final Paint clearPaint = Paint()
        ..blendMode = BlendMode.dstOut
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, currentRadius, clearPaint);

      canvas.restore();
    }
  }

  double _calculateMaxRadius(Offset center, Size size) {
    final corners = [
      center.distance,
      (center - Offset(size.width, 0)).distance,
      (center - Offset(0, size.height)).distance,
      (center - Offset(size.width, size.height)).distance,
    ];

    return corners.reduce(math.max);
  }

  @override
  bool shouldRepaint(CircularRevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.image != image ||
        oldDelegate.center != center ||
        oldDelegate.isReverse != isReverse;
  }
}
