import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CsBgImgHeader extends StatelessWidget {
  final double? height;
  const CsBgImgHeader({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipPathClass(),
      child: Transform.flip(
        flipX: false,
        flipY: true,
        child: Container(
          height: height,
          width: Get.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/image/new_bg_app.jpg'), fit: BoxFit.fitHeight, )),
        ),
      ),
    );
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 60);

    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 60);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
