import 'package:flutter/material.dart';

var backgroundColor = const Color.fromARGB(255, 209, 213, 219);
var mainColor = Colors.blue;
var titleColor = const Color.fromARGB(255, 20, 30, 90);
var subTitleColor = Colors.grey[600];
var timeColor = Colors.blueAccent[700];
var defaultColor = Colors.black;
var bgContainer = Colors.blue[50];
var red = Colors.redAccent[700];

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
