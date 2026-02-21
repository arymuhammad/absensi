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
import 'package:intl/intl.dart';

import '../../../data/helper/duration_count.dart';
import '../../shared/history_card.dart';
import '../../shared/history_card_shimmer.dart';
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
          const SizedBox(height: 10),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 15),
                        child: Text(
                          'Attendance History',
                          style: titleTextStyle.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 5),
                  Obx(
                    () =>
                        absenC.isLoading.value
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
                                  (context, index) => const SizedBox(height: 0),
                              itemCount: absenC.dataLimitAbsen.length,
                              itemBuilder: (c, i) {
                                final d = absenC.dataLimitAbsen[i];

                                var stsMasuk =
                                    FormatWaktu.formatJamMenit(
                                          jamMenit: d.jamAbsenMasuk!,
                                        ).isBefore(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit: d.jamMasuk!,
                                          ),
                                        )
                                        ? "Early"
                                        : FormatWaktu.formatJamMenit(
                                          jamMenit: d.jamAbsenMasuk!,
                                        ).isAtSameMomentAs(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit: d.jamMasuk!,
                                          ),
                                        )
                                        ? "On Time"
                                        : "Late";
                                var stsPulang =
                                    d.jamAbsenPulang! == ""
                                        ? "Absent"
                                        : DateTime.parse(
                                              d.tanggalPulang!,
                                            ).isAfter(
                                              DateTime.parse(d.tanggalMasuk!),
                                            ) &&
                                            FormatWaktu.formatJamMenit(
                                              jamMenit: d.jamAbsenPulang!,
                                            ).isAfter(
                                              FormatWaktu.formatJamMenit(
                                                jamMenit: d.jamAbsenMasuk!,
                                              ).add(const Duration(hours: 8)),
                                            )
                                        ? "Over Time"
                                        : DateTime.parse(
                                              d.tanggalPulang!,
                                            ).isAtSameMomentAs(
                                              DateTime.parse(d.tanggalMasuk!),
                                            ) &&
                                            FormatWaktu.formatJamMenit(
                                              jamMenit: d.jamAbsenPulang!,
                                            ).isBefore(
                                              FormatWaktu.formatJamMenit(
                                                jamMenit: d.jamPulang!,
                                              ),
                                            )
                                        ? "Minus Time"
                                        : FormatWaktu.formatJamMenit(
                                          jamMenit: d.jamAbsenPulang!,
                                        ).isAtSameMomentAs(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit: d.jamPulang!,
                                          ),
                                        )
                                        ? 'On Time'
                                        : FormatWaktu.formatJamMenit(
                                          jamMenit: d.jamAbsenPulang!,
                                        ).isAfter(
                                          FormatWaktu.formatJamMenit(
                                            jamMenit: d.jamPulang!,
                                          ).add(const Duration(hours: 1)),
                                        )
                                        ? 'Overtime'
                                        : 'Extra Time';
                                //
                                return InkWell(
                                  onTap: () {
                                    var detailData = {
                                      "foto_profil":
                                          userData!.foto != ""
                                              ? userData!.foto
                                              : userData!.nama,
                                      "nama": d.nama!,
                                      "id_shift": d.idShift!,
                                      "nama_shift": d.namaShift!,
                                      "id_user": d.idUser!,
                                      "kode_cabang": d.kodeCabang,
                                      "tanggal_masuk": d.tanggalMasuk!,
                                      "tanggal_pulang":
                                          d.tanggalPulang != null
                                              ? d.tanggalPulang!
                                              : "",
                                      "sts_masuk": stsMasuk,
                                      "sts_pulang": stsPulang,
                                      "jam_masuk": d.jamMasuk,
                                      "jam_pulang": d.jamPulang,
                                      "jam_absen_masuk": d.jamAbsenMasuk!,
                                      "jam_absen_pulang": d.jamAbsenPulang!,
                                      "foto_masuk": d.fotoMasuk!,
                                      "foto_pulang": d.fotoPulang!,
                                      "lat_masuk": d.latMasuk!,
                                      "long_masuk": d.longMasuk!,
                                      "lat_pulang": d.latPulang!,
                                      "long_pulang": d.longPulang!,
                                      "device_info": d.devInfo!,
                                      "device_info2": d.devInfo2!,
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

String safe(String? v, [String fallback = '-']) {
  if (v == null || v.isEmpty) return fallback;
  return v;
}
