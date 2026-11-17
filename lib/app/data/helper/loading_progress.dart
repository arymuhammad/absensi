import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialog extends GetView<AbsenController> {
  const LoadingDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor:
          isDark
              ? const Color(0xFF1E293B).withOpacity(0.78)
              : Colors.white.withOpacity(0.82),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// Progress bar
            Obx(
              () => LinearProgressIndicator(
                value: controller.progress.value,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                valueColor: AlwaysStoppedAnimation(
                  controller.progressColor.value,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Countdown
            Obx(
              () => Text(
                "Time out in ${controller.secondsLeft.value} second",
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
