import 'package:flutter/material.dart';

class CsDropDown extends StatelessWidget {
  const CsDropDown({super.key, this.items, this.onChanged, this.value, required this.label});
  final List<DropdownMenuItem<dynamic>>? items;
  final void Function(dynamic)? onChanged;
  final dynamic value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      items: items,
      onChanged: onChanged,
      value: value,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(8)),
    );
  }
}
