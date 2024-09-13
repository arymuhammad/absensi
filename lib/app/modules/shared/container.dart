import 'package:flutter/material.dart';

class CsContainer extends StatelessWidget {
  final Color color;
  final String title;
  final Color textColor;
  final double fontSize;
  const CsContainer(
      {super.key,
      required this.color,
      required this.title,
      required this.textColor,
      required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          title,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
    );
  }
}
