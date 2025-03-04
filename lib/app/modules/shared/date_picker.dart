import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class CsDatePicker extends StatelessWidget {
  const CsDatePicker(
      {super.key,
      required this.controller,
      required this.editable,
      required this.label});
  final TextEditingController controller;
  final bool editable;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
        controller: controller,
        enabled: editable,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0.5),
            prefixIcon: const Icon(Iconsax.calendar_edit_outline),
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder()),
        format: DateFormat("yyyy-MM-dd"),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        });
  }
}
