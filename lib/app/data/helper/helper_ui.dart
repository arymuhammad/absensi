import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'approved':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData getStatusIcon(String status) {
  switch (status) {
    case 'approved':
      return Icons.check_circle;
    case 'pending':
      return Icons.access_time;
    case 'rejected':
      return Icons.cancel;
    default:
      return Icons.help;
  }
}

String getDuration(String start, String end) {
  try {
    final s = start.split(':');
    final e = end.split(':');

    final startTime = DateTime(0, 0, 0, int.parse(s[0]), int.parse(s[1]));
    final endTime = DateTime(0, 0, 0, int.parse(e[0]), int.parse(e[1]));

    final diff = endTime.difference(startTime);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    return '${hours}j ${minutes}m';
  } catch (_) {
    return '-';
  }
}


  String dayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String monthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (date.month < 1 || date.month > 12) return '';
    return months[date.month - 1];
  }