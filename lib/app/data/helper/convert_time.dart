import 'package:intl/intl.dart';

extension Time12hExt on String? {
  String? to24Hour() {
    if (this == null || this!.isEmpty) return null;
    try {
      return DateFormat('HH:mm')
          .format(DateFormat('hh:mm a').parse(this!));
    } catch (_) {
      return this;
    }
  }
}
