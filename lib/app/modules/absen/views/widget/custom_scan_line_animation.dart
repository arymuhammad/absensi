import 'package:flutter/material.dart';

class ScanLineAnimation extends StatefulWidget {
  final double width;
  final double height;

  const ScanLineAnimation({super.key, required this.width, required this.height});

  @override
  _ScanLineAnimationState createState() => _ScanLineAnimationState();
}

class _ScanLineAnimationState extends State<ScanLineAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: widget.height - 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScanLinePainter(_animation.value),
          );
        },
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double position;

  _ScanLinePainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gambar garis horizontal naik-turun pada posisi 'position'
    canvas.drawLine(
      Offset(0, position),
      Offset(size.width, position),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
