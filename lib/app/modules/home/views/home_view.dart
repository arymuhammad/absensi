import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/home/views/summary_absen.dart';
import 'package:absensi/app/modules/home/views/summary_absen_area.dart';
import 'package:absensi/app/modules/leave/controllers/leave_controller.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/shared/rounded_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../absen/controllers/absen_controller.dart';
import '../../adjust_presence/controllers/adjust_presence_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key, this.listDataUser});
  final Data? listDataUser;
  final absenC = Get.put(AbsenController());
  final adjCtrl = Get.put(AdjustPresenceController());
  final leaveC = Get.put(LeaveController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // const CsBgImg(),
          Container(
            height: 110,
            decoration: const BoxDecoration(color: AppColors.itemsBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 40.0, right: 15.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(
                              () => ProfilView(listDataUser: listDataUser!),
                            );
                          },
                          child: RoundedImage(
                            height: 60,
                            width: 60,
                            foto: listDataUser!.foto!,
                            name: listDataUser!.nama!,
                            headerProfile: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listDataUser!.nama!.substring(
                                    0,
                                    listDataUser!.nama!.length > 18
                                        ? 18
                                        : listDataUser!.nama!.length,
                                  ) +
                                  (listDataUser!.nama!.length > 18 ? '...' : '')
                                      .toString()
                                      .capitalize!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                              style: titleTextStyle.copyWith(
                                fontSize: 18,
                                color: AppColors.contentColorWhite,
                                // fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              listDataUser!.levelUser!.capitalize!,
                              style: subtitleTextStyle.copyWith(
                                // color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              listDataUser!.namaCabang!.capitalize!,
                              // overflow: TextOverflow.ellipsis,
                              // maxLines: 1,
                              softWrap: true,
                              style: subtitleTextStyle.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
        ],
      ),
    );
  }
}
