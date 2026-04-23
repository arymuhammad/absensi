import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/duration_count.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/home/views/widget/summary_today.dart';
import 'package:absensi/app/modules/shared/history_card.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../detail_absen/views/detail_visit_view.dart';
import '../../login/controllers/login_controller.dart';
import '../../shared/history_card_shimmer.dart';
import 'main_menu.dart';

class SummaryAbsenArea extends GetView {
  SummaryAbsenArea({super.key});

  final auth = Get.find<LoginController>();
  final absenC = Get.find<AbsenController>();

  @override
  Widget build(BuildContext context) {
    final userData = auth.logUser.value;
    return Expanded(
      child: Column(
        children: [
          SummaryToday(listDataUser: userData),
          const SizedBox(height: 5),
          Expanded(
            child: CustomMaterialIndicator(
              onRefresh: () async {
                var paramSingleVisit = {
                  "mode": "single",
                  "id_user": userData.id,
                  "tgl_visit": absenC.realDateServer,
                };
                var paramLimitVisit = {
                  "mode": "limit",
                  "id_user": userData.id!,
                  "tanggal1": absenC.initDate1,
                  "tanggal2": absenC.initDate2,
                };

                // absenC.isLoading.value = true;
                await absenC.getLimitVisit(paramLimitVisit);
                await absenC.getVisitToday(paramSingleVisit);
                showToast("Page Refreshed");
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
                  // const SizedBox(height: 5),
                  MainMenu(userData: userData),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
                        child: Text(
                          'Visit History',
                          style: titleTextStyle.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () =>
                        absenC.isLoading.value && absenC.dataLimitVisit.isEmpty
                            ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return const HistoryCardShimmer();
                              },
                            )
                            : absenC.dataLimitVisit.isEmpty
                            ? SizedBox(
                              height: Get.size.height / 3,
                              child: const Center(
                                child: Text('There is no visit history yet'),
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder:
                                  (context, index) => const SizedBox(height: 0),
                              itemCount: absenC.dataLimitVisit.length,
                              itemBuilder: (c, i) {
                                final data = absenC.dataLimitVisit[i];

                                return InkWell(
                                  onTap: () {
                                    var detailData = {
                                      "foto_profil":
                                          userData.foto != ""
                                              ? userData.foto
                                              : userData.nama,
                                      "nama": data.nama!,
                                      "id_user": data.id!,
                                      "store": data.namaCabang!,
                                      "tgl_visit": data.tglVisit!,
                                      "jam_in": data.jamIn!,
                                      "foto_in": data.fotoIn!,
                                      "jam_out":
                                          data.jamOut != "" ? data.jamOut! : "",
                                      "foto_out":
                                          data.fotoOut != ""
                                              ? data.fotoOut!
                                              : "",
                                      "lat_in": data.latIn!,
                                      "long_in": data.longIn!,
                                      "lat_out":
                                          data.latOut != "" ? data.latOut! : "",
                                      "long_out":
                                          data.longOut != ""
                                              ? data.longOut!
                                              : "",
                                      "device_info": data.deviceInfo!,
                                      "device_info2":
                                          data.deviceInfo2 != ""
                                              ? data.deviceInfo2
                                              : "",
                                    };
                                    //   Get.to(() {

                                    //   return DetailVisitView(detailData);
                                    // }, transition: Transition.cupertino);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => DetailVisitView(detailData),
                                      ),
                                    );
                                  },
                                  child: HistoryCard(
                                    date: DateTime.parse(data.tglVisit!),
                                    checkIn: safe(data.jamIn),
                                    checkOut: safe(data.jamOut),
                                    duration: hitungDurasiFull(
                                      tglMasuk: data.tglVisit,
                                      jamMasuk: data.jamIn,
                                      tglPulang: data.tglVisit,
                                      jamPulang: data.jamOut,
                                    ),
                                    location: safe(data.namaCabang),
                                    stsM: '',
                                    stsP: '',
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
