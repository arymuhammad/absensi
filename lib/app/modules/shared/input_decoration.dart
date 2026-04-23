import 'package:flutter/material.dart';

InputDecoration inputDecoration({
  required String label,
  String? hint,
  IconData? prefixIcon,
  IconData? suffixIcon,
  Function()? onPressed,
  required bool isDark,
  required BuildContext context, 
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    fillColor: isDark? Theme.of(context).canvasColor: Colors.white,
    filled: true,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12, // 🔑 ini kunci tinggi stabil
    ),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 15) : null,
    suffix:
        suffixIcon != null
            ? IconButton(onPressed: onPressed, icon: Icon(suffixIcon, size: 15))
            : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: isDark
                            ? BorderSide(color: Colors.white.withOpacity(0.15))
                            : BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:isDark
                            ? BorderSide(color: Colors.white.withOpacity(0.15))
                            : BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   isDark
                            ? const BorderSide(
                              color:
                                  Colors
                                      .blueAccent, // 🔥 biar ada feedback focus
                              width: 1.2,
                            )
                            : BorderSide.none,
    ),
  );
}
