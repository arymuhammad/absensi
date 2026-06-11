import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/helper/app_colors.dart';
import '../../data/helper/const.dart';
import '../../data/helper/helper_ui.dart';

class HistoryCard extends StatelessWidget {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String duration;
  final String location;
  final String stsM;
  final String stsP;
  final bool isValid;
  final bool isLocal;
  final String statusSync;

  const HistoryCard({
    super.key,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.duration,
    required this.location,
    required this.stsM,
    required this.stsP,
    required this.statusSync,
    this.isValid = true,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.16).clamp(52.0, 70.0);
    final smallScreen = screenWidth < 360;
    final hasSyncStatus =
        isLocal && statusSync.isNotEmpty && statusSync != "SUCCESS";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            height: hasSyncStatus ? 102 : 82,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              // color: Color(0xFF1E293B),
              gradient: AppColors.mainGradient(
                context: context,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  monthName(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: smallScreen ? 11 : 13,
                    color: Colors.white,
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
                  dayName(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: smallScreen ? 11 : 13,
                    color: Colors.white,
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
                  // /// ================= LOCAL BADGE =================
                  // if (isLocalData)
                  //   Container(
                  //     margin: const EdgeInsets.only(bottom: 8),
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 10,
                  //       vertical: 4,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.orange.withOpacity(.15),
                  //       borderRadius: BorderRadius.circular(20),
                  //       border: Border.all(
                  //         color: Colors.orange.withOpacity(.5),
                  //       ),
                  //     ),
                  //     child: const Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(
                  //           Icons.cloud_off_rounded,
                  //           size: 14,
                  //           color: Colors.orange,
                  //         ),
                  //         SizedBox(width: 4),
                  //         Text(
                  //           'Local Data',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w600,
                  //             color: Colors.orange,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),

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
                        context,
                        checkIn,
                        'Check In',
                        stsM == "Late" ? red! : green!,
                      ),
                      _divider(),
                      _timeColumn(
                        context,
                        checkOut,
                        'Check Out',
                        stsP == "Minus Time" || stsP == "Absent"
                            ? red!
                            : stsP == "Overtime"
                            ? blue!
                            : green!,
                      ),
                      _divider(),
                      _timeColumn(
                        context,
                        duration,
                        'Total Hours',
                        Colors.black87,
                        bold: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),
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
                          location.capitalize!,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors
                                        .white70 // 🌙 dark → terang
                                    : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (isLocal &&
                      statusSync.isNotEmpty &&
                      statusSync != "SUCCESS")
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _syncStatusBadge(statusSync),
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
    BuildContext context,
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
            color:
                Theme.of(context).brightness == Brightness.dark &&
                        label == 'Total Hours'
                    ? Colors
                        .white70 // 🌙 dark → terang
                    : color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  static Widget _syncStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toUpperCase()) {
      case "PENDING":
        color = Colors.orange;
        text = "Pending Sync";
        break;

      case "FAILED":
        color = Colors.red;
        text = "Failed Sync";
        break;

      case "SUCCESS":
        color = Colors.green;
        text = "Synced";
        break;

      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   width: 8,
          //   height: 8,
          //   decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          // ),
          Icon(
            status == "SUCCESS"
                ? Icons.cloud_done_rounded
                : status == "FAILED"
                ? Icons.cloud_off_rounded
                : Icons.cloud_sync_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
