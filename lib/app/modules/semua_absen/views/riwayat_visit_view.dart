import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_visit_view.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/helper/format_waktu.dart';

class RiwayatVisitView extends GetView {
  RiwayatVisitView({super.key, this.userData});

  final Data? userData;
  final visitC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Visit History',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // const CsBgImg(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  top: 100.0,
                  right: 15.0,
                  bottom: 10,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 8,
                  child: TextField(
                    controller: visitC.filterVisit,
                    onChanged: (data) => visitC.filterDataVisit(data),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Store',
                      labelText: 'Cari Data Visit Store',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Periode',
                        style: TextStyle(color: subTitleColor, fontSize: 18),
                      ),
                      Text(
                        visitC.searchDate.value != ""
                            ? visitC.searchDate.value
                            : visitC.thisMonth,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(color: Colors.white, thickness: 2),
              ),
              Expanded(
                child: Obx(() {
                  return visitC.isLoading.value
                      ? ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
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
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey,
                                      highlightColor: const Color.fromARGB(
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                      borderRadius: BorderRadius.circular(10),
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
                                      borderRadius: BorderRadius.circular(10),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                      : visitC.searchVisit.isEmpty
                      ? CustomMaterialIndicator(
                        onRefresh: () async {
                          visitC.isLoading.value = true;
                          await visitC.getAllVisited(userData!.id!);
                          visitC.searchDate.value = "";

                          showToast("Page Refreshed");

                          // return Future.delayed(
                          //   const Duration(seconds: 1),
                          //   () async {},
                          // );
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
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: Get.size.height / 3,
                              ),
                              child: const Column(
                                children: [
                                  Center(
                                    child: Text('Belum ada data kunjungan'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      : CustomMaterialIndicator(
                        onRefresh: () async {
                          visitC.isLoading.value = true;
                          await visitC.getAllVisited(userData!.id!);
                          visitC.searchDate.value = "";
                          showToast("Page Refreshed");

                          // return Future.delayed(
                          //   const Duration(seconds: 1),
                          //   () async {},
                          // );
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
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: visitC.searchVisit.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 5),
                            itemBuilder: (c, i) {
                              var visit = visitC.searchVisit[i];
                              var diffHours = const Duration();
                              if (visit.jamOut != "") {
                                diffHours = DateTime.parse(
                                  '${visit.tglVisit!} ${visit.jamOut!}',
                                ).difference(
                                  DateTime.parse(
                                    '${visit.tglVisit!} ${visit.jamIn!}',
                                  ),
                                );
                              } else {
                                diffHours = const Duration();
                              }

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  double maxWidth = constraints.maxWidth;
                                  return InkWell(
                                    onTap: () {
                                      var detailData = {
                                        "foto_profil":
                                            userData!.foto != ""
                                                ? userData!.foto
                                                : userData!.nama,
                                        "nama": visit.nama!,
                                        "id_user": visit.id!,
                                        "store": visit.namaCabang!,
                                        "tgl_visit": visit.tglVisit!,
                                        "jam_in": visit.jamIn!,
                                        "foto_in": visit.fotoIn!,
                                        "jam_out":
                                            visit.jamOut != ""
                                                ? visit.jamOut!
                                                : "",
                                        "foto_out":
                                            visit.fotoOut != ""
                                                ? visit.fotoOut!
                                                : "",
                                        "lat_in": visit.latIn!,
                                        "long_in": visit.longIn!,
                                        "lat_out":
                                            visit.latOut != ""
                                                ? visit.latOut!
                                                : "",
                                        "long_out":
                                            visit.longOut != ""
                                                ? visit.longOut!
                                                : "",
                                        "device_info": visit.deviceInfo!,
                                        "device_info2":
                                            visit.deviceInfo2 != ""
                                                ? visitC
                                                    .searchVisit[i]
                                                    .deviceInfo2
                                                : "",
                                      };
                                      Get.to(() => DetailVisitView(detailData));
                                    },
                                    child: Container( width: maxWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      height:
                                          i == 0 && visitC.statsCon.value != ""
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
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
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
                                                              visit.tglVisit!,
                                                        ),
                                                        style: titleTextStyle
                                                            .copyWith(
                                                              fontSize:   maxWidth *
                                                                    0.06,
                                                              color:
                                                                  AppColors
                                                                      .contentColorWhite,
                                                            ),  maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                      ),
                                                      // Hari
                                                      Text(
                                                        FormatWaktu.formatHariEn(
                                                          tanggal:
                                                              visit.tglVisit!,
                                                        ),
                                                        style: subtitleTextStyle
                                                            .copyWith(
                                                              color:
                                                                  Colors.white,
                                                            ),  maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                SizedBox( width: maxWidth * 0.7,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      IntrinsicHeight(
                                                        child: Row(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  visit.jamIn!,
                                                                  style: TextStyle(
                                                                    // color:
                                                                    //     stsMasuk == "Late"
                                                                    //         ? red
                                                                    //         : green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: maxWidth *
                                                                          0.05,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  'Check In',
                                                                  style: TextStyle(
                                                                    fontSize: 14,
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
                                                                  visit.jamOut!,
                                                                  style: TextStyle(
                                                                    // color:
                                                                    //     stsPulang ==
                                                                    //                 "Early" ||
                                                                    //             stsPulang ==
                                                                    //                 "Absent"
                                                                    //         ? red
                                                                    //         : green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:  maxWidth *
                                                                          0.05,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  'Check Out',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    fontSize: 14,
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
                                                                  visitC.searchVisit.isNotEmpty &&
                                                                          visit.jamIn! !=
                                                                              ""
                                                                      ? '${visit.jamOut != "" ? diffHours.inHours % 24 : '-'}j ${visit.jamOut != "" ? diffHours.inMinutes % 60 : '-'}m'
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
                                                                    fontSize: maxWidth * 0.05,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  'Total Hours',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Container( decoration: BoxDecoration(
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
                                                          child: Row(  mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                          children: [
                                                            const Icon(
                                                              HeroIcons.map_pin,
                                                              size: 16,  color:
                                                                    AppColors
                                                                        .contentColorWhite,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              visit
                                                                  .namaCabang!
                                                                  .capitalize!,  style: const TextStyle(
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
                                                    visitC.statsCon.value != ""
                                                ? Container(
                                                  width:
                                                      Get.mediaQuery.size.width,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
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
                                                      visitC.statsCon.value,
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
                      );
                }),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.itemsBackground,
        onPressed: () {
          formFilter(userData!.id);
        },
        child: const Icon(
          Iconsax.calendar_tick_outline,
          color: AppColors.mainTextColor1,
        ),
      ),
    );
  }

  void formFilter(idUser) {
    Get.bottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 10,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      SizedBox(
        height: 140,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DateTimeField(
                      controller: visitC.date1,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0.5),
                        prefixIcon: Icon(Iconsax.calendar_edit_outline),
                        hintText: 'Tanggal Awal',
                        border: OutlineInputBorder(),
                      ),
                      format: DateFormat("yyyy-MM-dd"),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DateTimeField(
                      controller: visitC.date2,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0.5),
                        prefixIcon: Icon(Iconsax.calendar_edit_outline),
                        hintText: 'Tanggal Akhir',
                        border: OutlineInputBorder(),
                      ),
                      format: DateFormat("yyyy-MM-dd"),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: ElevatedButton(
                  onPressed: () async {
                    await visitC.getFilteredVisit(idUser);
                    visitC.date1.clear();
                    visitC.date2.clear();
                    //  Restart.restartApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.itemsBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    minimumSize: Size(Get.size.width / 2, 50),
                  ),
                  child: const Text(
                    'SIMPAN',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.contentColorWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
