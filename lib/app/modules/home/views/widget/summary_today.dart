import 'dart:io';

import 'package:absensi/app/data/model/visit_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:marquee/marquee.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/model/absen_model.dart';
import '../../../../data/model/login_model.dart';

class SummaryToday extends StatelessWidget {
  SummaryToday({super.key, this.listDataUser});
  final Data? listDataUser;
  final homeC = Get.put(HomeController());
  final absenC = Get.find<AbsenController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 8, top: 4, right: 8),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  FormatWaktu.formatIndo(tanggal: absenC.tglStream.value),
                  style: const TextStyle(
                    color: AppColors.contentColorWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Iconsax.clock_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                  StreamBuilder(
                    stream: homeC.getTime(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(
                            color: AppColors.contentColorWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Center(child: CupertinoActivityIndicator());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Container(
            height: listDataUser!.visit == "1" ? 170 : 150,
            decoration: BoxDecoration(
              color: AppColors.contentColorWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Expanded(
                        flex: 1,
                        child: _buildTimeCard(
                          title: 'Check In',
                          angle: -45,
                          icon: Icons.arrow_circle_left,
                          iconColor: AppColors.contentColorBlue,
                          isLoading: absenC.isLoading.value,
                          data: absenC.dataAbsen,
                          dataVisit: absenC.dataVisit,
                          isIn: true,
                          visit: listDataUser!.visit!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => Expanded(
                        flex: 1,
                        child: _buildTimeCard(
                          title: 'Check Out',
                          angle: -70,
                          icon: Icons.arrow_circle_right_rounded,
                          iconColor: AppColors.contentColorRed,
                          isLoading: absenC.isLoading.value,
                          data: absenC.dataAbsen,
                          dataVisit: absenC.dataVisit,
                          isIn: false,
                          visit: listDataUser!.visit!,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Visibility(
                        visible: listDataUser!.visit == "1" ? true : false,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  HeroIcons.map_pin,
                                  color: AppColors.contentColorBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Obx(
                                  () => Text(
                                    absenC.dataVisit.isNotEmpty &&
                                            absenC.dataVisit[0].namaCabang! !=
                                                ""
                                        ? absenC.dataVisit[0].namaCabang!
                                        : '-',
                                    style: titleTextStyle.copyWith(
                                      color: Colors.grey,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.clock_bold,
                                  color: AppColors.contentColorBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 2),
                                Obx(() {
                                  var diffHours = const Duration();
                                  if (absenC.dataVisit.isNotEmpty &&
                                      absenC.dataVisit[0].jamOut != "") {
                                    diffHours = DateTime.parse(
                                      '${absenC.dataVisit[0].tglVisit!} ${absenC.dataVisit[0].jamOut!}',
                                    ).difference(
                                      DateTime.parse(
                                        '${absenC.dataVisit[0].tglVisit!} ${absenC.dataVisit[0].jamIn!}',
                                      ),
                                    );
                                  } else {
                                    diffHours = const Duration();
                                  }
                                  return absenC.isLoading.value
                                      ? Platform.isAndroid
                                          ? const SizedBox(
                                            height: 17,
                                            width: 17,
                                            child: CircularProgressIndicator(),
                                          )
                                          : const SizedBox(
                                            height: 17,
                                            width: 17,
                                            child: CupertinoActivityIndicator(),
                                          )
                                      : Text(
                                        absenC.dataVisit.isNotEmpty &&
                                                absenC.dataVisit[0].jamIn! != ""
                                            ? ' Total hour ${absenC.dataVisit[0].jamOut != "" ? diffHours.inHours : '0'}j ${absenC.dataVisit[0].jamOut != "" ? diffHours.inMinutes % 60 : '0'}m'
                                            : '-:-',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          // color:
                                          //     absenC.dataVisit.isNotEmpty &&
                                          //             absenC
                                          //                     .dataVisit[0]
                                          //                     .jamIn! !=
                                          //                 ""
                                          //         ? green
                                          //         : defaultColor,
                                        ),
                                      );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: listDataUser!.visit == "1" ? false : true,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.itemsBackground,
                          ),
                          child: Row(
                            children: [
                              Transform.rotate(
                                angle: -120,
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  size: 18.0,
                                  color: AppColors.contentColorWhite,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 50,
                                width: Get.mediaQuery.size.width / 1.5,
                                child: Marquee(
                                  text:
                                      'Periksa selalu notifikasi untuk informasi pengajuan perubahan data absensi ',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.contentColorWhite,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 50.0, // kecepatan scrolling
                                  startPadding: 0.0,
                                  accelerationDuration: const Duration(
                                    seconds: 1,
                                  ),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  decelerationCurve: Curves.easeOut,
                                  pauseAfterRound: const Duration(seconds: 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildTimeCard({
  required String title,
  required double angle,
  required IconData icon,
  required Color iconColor,
  required bool isLoading,
  List<Absen>? data,
  List<Visit>? dataVisit,
  required bool isIn,
  required String visit,
}) {
  // Pilih list yang dipakai: jika data kosong atau null, pakai dataVisit
  // Tentukan data yang akan dipakai berdasarkan nilai visit
  final isVisitOne = (visit == "1");
  final effectiveData =
      isVisitOne
          ? null
          : (data != null && data.isNotEmpty
              ? data
              : null); // pakai data jika visit bukan 1
  final effectiveVisit =
      isVisitOne
          ? (dataVisit != null && dataVisit.isNotEmpty ? dataVisit : null)
          : null; // pakai dataVisit jika visit == "1"

  return Container(
    height: 108,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      // color: Colors.black,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: angle,
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          isIn
                              ? (effectiveData != null &&
                                      effectiveData[0].jamAbsenMasuk! != ""
                                  ? (FormatWaktu.formatJamMenit(
                                        jamMenit:
                                            effectiveData[0].jamAbsenMasuk!,
                                      ).isBefore(
                                        FormatWaktu.formatJamMenit(
                                          jamMenit: effectiveData[0].jamMasuk!,
                                        ),
                                      )
                                      ? green
                                      : FormatWaktu.formatJamMenit(
                                        jamMenit:
                                            effectiveData[0].jamAbsenMasuk!,
                                      ).isAtSameMomentAs(
                                        FormatWaktu.formatJamMenit(
                                          jamMenit: effectiveData[0].jamMasuk!,
                                        ),
                                      )
                                      ? green
                                      : red)
                                  : AppColors.mainTextColor1)
                              : (effectiveData != null &&
                                      effectiveData[0].jamAbsenPulang! != ""
                                  ? (FormatWaktu.formatJamMenit(
                                        jamMenit:
                                            effectiveData[0].jamAbsenPulang!,
                                      ).isBefore(
                                        FormatWaktu.formatJamMenit(
                                          jamMenit: effectiveData[0].jamPulang!,
                                        ),
                                      )
                                      ? green
                                      : FormatWaktu.formatJamMenit(
                                        jamMenit:
                                            effectiveData[0].jamAbsenPulang!,
                                      ).isAtSameMomentAs(
                                        FormatWaktu.formatJamMenit(
                                          jamMenit: effectiveData[0].jamPulang!,
                                        ),
                                      )
                                      ? green
                                      : red)
                                  : AppColors.mainTextColor1),
                    ),
                    child: Text(
                      isIn
                          ? (effectiveData != null &&
                                  effectiveData[0].jamAbsenMasuk! != ""
                              ? (FormatWaktu.formatJamMenit(
                                    jamMenit: effectiveData[0].jamAbsenMasuk!,
                                  ).isBefore(
                                    FormatWaktu.formatJamMenit(
                                      jamMenit: effectiveData[0].jamMasuk!,
                                    ),
                                  )
                                  ? 'Early'
                                  : FormatWaktu.formatJamMenit(
                                    jamMenit: effectiveData[0].jamAbsenMasuk!,
                                  ).isAtSameMomentAs(
                                    FormatWaktu.formatJamMenit(
                                      jamMenit: effectiveData[0].jamMasuk!,
                                    ),
                                  )
                                  ? 'On Time'
                                  : 'Late')
                              : '')
                          : (effectiveData != null &&
                                  effectiveData[0].jamAbsenPulang! != ""
                              ? (FormatWaktu.formatJamMenit(
                                    jamMenit: effectiveData[0].jamAbsenPulang!,
                                  ).isBefore(
                                    FormatWaktu.formatJamMenit(
                                      jamMenit: effectiveData[0].jamPulang!,
                                    ),
                                  )
                                  ? 'Early'
                                  : FormatWaktu.formatJamMenit(
                                    jamMenit: effectiveData[0].jamAbsenPulang!,
                                  ).isAtSameMomentAs(
                                    FormatWaktu.formatJamMenit(
                                      jamMenit: effectiveData[0].jamPulang!,
                                    ),
                                  )
                                  ? 'On Time'
                                  : 'Late')
                              : ''),
                      style: const TextStyle(
                        color: AppColors.contentColorWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          isLoading
              ? (Platform.isAndroid
                  ? const SizedBox(
                    height: 17,
                    width: 17,
                    child: CircularProgressIndicator(),
                  )
                  : const SizedBox(
                    height: 17,
                    width: 17,
                    child: CupertinoActivityIndicator(),
                  ))
              : Text(
                isIn
                    ? (effectiveData != null &&
                            effectiveData[0].jamAbsenMasuk! != ""
                        ? effectiveData[0].jamAbsenMasuk!
                        : (effectiveVisit != null &&
                                effectiveVisit[0].visitIn != null &&
                                effectiveVisit[0].visitIn!.isNotEmpty
                            ? effectiveVisit[0].jamIn!
                            : '-:-'))
                    : (effectiveData != null &&
                            effectiveData[0].jamAbsenPulang! != ""
                        ? effectiveData[0].jamAbsenPulang!
                        : (effectiveVisit != null &&
                                effectiveVisit[0].visitOut != null &&
                                effectiveVisit[0].visitOut!.isNotEmpty
                            ? effectiveVisit[0].jamOut!
                            : '-:-')),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    ),
  );
}
