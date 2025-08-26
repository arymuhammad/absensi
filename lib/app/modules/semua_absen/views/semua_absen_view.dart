import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/semua_absen/views/widget/list_item_data.dart';
import 'package:absensi/app/modules/semua_absen/views/widget/table_calendar.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/semua_absen_controller.dart';

class SemuaAbsenView extends GetView<SemuaAbsenController> {
  SemuaAbsenView({super.key, this.data});
  final absenC = Get.put(AbsenController());
  final Data? data;
  // final String? foto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // const CsBgImg(
          // ),
          Container(
            height: 250,
            decoration: const BoxDecoration(color: AppColors.itemsBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 110, left: 7.0, right: 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(
                    () => SizedBox(
                      height:
                          absenC.calendarFormat.value == CalendarFormat.month
                              ? 394
                              : absenC.calendarFormat.value ==
                                  CalendarFormat.twoWeeks
                              ? 200
                              : 150,
                      child: WidgetTblCalendar(userData: data!),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Attendance',
                        style: titleTextStyle.copyWith(fontSize: 15),
                      ),
                      // Text(FormatWaktu.formatBulan(tanggal:  absenC.selectedDate.value.toString()))
                    ],
                  ),
                ),
                Obx(() {
                  // Ambil variabel dari controller (supaya mudah dan hanya akses sekali)
                  final selected = absenC.selectedDate.value;
                  final rangeMode = absenC.rangeSelectionMode.value;
                  final rangeStart = absenC.rangeStart.value;
                  final rangeEnd = absenC.rangeEnd.value;
                  final isLoading = absenC.isLoading.value;

                  // Filter data sesuai kondisi range atau selected
                  final filteredAbsen = () {
                    if (rangeMode == RangeSelectionMode.toggledOn &&
                        rangeStart != null &&
                        rangeEnd != null) {
                      return absenC.searchAbsen.where((absen) {
                        final absenDate = DateTime.parse(absen.tanggalMasuk!);
                        return !absenDate.isBefore(rangeStart) &&
                            !absenDate.isAfter(rangeEnd);
                      }).toList();
                    } else if (selected != null) {
                      return absenC.searchAbsen.where((absen) {
                        final absenDate = DateTime.parse(absen.tanggalMasuk!);
                        return isSameDay(absenDate, selected);
                      }).toList();
                    } else {
                      // Tampilkan semua data saat tidak ada filter tanggal/range
                      return absenC.searchAbsen;
                    }
                  }();

                  return Expanded(
                    flex: 1,
                    child:
                        isLoading
                            ? SizedBox(
                              width: Get.mediaQuery.size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Loading data...   '),
                                  Platform.isAndroid
                                      ? const CircularProgressIndicator()
                                      : const CupertinoActivityIndicator(),
                                ],
                              ),
                            )
                            : CustomMaterialIndicator(
                              onRefresh: () async {
                                await absenC.getAllAbsen(data!.id!, '', '');
                                absenC.searchDate.value = "";

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
                                                    : math.min(
                                                      controller.value,
                                                      1.0,
                                                    ),
                                          )
                                          : const CupertinoActivityIndicator(),
                                );
                              },
                              child:
                                  filteredAbsen.isEmpty
                                      ? ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          SizedBox(
                                            height:
                                                absenC.calendarFormat.value ==
                                                        CalendarFormat.month
                                                    ? Get.size.height * 0.1
                                                    : absenC
                                                            .calendarFormat
                                                            .value ==
                                                        CalendarFormat.twoWeeks
                                                    ? Get.size.height * 0.3
                                                    : Get.size.height * 0.4,
                                            child: const Center(
                                              child: Text(
                                                'No data presence today',
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      :
                                      // ListView.builder(
                                      //   padding: const EdgeInsets.all(8),
                                      //   physics:
                                      //       const AlwaysScrollableScrollPhysics(),
                                      //   itemCount: filteredAbsen.length,
                                      //   itemBuilder: (context, index) {
                                      //     final absen = filteredAbsen[index];
                                      ListItemData(
                                        data: filteredAbsen,
                                        // Asumsi ListItemData menerima List
                                        userData: data!,
                                      ),
                              // },
                              // ),
                            ),
                  );
                }),
              ],
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(
                    CupertinoIcons.doc_text_search,
                    size: 25,
                    color: AppColors.contentColorWhite,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'History',
                  style: titleTextStyle.copyWith(
                    fontSize: 18,
                    color: AppColors.contentColorWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(
            () => Visibility(
              visible: absenC.searchAbsen.isNotEmpty ? true : false,
              child: FloatingActionButton(
                heroTag: 'pdf',
                backgroundColor: Colors.redAccent[700],
                onPressed: () async {
                  if (absenC.searchAbsen.isNotEmpty) {
                    loadingDialog(
                      'Please wait until',
                      'Data is ready to print',
                    );
                    await absenC.exportPdf();
                    Get.back();
                  } else {
                    showToast('Empty attendance data');
                  }
                },
                child: const Icon(
                  FontAwesome.file_pdf_solid,
                  color: AppColors.mainTextColor1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
