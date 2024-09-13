import 'package:flutter/material.dart';

class CsElevatedButtonIcon extends StatelessWidget {
  final void Function()? onPressed;
  final Widget icon;
  final Size? size;
  final String? label;
  final double fontSize;
  const CsElevatedButtonIcon(
      {super.key,
      this.onPressed,
      required this.icon,
      this.size,
      this.label,
      required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          fixedSize: size),
      onPressed: onPressed,
      label: Text(
        label != "" ? label! : "Save",
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
