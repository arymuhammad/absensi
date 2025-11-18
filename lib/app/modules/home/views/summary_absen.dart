import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/widget/summary_today.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'main_menu.dart';
import 'widget/summary_per_month.dart';

class SummaryAbsen extends GetView {
  SummaryAbsen({super.key, this.userData});
  final Data? userData;
  final absenC = Get.find<AbsenController>();
  final homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SummaryToday(listDataUser: userData!),
          const SizedBox(height: 15),
          Expanded(
            child: CustomMaterialIndicator(
              onRefresh: () async {
                var paramLimit = {
                  "mode": "limit",
                  "id_user": userData!.id,
                  "tanggal1": absenC.initDate1,
                  "tanggal2": absenC.initDate2,
                };

                var paramSingle = {
                  "mode": "single",
                  "id_user": userData!.id,
                  "tanggal_masuk": DateFormat(
                    'yyyy-MM-dd',
                  ).format(absenC.tglStream.value),
                };

                absenC.isLoading.value = true;
                homeC.reloadSummary(userData!.id!);
                await absenC.getLastUserData(dataUser: userData!);
                showToast('Page Refreshed');
                await absenC.getAbsenToday(paramSingle);
                await absenC.getLimitAbsen(paramLimit);

                showToast("Page Refreshed");

                // return Future.delayed(const Duration(seconds: 1), () async {});
              },
              backgroundColor: Colors.white,
              indicatorBuilder: (context, controller) {
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child:
                      Platform.isAndroid
                          ? CircularProgressIndicator(
                            color: AppColors.itemsBackground,
                            value:
                                controller.state.isLoading
                                    ? null
                                    : math.min(controller.value, 1.0),
                          )
                          : const CupertinoActivityIndicator(),
                );
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SummaryPerMonth(userData: userData!),
                  const SizedBox(height: 5),
                  MainMenu(userData: userData!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance History',
                        style: titleTextStyle.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () =>
                        absenC.isLoading.value
                            ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey,
                                            highlightColor:
                                                const Color.fromARGB(
                                                  255,
                                                  238,
                                                  238,
                                                  238,
                                                ),
                                            child: Container(
                                              width: 60,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey,
                                            highlightColor:
                                                const Color.fromARGB(
                                                  255,
                                                  238,
                                                  238,
                                                  238,
                                                ),
                                            child: Container(
                                              width: 130,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey,
                                        highlightColor: const Color.fromARGB(
                                          255,
                                          238,
                                          238,
                                          238,
                                        ),
                                        child: Container(
                                          width: 70,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey,
                                        highlightColor: const Color.fromARGB(
                                          255,
                                          238,
                                          238,
                                          238,
                                        ),
                                        child: Container(
                                          width: 60,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey,
                                        highlightColor: const Color.fromARGB(
                                          255,
                                          238,
                                          238,
                                          238,
                                        ),
                                        child: Container(
                                          width: 70,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : absenC.dataLimitAbsen.isEmpty
                            ? SizedBox(
                              height: Get.size.height / 3,
                              child: const Center(
                                child: Text('Belum ada riwayat absen'),
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder:
                                  (context, index) => const SizedBox(height: 8),
                              itemCount: absenC.dataLimitAbsen.length,
                              itemBuilder: (c, i) {
                                var diffHours = const Duration();
                                if (absenC.dataLimitAbsen.isNotEmpty &&
                                    absenC.dataLimitAbsen[i].jamAbsenPulang !=
                                        "") {
                                  if (DateTime.parse(
                                    absenC.dataLimitAbsen[i].tanggalPulang!,
                                  ).isAfter(
                                    DateTime.parse(
                                      absenC.dataLimitAbsen[i].tanggalMasuk!,
                                    ),
                                  )) {
                                    diffHours = DateTime.parse(
                                          '${absenC.dataLimitAbsen[i].tanggalMasuk!} ${absenC.dataLimitAbsen[i].jamAbsenPulang!}',
                                        )
                                        .add(const Duration(hours: -1))
                                        .difference(
                                          DateTime.parse(
                                            '${absenC.dataLimitAbsen[i].tanggalPulang!} ${absenC.dataLimitAbsen[i].jamAbsenMasuk!}',
                                          ),
                                        );
                                  } else {
                                    diffHours = DateTime.parse(
                                      '${absenC.dataLimitAbsen[i].tanggalMasuk!} ${absenC.dataLimitAbsen[i].jamAbsenPulang!}',
                                    ).difference(
                                      DateTime.parse(
                                        '${absenC.dataLimitAbsen[i].tanggalPulang!} ${absenC.dataLimitAbsen[i].jamAbsenMasuk!}',
                                      ),
                                    );
                                  }
                                } else {
                                  diffHours = const Duration();
                                }

                                var stsMasuk =
                                    FormatWaktu.formatJamMenit(
                                          jamMenit:
                                              absenC
                                                  .dataLimitAbsen[i]
                                                  .jamAbsenMasuk!,
                                        ).isBefore(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit:
                                                absenC
                                                    .dataLimitAbsen[i]
                                                    .jamMasuk!,
                                          ),
                                        )
                                        ? "Early"
                                        : FormatWaktu.formatJamMenit(
                                          jamMenit:
                                              absenC
                                                  .dataLimitAbsen[i]
                                                  .jamAbsenMasuk!,
                                        ).isAtSameMomentAs(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit:
                                                absenC
                                                    .dataLimitAbsen[i]
                                                    .jamMasuk!,
                                          ),
                                        )
                                        ? "On Time"
                                        : "Late";
                                var stsPulang =
                                    absenC.dataLimitAbsen[i].jamAbsenPulang! ==
                                            ""
                                        ? "Absent"
                                        : DateTime.parse(
                                              absenC
                                                  .dataLimitAbsen[i]
                                                  .tanggalPulang!,
                                            ).isAfter(
                                              DateTime.parse(
                                                absenC
                                                    .dataLimitAbsen[i]
                                                    .tanggalMasuk!,
                                              ),
                                            ) &&
                                            FormatWaktu.formatJamMenit(
                                              jamMenit:
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .jamAbsenPulang!,
                                            ).isAfter(
                                              FormatWaktu.formatJamMenit(
                                                jamMenit:
                                                    absenC
                                                        .dataLimitAbsen[i]
                                                        .jamAbsenMasuk!,
                                              ).add(const Duration(hours: 8)),
                                            )
                                        ? "Over Time"
                                        : DateTime.parse(
                                              absenC
                                                  .dataLimitAbsen[i]
                                                  .tanggalPulang!,
                                            ).isAtSameMomentAs(
                                              DateTime.parse(
                                                absenC
                                                    .dataLimitAbsen[i]
                                                    .tanggalMasuk!,
                                              ),
                                            ) &&
                                            FormatWaktu.formatJamMenit(
                                              jamMenit:
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .jamAbsenPulang!,
                                            ).isBefore(
                                              FormatWaktu.formatJamMenit(
                                                jamMenit:
                                                    absenC
                                                        .dataLimitAbsen[i]
                                                        .jamPulang!,
                                              ),
                                            )
                                        ? "Early"
                                        : FormatWaktu.formatJamMenit(
                                          jamMenit:
                                              absenC
                                                  .dataLimitAbsen[i]
                                                  .jamAbsenPulang!,
                                        ).isAtSameMomentAs(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit:
                                                absenC
                                                    .dataLimitAbsen[i]
                                                    .jamPulang!,
                                          ),
                                        )
                                        ? 'On Time'
                                        : "Over Time";

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    double maxWidth = constraints.maxWidth;
                                    return InkWell(
                                      onTap:
                                          () => Get.to(() {
                                            var detailData = {
                                              "foto_profil":
                                                  userData!.foto != ""
                                                      ? userData!.foto
                                                      : userData!.nama,
                                              "nama":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .nama!,
                                              "nama_shift":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .namaShift!,
                                              "id_user":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .idUser!,
                                              "tanggal_masuk":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .tanggalMasuk!,
                                              "tanggal_pulang":
                                                  absenC
                                                              .dataLimitAbsen[i]
                                                              .tanggalPulang !=
                                                          null
                                                      ? absenC
                                                          .dataLimitAbsen[i]
                                                          .tanggalPulang!
                                                      : "",
                                              "jam_masuk": stsMasuk,
                                              "jam_pulang": stsPulang,
                                              "jam_absen_masuk":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .jamAbsenMasuk!,
                                              "jam_absen_pulang":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .jamAbsenPulang!,
                                              "foto_masuk":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .fotoMasuk!,
                                              "foto_pulang":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .fotoPulang!,
                                              "lat_masuk":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .latMasuk!,
                                              "long_masuk":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .longMasuk!,
                                              "lat_pulang":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .latPulang!,
                                              "long_pulang":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .longPulang!,
                                              "device_info":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .devInfo!,
                                              "device_info2":
                                                  absenC
                                                      .dataLimitAbsen[i]
                                                      .devInfo2!,
                                            };

                                            return DetailAbsenView(detailData);
                                          }, transition: Transition.cupertino),
                                      child: Container(
                                        width: maxWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          color: Colors.white,
                                        ),
                                        height:
                                            i == 0 &&
                                                    absenC.statsCon.value != ""
                                                ? 147
                                                : 85,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: maxWidth * 0.15,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                      color:
                                                          AppColors
                                                              .itemsBackground,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        // Tanggal
                                                        Text(
                                                          FormatWaktu.formatTanggal(
                                                            tanggal:
                                                                absenC
                                                                    .dataLimitAbsen[i]
                                                                    .tanggalMasuk!,
                                                          ),
                                                          style: titleTextStyle
                                                              .copyWith(
                                                                fontSize:
                                                                    maxWidth *
                                                                    0.06,
                                                                color:
                                                                    AppColors
                                                                        .contentColorWhite,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        // Hari
                                                        Text(
                                                          FormatWaktu.formatHariEn(
                                                            tanggal:
                                                                absenC
                                                                    .dataLimitAbsen[i]
                                                                    .tanggalMasuk!,
                                                          ),
                                                          style: subtitleTextStyle
                                                              .copyWith(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  SizedBox(
                                                    width: maxWidth * 0.7,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        IntrinsicHeight(
                                                          child: Row(
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    absenC
                                                                        .dataLimitAbsen[i]
                                                                        .jamAbsenMasuk!,
                                                                    style: TextStyle(
                                                                      color:
                                                                          stsMasuk ==
                                                                                  "Late"
                                                                              ? red
                                                                              : green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          maxWidth *
                                                                          0.05,
                                                                    ),
                                                                  ),
                                                                  const Text(
                                                                    'Check In',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              const VerticalDivider(
                                                                color:
                                                                    Colors
                                                                        .grey, // Warna garis
                                                                // thickness:
                                                                //     1, // Ketebalan garis
                                                                width:
                                                                    25, // Lebar box pembungkus
                                                                // indent: 20, // Jarak dari atas
                                                                endIndent: 5,
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    absenC
                                                                        .dataLimitAbsen[i]
                                                                        .jamAbsenPulang!,
                                                                    style: TextStyle(
                                                                      color:
                                                                          stsPulang ==
                                                                                      "Early" ||
                                                                                  stsPulang ==
                                                                                      "Absent"
                                                                              ? red
                                                                              : green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          maxWidth *
                                                                          0.05,
                                                                    ),
                                                                  ),
                                                                  const Text(
                                                                    'Check Out',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              const VerticalDivider(
                                                                color:
                                                                    Colors
                                                                        .grey, // Warna garis
                                                                // thickness:
                                                                //     1, // Ketebalan garis
                                                                width:
                                                                    25, // Lebar box pembungkus
                                                                // indent: 20, // Jarak dari atas
                                                                endIndent: 5,
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    absenC.dataLimitAbsen.isNotEmpty &&
                                                                            absenC.dataLimitAbsen[i].jamAbsenMasuk! !=
                                                                                ""
                                                                        ? '${absenC.dataLimitAbsen[i].jamAbsenPulang != "" ? diffHours.inHours % 24 : '-'}j ${absenC.dataLimitAbsen[i].jamAbsenPulang != "" ? diffHours.inMinutes % 60 : '-'}m'
                                                                        : '-:-',
                                                                    style: TextStyle(
                                                                      // color:
                                                                      //     stsPulang ==
                                                                      //                 "Pulang Cepat" ||
                                                                      //             stsPulang ==
                                                                      //                 "Belum Absen"
                                                                      //         ? red
                                                                      //         : green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          maxWidth *
                                                                          0.05,
                                                                    ),
                                                                  ),
                                                                  const Text(
                                                                    'Total Hours',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                AppColors
                                                                    .itemsBackground,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 5,
                                                                right: 5,
                                                              ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                HeroIcons
                                                                    .map_pin,
                                                                size: 16,
                                                                color:
                                                                    AppColors
                                                                        .contentColorWhite,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                absenC
                                                                    .dataLimitAbsen[i]
                                                                    .namaCabang!
                                                                    .capitalize!,
                                                                style: const TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .contentColorWhite,
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
                                              const SizedBox(height: 2),
                                              i == 0 &&
                                                      absenC.statsCon.value !=
                                                          ""
                                                  ? Container(
                                                    width:
                                                        Get
                                                            .mediaQuery
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                            118,
                                                            255,
                                                            139,
                                                            128,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 8.0,
                                                          ),
                                                      child: Text(
                                                        absenC.statsCon.value,
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .redAccent[700],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
