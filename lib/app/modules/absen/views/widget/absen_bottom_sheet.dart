import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slider_button/slider_button.dart';
import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/model/login_model.dart';
import '../../controllers/absen_controller.dart';
import 'absen_form.dart';
import 'check_in.dart';
import 'check_out.dart';
import 'visit_form.dart';
import 'visit_in.dart';
import 'visit_out.dart';
import 'package:icons_plus/icons_plus.dart';

class AbsenBottomSheet extends StatelessWidget {
  const AbsenBottomSheet({
    super.key,
    required this.data,
    required this.controller,
    required this.scrollController,
  });

  final Data data;
  final AbsenController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
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
                        ? "Location is not suitable"
                        : "You are within the attendance radius",
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
                ? buildVisit(data: data, controller: controller)
                : buildAbsen(data: data, controller: controller),

            const SizedBox(height: 10),

            /// SLIDER BUTTON
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(() {
                final enabled = controller.isEnabled.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1B2541).withOpacity(enabled ? 1 : 0.5),
                        const Color(0xFF3949AB).withOpacity(enabled ? 1 : 0.5),
                      ],
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
                      if (!enabled) {
                        return false;
                      }
                      // if (controller.isTimeUntrusted.value) {
                      //   showToast(
                      //     "Jam perangkat tidak valid.\nTidak dapat melakukan absensi.",
                      //   );
                      //   return false;
                      // }
                      // if (data.visit == "1") {

                      if (controller.stsAbsenSelected.value.isEmpty) {
                        showToast("please select check in / out first");
                      } else {
                        if (data.visit == "1") {
                          // visit
                          if (controller.optVisitSelected.isEmpty) {
                            showToast("please select RND / Visit first");
                          } else if (controller.optVisitSelected.value ==
                                  "Research and Development" &&
                              controller.rndLoc.text.isEmpty) {
                            showToast("please fill in the location");
                            // } else if (controller.optVisitSelected.value ==
                            //         "Store Visit" &&
                            //     controller.selectedCabangVisit.isEmpty) {
                            //   showToast("please select a store");
                          } else {
                            loadingDialog("open the camera", "");
                            controller.stsAbsenSelected.value == "Check In"
                                ? await visitIn(
                                  dataUser: data,
                                  latitude: controller.latFromGps.value,
                                  longitude: controller.longFromGps.value,
                                )
                                : await visitOut(
                                  dataUser: data,
                                  latitude: controller.latFromGps.value,
                                  longitude: controller.longFromGps.value,
                                );
                          }
                        } else {
                          // absen
                          if (controller.stsAbsenSelected.value == "Check In" &&
                              controller.selectedShift.isEmpty) {
                            showToast("please select absence shift first");
                          } else {
                            loadingDialog("open the camera", "");
                            controller.stsAbsenSelected.value == "Check In"
                                ? await checkIn(
                                  data,
                                  controller.latFromGps.value,
                                  controller.longFromGps.value,
                                )
                                : await checkOut(
                                  data,
                                  controller.latFromGps.value,
                                  controller.longFromGps.value,
                                );
                          }
                        }
                      }
                      // } else {
                      // }

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
