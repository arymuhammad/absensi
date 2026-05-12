import 'package:flutter/material.dart';

class CsDropDown extends StatelessWidget {
  const CsDropDown({
    super.key,
    this.items,
    this.selectedItemBuilder,
    this.onChanged,
    this.value,
    required this.label,
    required this.isDark,
  });
  final List<DropdownMenuItem<dynamic>>? items;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final void Function(dynamic)? onChanged;
  final dynamic value;
  final String label;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      items: items,
      onChanged: onChanged,
      value: value,
      selectedItemBuilder: selectedItemBuilder,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8),
        filled: true,
        fillColor: isDark ? Colors.black : Colors.white,
      ),
    );
  }
}
