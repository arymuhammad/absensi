import 'package:flutter/material.dart';

class CsTextField extends StatelessWidget {
  final String label;
  final Widget? icon;
  final TextEditingController? controller;
  const CsTextField(
      {super.key, required this.label, this.icon, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(border: const OutlineInputBorder(),
        labelText: label,
        suffixIcon: icon,
        contentPadding: const EdgeInsets.all(8)
      ),
      onChanged: (value) {},
    );
  }
}
