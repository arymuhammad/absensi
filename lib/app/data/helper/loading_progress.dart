import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialog extends GetView<AbsenController> {
  const LoadingDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
             title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            /// Progress bar
           Obx(() => LinearProgressIndicator(
      value: controller.progress.value,
      minHeight: 8,
      borderRadius: BorderRadius.circular(8),
      valueColor: AlwaysStoppedAnimation(
        controller.progressColor.value,
      ),
)),


            const SizedBox(height: 16),

            /// Countdown
            Obx(() => Text(
                  "Time out in ${controller.secondsLeft.value} second",
                  style: const TextStyle(fontSize: 13),
                )),
          ],
        ),
      ),
    );
  }
}
