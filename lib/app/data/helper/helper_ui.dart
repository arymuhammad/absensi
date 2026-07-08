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

IconData getIcon(String name) {
  switch (name) {
    case 'folder_shared':
      return Icons.folder_shared;

    case 'health_and_safety_rounded':
      return Icons.health_and_safety_rounded;

    case 'notifications':
      return Icons.notifications;

    case 'bug_report':
      return Icons.bug_report;

    case 'sync':
      return Icons.sync;

    case 'map':
      return Icons.map;

    case 'access_time_sharp':
      return Icons.access_time_sharp;

    case 'groups_sharp':
      return Icons.groups_sharp;

    case 'leave_bags_at_home_sharp':
      return Icons.leave_bags_at_home_sharp;

    case 'assignment_ind_outlined':
      return Icons.assignment_ind_outlined;

    case 'brightness_6':
      return Icons.brightness_6;

    case 'wifi_off_outlined':
      return Icons.wifi_off_outlined;

    case 'info_outlined':
      return Icons.info_outlined;

    case 'content_paste':
      return Icons.content_paste;

    case 'data_saver_off_sharp':
      return Icons.data_saver_off_sharp;

    case 'receipt_long':
      return Icons.receipt_long;

    case 'timer_sharp':
      return Icons.timer_sharp;

    case 'assignment_ind_rounded':
      return Icons.assignment_ind_rounded;

    case 'refresh_rounded':
      return Icons.refresh_rounded;

    case 'draw_rounded':
      return Icons.draw_rounded;

    case 'history':
      return Icons.history;

    case 'upload_file':
      return Icons.upload_file;

    case 'warning_rounded':
      return Icons.warning_rounded;

    default:
      return Icons.info;
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
