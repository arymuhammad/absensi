import 'dart:math';
import 'package:flutter/material.dart';

class RepeatedWatermark extends StatelessWidget {
  final String text;

  const RepeatedWatermark({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // 🔥 overdraw area BESAR biar sudut aman
          final drawWidth = width * 3;
          final drawHeight = height * 3;

          final cols = (drawWidth / 160).ceil();
          final rows = (drawHeight / 80).ceil();

          return Stack(
            children: [
              /// ================= WATERMARK TEXT =================
              Transform.rotate(
                angle: -0.50,
                child: SizedBox(
                  width: drawWidth,
                  height: drawHeight,
                  child: Stack(
                    children: List.generate(rows * cols, (index) {
                      final row = index ~/ cols;
                      final col = index % cols;

                      final zigZagOffset = row.isEven ? 0.0 : 80.0;

                      return Positioned(
                        left: col * 160.0 + zigZagOffset - drawWidth / 3,
                        top: row * 80.0 - drawHeight / 3,
                        child: Opacity(
                          opacity: 0.025 + random.nextDouble() * 0.05,
                          child: Transform.rotate(
                            angle: (random.nextDouble() - 0.5) * 0.1,
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              /// ================= THERMAL NOISE =================
              Positioned.fill(
                child: CustomPaint(painter: _ThermalNoisePainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThermalNoisePainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.015);

    /// random dots (printer grain)
    for (int i = 0; i < 700; i++) {
      final offset = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawCircle(offset, random.nextDouble() * 0.8, paint);
    }

    /// horizontal scan lines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 0.6),
        Paint()..color = Colors.black.withOpacity(0.01),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
