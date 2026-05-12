import 'package:flutter/material.dart';

class CsTextField extends StatelessWidget {
  final bool enabled;
  final String label;
  final String? hint;
  final Widget? icon;
  final int? maxLines;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isDark;
  const CsTextField({
    super.key,
   required this.enabled,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.maxLines,
    this.onChanged,
    this.keyboardType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        fillColor: isDark ? Theme.of(context).cardColor : Colors.white,
        filled: true,
        // isDense: true, // 🔑 biar tinggi tetap rapih
        contentPadding: const EdgeInsets.all(5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          // borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          // borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          // borderSide: BorderSide.none,
        ),
        labelText: label,
        hintText: hint ?? '',
        prefixIcon: icon,
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}
