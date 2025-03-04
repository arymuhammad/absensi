import 'package:flutter/material.dart';

class CsElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final double fontsize;
  final Size? size;
  final String? label;
  final Color color;
  const CsElevatedButton(
      {super.key,
      this.onPressed,
      this.size,
      this.label,
      required this.color,
      required this.fontsize});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          fixedSize: size),
      onPressed: onPressed,
      child: Text(
        label != "" ? label! : "Save",
        style: TextStyle(fontSize: fontsize),
      ),
    );
  }
}
