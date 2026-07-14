import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget calendarBadge({required DateTime startDate, required DateTime endDate}) {
  final isSameDate =
      startDate.year == endDate.year &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day;

  Widget buildItem(DateTime date) {
    return Container(
      width: 27,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
            child: Text(
              DateFormat('MMM').format(date).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${date.day}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (isSameDate) {
    return buildItem(startDate);
  }

  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildItem(startDate),
        const SizedBox(width: 4),
        buildItem(endDate),
      ],
    ),
  );
}
