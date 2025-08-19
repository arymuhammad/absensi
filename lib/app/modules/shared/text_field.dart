import 'package:flutter/material.dart';

class CsTextField extends StatelessWidget {
  final String label;
  final Widget? icon;
  final int? maxLines;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  const CsTextField({
    super.key,
    required this.label,
    this.icon,
    this.controller,
    this.maxLines,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        suffixIcon: icon,
        contentPadding: const EdgeInsets.all(8),
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}
