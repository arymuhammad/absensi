import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/widget/summary_today.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/duration_count.dart';
import '../../../data/helper/error_logger.dart';
import '../../login/controllers/login_controller.dart';
import '../../shared/history_card.dart';
import '../../shared/history_card_shimmer.dart';
import 'main_menu.dart';
import 'widget/summary_per_month.dart';

class SummaryAbsen extends GetView {
  SummaryAbsen({super.key});
  final auth = Get.find<LoginController>();
  final absenC = Get.find<AbsenController>();
  final homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SummaryToday(),
          const SizedBox(height: 5),
          Expanded(
            child: CustomMaterialIndicator(
              onRefresh: () async {
                final uData = auth.logUser.value;
                final online = await absenC.isOnline();
                if (online) {
                  await ErrorLogger.save('''
                  SUMMARY REFRESH

                  ID          : ${uData.id}
                  KODE_CABANG : ${uData.kodeCabang}
                  LEVEL       : ${uData.level}

                  RAW:
                  ${jsonEncode(uData.toJson())}
                  ''', ''); //save error to log

                  homeC.getPendingAdj(
                    idUser: uData.id!,
                    idCabang: uData.kodeCabang!,
                    level: uData.level!,
                  );
                  homeC.getSummAttPerMonth(uData.id!);
                  await absenC.getLastUserData(dataUser: uData);
                }
                var paramLimit = {
                  "mode": "limit",
                  "id_user": uData.id,
                  "tanggal1": absenC.initDate1,
                  "tanggal2": absenC.initDate2,
                };

                var paramSingle = {
                  "mode": "single",
                  "id_user": uData.id,
                  "tanggal_masuk": DateFormat(
                    'yyyy-MM-dd',
                  ).format(absenC.tglStream.value),
                };

                // absenC.isLoading.value = true;

                // showToast('Page Refreshed');
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
                  SummaryPerMonth(),
                  // const SizedBox(height: 5),
                  MainMenu(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                        child: Text(
                          'Attendance History',
                          style: titleTextStyle.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () =>
                        absenC.isLoading.value && absenC.dataLimitAbsen.isEmpty
                            ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return const HistoryCardShimmer();
                              },
                            )
                            : absenC.dataLimitAbsen.isEmpty
                            ? Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(8, 25, 8, 25),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.assignment_ind),
                                    SizedBox(height: 5),
                                    Text('There is no attendance history yet'),
                                  ],
                                ),
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder:
                                  (context, index) => const SizedBox(height: 0),
                              itemCount: absenC.dataLimitAbsen.length,
                              itemBuilder: (c, i) {
                                final d = absenC.dataLimitAbsen[i];
                                final jamMasuk = safe(d.jamAbsenMasuk);
                                final jamPulang = safe(d.jamAbsenPulang);
                                final tglMasuk = safe(d.tanggalMasuk);
                                final tglPulang = safe(d.tanggalPulang);
                                final jamShiftMasuk = safe(d.jamMasuk);
                                final jamShiftPulang = safe(d.jamPulang);

                                /// =====================
                                /// STATUS MASUK
                                /// =====================
                                var stsMasuk = "-";

                                if (jamMasuk.isNotEmpty &&
                                    jamShiftMasuk.isNotEmpty) {
                                  try {
                                    final jm = FormatWaktu.formatJamMenit(
                                      jamMenit: jamMasuk,
                                    );
                                    final jm2 = FormatWaktu.formatJamMenit(
                                      jamMenit: jamShiftMasuk,
                                    );

                                    if (jm.isBefore(jm2)) {
                                      stsMasuk = "Early";
                                    } else if (jm.isAtSameMomentAs(jm2)) {
                                      stsMasuk = "On Time";
                                    } else {
                                      stsMasuk = "Late";
                                    }
                                  } catch (_) {}
                                }

                                /// =====================
                                /// STATUS PULANG
                                /// =====================
                                var stsPulang = "Absent";

                                if (jamPulang.isNotEmpty &&
                                    tglPulang.isNotEmpty &&
                                    tglMasuk.isNotEmpty) {
                                  try {
                                    final tp = DateTime.parse(tglPulang);
                                    final tm = DateTime.parse(tglMasuk);

                                    final jp = FormatWaktu.formatJamMenit(
                                      jamMenit: jamPulang,
                                    );
                                    final jm = FormatWaktu.formatJamMenit(
                                      jamMenit: jamMasuk,
                                    );
                                    final shiftOut = FormatWaktu.formatJamMenit(
                                      jamMenit: jamShiftPulang,
                                    );

                                    if (tp.isAfter(tm) &&
                                        jp.isAfter(
                                          jm.add(const Duration(hours: 8)),
                                        )) {
                                      stsPulang = "Over Time";
                                    } else if (tp.isAtSameMomentAs(tm) &&
                                        jp.isBefore(shiftOut)) {
                                      stsPulang = "Minus Time";
                                    } else if (jp.isAtSameMomentAs(shiftOut)) {
                                      stsPulang = "On Time";
                                    } else if (jp.isAfter(
                                      shiftOut.add(const Duration(hours: 1)),
                                    )) {
                                      stsPulang = "Overtime";
                                    } else {
                                      stsPulang = "Extra Time";
                                    }
                                  } catch (_) {
                                    stsPulang = "Invalid";
                                  }
                                }
                                //
                                // print('STATUS SYNC ${d.statusSync}');
                                return InkWell(
                                  onTap: () {
                                    final userData = auth.logUser.value;
                                    var detailData = {
                                      "foto_profil":
                                          userData.foto != ""
                                              ? userData.foto
                                              : userData.nama,
                                      "nama": d.nama,
                                      "id_shift": d.idShift,
                                      "nama_shift": d.namaShift,
                                      "id_user": d.idUser,
                                      "kode_cabang": d.kodeCabang,
                                      "tanggal_masuk": tglMasuk,
                                      "tanggal_pulang": tglPulang,
                                      "sts_masuk": stsMasuk,
                                      "sts_pulang": stsPulang,
                                      "jam_masuk": jamMasuk,
                                      "jam_pulang": jamPulang,
                                      "jam_absen_masuk": jamShiftMasuk,
                                      "jam_absen_pulang": jamShiftPulang,
                                      "foto_masuk": d.fotoMasuk,
                                      "foto_pulang": d.fotoPulang,
                                      "lat_masuk": d.latMasuk,
                                      "long_masuk": d.longMasuk,
                                      "lat_pulang": d.latPulang,
                                      "long_pulang": d.longPulang,
                                      "device_info": d.devInfo,
                                      "device_info2": d.devInfo2,
                                    };

                                    //   Get.to(() {

                                    //   return DetailAbsenView(detailData);
                                    // }, transition: Transition.cupertino);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => DetailAbsenView(detailData),
                                      ),
                                    );
                                  },
                                  child: HistoryCard(
                                    date: DateTime.parse(d.tanggalMasuk!),
                                    checkIn: safe(d.jamAbsenMasuk),
                                    checkOut: safe(d.jamAbsenPulang),
                                    duration: hitungDurasiFull(
                                      tglMasuk: d.tanggalMasuk,
                                      jamMasuk: d.jamAbsenMasuk,
                                      tglPulang: d.tanggalPulang,
                                      jamPulang: d.jamAbsenPulang,
                                    ),
                                    location: safe(d.namaCabang),
                                    isValid: d.jamAbsenMasuk != null,
                                    stsM: stsMasuk,
                                    stsP: stsPulang,
                                    isLocal: d.isLocal!,
                                    statusSync: safe(d.statusSync),
                                  ),
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

String safe(String? v, [String fallback = '']) {
  if (v == null || v.isEmpty) return fallback;
  return v;
}
