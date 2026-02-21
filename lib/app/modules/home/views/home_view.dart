import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/home/views/summary_absen.dart';
import 'package:absensi/app/modules/home/views/summary_absen_area.dart';
import 'package:absensi/app/modules/leave/controllers/leave_controller.dart';
import 'package:absensi/app/modules/shared/container_main_color.dart';
import 'package:absensi/app/modules/shared/rounded_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../absen/controllers/absen_controller.dart';
import '../../adjust_presence/controllers/adjust_presence_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key, this.listDataUser});
  final Data? listDataUser;
  final absenC = Get.put(AbsenController());
  final adjCtrl = Get.put(AdjustPresenceController());
  final leaveC = Get.put(LeaveController());
  final greetingC = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          ContainerMainColor(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            radius: 0,
            child: Container(height: 230),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 45.0, right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Text(
                            '${greetingC.greeting.value}${listDataUser!.nama!.split(' ')[0]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.contentColorWhite,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.waving_hand_rounded,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    // Obx(() => Image(image: greetingC.icon.value, width: 42)),
                    // const Padding(
                    //   padding: EdgeInsets.all(8.0),
                    //   child: PingIndicator(host: '103.156.15.61'),
                    // ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // Get.to(
                            //   () => ProfilView(listDataUser: listDataUser!),
                            // );
                            final loginC = Get.find<LoginController>();
                            loginC.selected.value = 4;
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 1,
                              ), // border putih tebal 4
                            ),
                            child: RoundedImage(
                              height: 60,
                              width: 60,
                              foto: listDataUser!.foto!,
                              name: listDataUser!.nama!,
                              headerProfile: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listDataUser!.levelUser!.capitalize!,
                              style: subtitleTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              listDataUser!.namaCabang!.capitalize!,

                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ping widget
                  ],
                ),
                const SizedBox(height: 5),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [

                //     Obx(
                //       () => IconButton(
                //         onPressed:
                //             absenC.timerStat.value == true ||
                //                     absenC.dataAbsen.isEmpty
                //                 ? null
                //                 : () async {
                //                   if (absenC.dataAbsen.isEmpty) {
                //                     absenC.startTimer(0);
                //                     showToast("Tidak ada data absen hari ini");
                //                   } else {
                //                     loadingDialog("Sending data", "");
                //                     absenC.startTimer(20);
                //                     absenC.resend();

                //                     await Future.delayed(
                //                       const Duration(seconds: 2),
                //                       () {
                //                         Get.back();
                //                       },
                //                     );
                //                   }
                //                 },
                //         icon: Icon(
                //           Icons.change_circle_sharp,
                //           size: 30.0,
                //           color:
                //               absenC.timerStat.value == true
                //                   ? AppColors.mainTextColor3
                //                   : AppColors.contentColorWhite,
                //         ),
                //         tooltip: 'Resend Data',
                //       ),
                //     ),
                //   ],
                // ),
                // Visibility(
                //   visible: listDataUser!.visit == "1" ? true : false,
                //   child: Row(
                //     children: [
                //       const Icon(
                //         FontAwesome.map_location_dot_solid,
                //         size: 17,
                //         color: AppColors.contentColorWhite,
                //       ),
                //       const SizedBox(width: 5),
                //       Obx(
                //         () => Text(
                //           absenC.dataVisit.isNotEmpty &&
                //                   absenC.dataVisit[0].namaCabang! != ""
                //               ? absenC.dataVisit[0].namaCabang!
                //               : '-',
                //           style: const TextStyle(fontWeight: FontWeight.bold),
                //           softWrap: true,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                listDataUser!.visit == "1"
                    ? SummaryAbsenArea(userData: listDataUser!)
                    : SummaryAbsen(userData: listDataUser!),
              ],
            ),
          ),
          Positioned(
            top: 45,
            right: -5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;

                // ukuran responsif
                final double iconSize = screenWidth * 0.20; // ±28% layar

                return IgnorePointer(
                  child: Opacity(
                    opacity: 0.95,
                    child: Obx(
                      () => SizedBox(
                        height: iconSize,
                        width: iconSize,
                        child: greetingC.icon.value,
                      ),
                    ),
                    //   width: iconSize,
                    //   height: iconSize,
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
