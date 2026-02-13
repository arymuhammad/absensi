import 'dart:io';

import 'package:absensi/app/data/model/visit_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/model/absen_model.dart';
import '../../../../data/model/login_model.dart';
import '../../../login/controllers/login_controller.dart';

class SummaryToday extends StatelessWidget {
  SummaryToday({super.key, this.listDataUser});
  final Data? listDataUser;
  final homeC = Get.find<HomeController>();
  final absenC = Get.find<AbsenController>();
  final logC = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container(
        //   padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
        //   height: 180,
        //   decoration: BoxDecoration(
        //     color: AppColors.itemsBackground,
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Obx(
        //         () => Text(
        //           FormatWaktu.formatIndo(tanggal: absenC.tglStream.value),
        //           style: const TextStyle(
        //             color: AppColors.contentColorWhite,
        //             fontWeight: FontWeight.bold,
        //             fontSize: 14,
        //           ),
        //         ),
        //       ),
        //       Row(
        //         children: [
        //           const Icon(
        //             Iconsax.clock_outline,
        //             size: 18,
        //             color: Colors.white,
        //           ),
        //           StreamBuilder(
        //             stream: homeC.getTime(),
        //             builder: (context, snapshot) {
        //               if (snapshot.hasData) {
        //                 return Text(
        //                   snapshot.data!,
        //                   style: const TextStyle(
        //                     color: AppColors.contentColorWhite,
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 14,
        //                   ),
        //                 );
        //               } else if (snapshot.hasError) {
        //                 return Text('${snapshot.error}');
        //               }
        //               return const Center(child: CupertinoActivityIndicator());
        //             },
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            child: Container(
              height: listDataUser!.visit == "1" ? 170 : 168,
              decoration: BoxDecoration(
                color: AppColors.contentColorWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    absenC.dataAbsen.isNotEmpty || absenC.dataVisit.isNotEmpty
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Obx(
                            //   () =>
                            Expanded(
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
                            // ),
                            const SizedBox(width: 10),
                            // Obx(
                            //   () =>
                            Expanded(
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
                            // ),
                          ],
                        )
                        : Container(
                          height: 130, // tambahin dikit biar napas
                          width: Get.mediaQuery.size.width,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              /// IMAGE KANAN
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 40, // stop sebelum button
                                child: Image.asset(
                                  'assets/image/bg_sts_home.png',
                                  width: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              /// TEXT
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  48,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Today's status",
                                      style: titleTextStyle.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Haven't Checked In yet",
                                      style: titleTextStyle.copyWith(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ✅ BUTTON FIX DI BOTTOM
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      logC.selectedMenu(2);
                                      // 🔑 VALIDASI STATUS ABSEN TERKINI (DB / SERVER)
                                      await absenC.refreshAbsen(listDataUser!);

                                      // ⛔ Jika masih wajib checkout, jangan lanjut ambil lokasi
                                      if (absenC.mustCheckoutYesterday.value) {
                                        showToast(
                                          'You must Check Out yesterday first',
                                        );
                                        return;
                                      }

                                      // 📍 BARU ambil lokasi
                                      absenC.getLoc(listDataUser);
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/image/bg_btn_ci.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'CHECK IN NOW',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible:
                                listDataUser!.visit == "1" &&
                                        absenC.dataVisit.isNotEmpty
                                    ? true
                                    : false,
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
                                    // Obx(
                                    //   () =>
                                    Text(
                                      absenC.dataVisit.isNotEmpty &&
                                              absenC.dataVisit[0].namaCabang! !=
                                                  ""
                                          ? absenC
                                              .dataVisit[0]
                                              .namaCabang!
                                              .capitalize!
                                          : '-',
                                      style: titleTextStyle.copyWith(
                                        color: Colors.grey,
                                      ),
                                      softWrap: true,
                                    ),
                                    // ),
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
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                              : const SizedBox(
                                                height: 17,
                                                width: 17,
                                                child:
                                                    CupertinoActivityIndicator(),
                                              )
                                          : Text(
                                            absenC.dataVisit.isNotEmpty &&
                                                    absenC
                                                            .dataVisit[0]
                                                            .jamIn! !=
                                                        ""
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
                            visible: listDataUser!.visit != "1",
                            child:
                                // Obx(
                                //   () =>
                                absenC.dataAbsen.isEmpty
                                    ? Container()
                                    : StreamBuilder<Duration>(
                                      stream: absenC.countdownToCheckout(
                                        DateFormat('HH:mm').parse(
                                          absenC.dataAbsen[0].jamAbsenMasuk!,
                                        ),
                                      ),
                                      builder: (context, snapshot) {
                                        // ⛔ JIKA SUDAH CHECK OUT, JANGAN TAMPILKAN APA-APA
                                        final jamPulang =
                                            absenC.dataAbsen[0].jamAbsenPulang;
                                        if (jamPulang != null &&
                                            jamPulang.isNotEmpty) {
                                          return const SizedBox(); // atau Text("Checked out")
                                        }

                                        if (snapshot.hasData) {
                                          final remaining = snapshot.data!;

                                          // ✅ WAKTU SUDAH HABIS & BELUM CHECKOUT
                                          if (remaining == Duration.zero) {
                                            return const Row(
                                              children: [
                                                Text(
                                                  'It`s time to Check Out',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        AppColors
                                                            .contentColorGreenAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Nunito',
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          // ⏳ MASIH COUNTDOWN
                                          return Row(
                                            children: [
                                              const Icon(
                                                Icons.hourglass_bottom_rounded,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 2),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: absenC
                                                          .formatDuration(
                                                            remaining,
                                                          ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors
                                                                .contentColorRed,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text:
                                                          ' until you Check Out',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Nunito',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        // ⏱️ LOADING STREAM
                                        return const Row(
                                          children: [
                                            Text(
                                              'counting time...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Nunito',
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            // ),
                          ),
                          const SizedBox(height: 3,),
                          Visibility(
                            visible: absenC.dataAbsen.isNotEmpty,
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.clock, size: 19,),
                                const SizedBox(width:3 ,),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Jam Kerja: ',
                                        style: TextStyle(
                                          color: AppColors.itemsBackground,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${absenC.dataAbsen.isNotEmpty?absenC.dataAbsen[0].jamMasuk:''} - ${absenC.dataAbsen.isNotEmpty?absenC.dataAbsen[0].jamPulang:''}',
                                        style: TextStyle(
                                          color: AppColors.itemsBackground,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                                      ? red
                                      : FormatWaktu.formatJamMenit(
                                        jamMenit:
                                            effectiveData[0].jamAbsenPulang!,
                                      ).isAtSameMomentAs(
                                        FormatWaktu.formatJamMenit(
                                          jamMenit: effectiveData[0].jamPulang!,
                                        ),
                                      )
                                      ? green
                                      : yellow)
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
                                  : 'Overtime')
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
