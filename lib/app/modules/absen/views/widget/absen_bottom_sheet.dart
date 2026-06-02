import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slider_button/slider_button.dart';
import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../login/controllers/login_controller.dart';
import '../../controllers/absen_controller.dart';
import 'absen_form.dart';
import 'visit_form.dart';
import 'package:icons_plus/icons_plus.dart';

class AbsenBottomSheet extends StatelessWidget {
  AbsenBottomSheet({
    super.key,

    required this.controller,
    required this.scrollController,
  });

  final auth = Get.find<LoginController>();
  final AbsenController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = auth.logUser.value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.blueGrey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DRAG HANDLE
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            /// STATUS
            Obx(() {
              final data = auth.logUser.value;

              final isOutside =
                  controller.distanceStore.value > num.parse(data.areaCover!);

              final bypass = controller.canBypassArea(data);
              // final isRnD =
              //     controller.optVisitSelected.value ==
              //     "Research and Development";
              return Row(
                children: [
                  Icon(
                    isOutside && !bypass ? Icons.error : Icons.check_circle,
                    color: (isOutside && !bypass) ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (isOutside && !bypass) ? "Outside area" : "Inside area",
                    style: titleTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }),

            const SizedBox(height: 3),

            /// DISTANCE INFO
            Obx(() {
              final data = auth.logUser.value;

              final isOutside =
                  controller.distanceStore.value > num.parse(data.areaCover!);

              final bypass = controller.canBypassArea(data);
              // final isRnD =
              //     controller.optVisitSelected.value ==
              //     "Research and Development";

              return Visibility(
                visible: isOutside && !bypass,
                child: Column(
                  children: [
                    Text(
                      controller.locNote.value,
                      style: TextStyle(
                        color: (isOutside && !bypass) ? red : green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              );
            }),

            /// REFRESH BUTTON
            Obx(() {
              final data = auth.logUser.value;
              final isOutside =
                  controller.distanceStore.value > num.parse(data.areaCover!);

              final bypass = controller.canBypassArea(data);
              // final isRnD =
              //     controller.optVisitSelected.value ==
              //     "Research and Development";
              return Visibility(
                visible: isOutside && !bypass,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // loadingDialog('verify your location', '');
                          await controller.getLoc(data);
                          // Get.back();
                        },
                        child: const Text("Refresh Lokasi"),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 5),

            /// FORM
            data.visit == "1"
                ? buildVisit(
                  context: context,
                  data: data,
                  controller: controller,
                  isDark: isDark,
                )
                : buildAbsen(
                  context: context,
                  isDark: isDark,
                  data: data,
                  controller: controller,
                ),

            const SizedBox(height: 10),

            /// SLIDER BUTTON
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(() {
                final bypass = controller.canBypassArea(data);

                // final canBypassArea =
                //     controller.optVisitSelected.value ==
                //     "Research and Development";
                final isOutside =
                    controller.distanceStore.value > num.parse(data.areaCover!);

                final locationValid =
                    bypass
                        ? controller.isEnabled.value
                        : (!isOutside && controller.isEnabled.value);
                final enabled =
                    locationValid &&
                    !controller.isTimeUntrusted.value &&
                    !controller.isAppLocked.value;

//                 print('''
// distanceStore : ${controller.distanceStore.value}
// areaCover     : ${data.areaCover}
// isQrValidated : ${controller.isQrValidated.value}
// isEnabled     : ${controller.isEnabled.value}
// bypass        : $bypass
// isOutside     : $isOutside
// locationValid : $locationValid
// enabled       : $enabled
// ''');

                return Container(
                  decoration: BoxDecoration(
                    gradient:
                        enabled
                            ? AppColors.mainGradient(
                              context: context,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : LinearGradient(
                              colors: [
                                Colors.grey.shade500,
                                Colors.grey.shade600,
                              ],
                            ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color:
                            enabled
                                ? Colors.blueAccent.withOpacity(0.4)
                                : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IgnorePointer(
                    ignoring: !enabled,
                    child: SliderButton(
                      backgroundColor: Colors.transparent,
                      buttonSize: 35,
                      buttonColor:
                          enabled
                              ? AppColors.contentColorWhite
                              : Colors.grey.shade400,
                      alignLabel: Alignment.center,
                      baseColor:
                          enabled
                              ? AppColors.borderColor
                              : Colors.grey.shade700,
                      height: 45,
                      shimmer: enabled,
                      action: () async {
                        /// BLOCK ACTION
                        // if (!enabled) {
                        //   if (controller.distanceStore.value >
                        //       num.parse(data.areaCover!)) {
                        //     showToast(
                        //       "Outside area (${(controller.distanceStore.value / 1000).toStringAsFixed(2)} Km)",
                        //     );
                        //   } else if (controller.isTimeUntrusted.value) {
                        //     showToast("Invalid device time");
                        //   } else if (controller.isAppLocked.value) {
                        //     showToast("Application locked");
                        //   } else {
                        //     showToast("Unable to continue");
                        //   }

                        //   return false;
                        // }

                        final result = await controller.executeAction(data);

                        if (!result.success) {
                          showToast(result.message);
                          return false;
                        }

                        showToast(result.message); // optional success message
                        return false;
                      },
                      label: Text(
                        data.visit == "1"
                            ? 'Swipe to Visit'
                            : 'Swipe to ${controller.stsAbsenSelected.value}',
                        style: const TextStyle(
                          color: AppColors.contentColorWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      icon: Icon(
                        controller.stsAbsenSelected.value.contains("Break")
                            ? Iconsax.coffee_bold
                            : Icons.double_arrow_rounded,
                        color: AppColors.itemsBackground,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
