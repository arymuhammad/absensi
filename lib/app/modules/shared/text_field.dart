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
       fillColor: Colors.white,
                  filled: true,
                  isDense: true, // 🔑 biar tinggi tetap rapih
                  contentPadding: const EdgeInsets.all(5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
        labelText: label,
        suffixIcon: icon,
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}
