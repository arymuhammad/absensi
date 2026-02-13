import 'package:flutter/material.dart';

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 6;      // ukuran sobekan
    const double gap = 6;         // garis datar antar sobekan

    final path = Path();

    /// ================= TOP =================
    path.moveTo(0, radius);

    double x = 0;
    while (x < size.width) {
      // setengah lingkaran (cekungan)
      path.arcToPoint(
        Offset(x + radius * 2, radius),
        radius: Radius.circular(radius),
        clockwise: false,
      );

      x += radius * 2;

      // garis datar penghubung
      path.lineTo(
        (x + gap).clamp(0, size.width),
        radius,
      );

      x += gap;
    }

    /// ================= RIGHT =================
    path.lineTo(size.width, size.height - radius);

    /// ================= BOTTOM =================
    x = size.width;
    while (x > 0) {
      path.arcToPoint(
        Offset(x - radius * 2, size.height - radius),
        radius: Radius.circular(radius),
        clockwise: false,
      );

      x -= radius * 2;

      path.lineTo(
        (x - gap).clamp(0, size.width),
        size.height - radius,
      );

      x -= gap;
    }

    /// ================= LEFT =================
    path.lineTo(0, radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
