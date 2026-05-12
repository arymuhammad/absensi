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
    final data = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Obx(
              () => Row(
                children: [
                  Icon(
                    controller.distanceStore.value > num.parse(data.areaCover!)
                        ? Icons.error
                        : Icons.check_circle,
                    color:
                        controller.distanceStore.value >
                                num.parse(data.areaCover!)
                            ? Colors.red
                            : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.distanceStore.value > num.parse(data.areaCover!)
                        ? "Outside area"
                        : "Inside area",
                    style: titleTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 3),

            /// DISTANCE INFO
            Obx(
              () => Visibility(
                visible:
                    controller.distanceStore.value > num.parse(data.areaCover!),
                child: Column(
                  children: [
                    Text(
                      controller.locNote.value,
                      style: TextStyle(
                        color:
                            controller.distanceStore.value >
                                    num.parse(data.areaCover!)
                                ? red
                                : green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),

            /// REFRESH BUTTON
            Obx(
              () => Visibility(
                visible:
                    controller.distanceStore.value > num.parse(data.areaCover!),
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
              ),
            ),

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
                final enabled =
                    controller.isEnabled.value &&
                    !controller.isTimeUntrusted.value &&
                    !controller.isAppLocked.value;

                return Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.mainGradient(
                      context: context,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(
                          enabled ? 0.4 : 0.2,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SliderButton(
                    backgroundColor: Colors.transparent,
                    buttonSize: 35,
                    buttonColor:
                        enabled ? AppColors.contentColorWhite : Colors.grey,
                    alignLabel: Alignment.center,
                    baseColor: enabled ? AppColors.borderColor : Colors.grey,
                    height: 45,
                    shimmer: enabled,
                    action: () async {
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
