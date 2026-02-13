import 'package:flutter/material.dart';

InputDecoration inputDecoration({
  required String label,
  String? hint,
  IconData? prefixIcon,
  IconData? suffixIcon,
  Function()? onPressed,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    fillColor: Colors.white,
    filled: true,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12, // 🔑 ini kunci tinggi stabil
    ),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
    suffix:
        suffixIcon != null
            ? IconButton(onPressed: onPressed, icon: Icon(suffixIcon, size: 18))
            : null,
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
  );
}
