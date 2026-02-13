import 'package:flutter/material.dart';

import '../../data/helper/const.dart';

class HistoryCard extends StatelessWidget {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String duration;
  final String location;
  final String stsM;
  final String stsP;
  final bool isValid;

  const HistoryCard({
    super.key,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.duration,
    required this.location,
    required this.stsM,
    required this.stsP,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.16).clamp(52.0, 70.0);
    final smallScreen = screenWidth < 360;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ================= DATE BOX =================
          Container(
            width: boxWidth,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _monthName(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: smallScreen ? 11 : 13,
                    color: Colors.white70,
                  ),
                ),
                // const SizedBox(height: 1),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: smallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // const SizedBox(height: 1),
                Text(
                  _dayName(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: smallScreen ? 11 : 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // ================= CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATUS + TIME
                  Row(
                    children: [
                      // Icon(
                      //   isValid ? Icons.check_circle : Icons.error,
                      //   size: 18,
                      //   color: isValid ? Colors.green : Colors.red,
                      // ),
                      // const SizedBox(width: 6),
                      _timeColumn(
                        checkIn,
                        'Check In',
                        stsM == "Late" ? red! : green!,
                      ),
                      _divider(),
                      _timeColumn(
                        checkOut,
                        'Check Out',
                        stsP == "Early" || stsP == "Absent"
                            ? red!
                            : stsP == "Over Time"
                            ? blue!
                            : green!,
                      ),
                      _divider(),
                      _timeColumn(
                        duration,
                        'Total Hours',
                        Colors.black87,
                        bold: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // LOCATION
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  static Widget _divider() {
    return Container(
      height: 28,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }

  static Widget _timeColumn(
    String time,
    String label,
    Color color, {
    bool bold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  static String _dayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  static String _monthName(DateTime date) {
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
}
