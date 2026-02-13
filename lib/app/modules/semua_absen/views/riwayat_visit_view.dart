import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_visit_view.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helper/duration_count.dart';
import '../../shared/history_card.dart';

class RiwayatVisitView extends GetView {
  RiwayatVisitView({super.key, this.userData});

  final Data? userData;
  final visitC = Get.put(AbsenController());
  final Rxn<DateTimeRange> pickedRange = Rxn<DateTimeRange>();
  final Rx<DateTime> pickedMonth = DateTime.now().obs;
  final RxInt selectedTab = 0.obs;
  final scrollC = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visit History',
              style: titleTextStyle.copyWith(
                fontSize: 18,
                color: AppColors.contentColorWhite,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: DateTimeRange(
                    start: pickedMonth.value,
                    end: pickedMonth.value,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.itemsBackground,
                          onPrimary: AppColors.contentColorWhite,
                          surface: AppColors.contentColorWhite,
                          onSurface:  AppColors.contentColorBlack,
                        ), 
                      ),
                      child: child!,
                    );
                  },
                );

                if (range != null) {
                  loadingDialog("memuat data...", "");
                  await visitC.getAllVisited(userData!.id!);
                  Get.back();

                  pickedRange.value = range;
                  selectedTab.value = 1;
                }
              },
              child: const Icon(CupertinoIcons.calendar, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.itemsBackground,
        elevation: 0.0,
       flexibleSpace:Container(decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),)
      ),
      // resizeToAvoidBottomInset: false,
      body: CustomMaterialIndicator(
        onRefresh: () async {
          visitC.resetFilter();
          pickedRange.value = null;
          // selectedTab.value = 0;
          await visitC.getAllVisited(userData!.id!);
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
        child: CustomScrollView(
          controller: scrollC,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            /// 🔥 STICKY TAB
            SliverPersistentHeader(
              pinned: true,
              delegate: HistoryTabHeaderDelegate(
                height: 62, // ⬅️ HARUS SAMA
                child: HistoryRangeTab(
                  selectedIndex: selectedTab,
                  scrollController: scrollC,
                  onSearch: (q) => visitC.searchKeyword.value = q,
                ),
              ),
            ),

            /// 🔹 CONTENT
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: Obx(() {
                final now = DateTime.now();

                DateTime start;
                DateTime end;

                if (selectedTab.value == 0) {
                  /// MINGGU INI
                  final monday = now.subtract(Duration(days: now.weekday - 1));

                  start = DateTime(monday.year, monday.month, monday.day);
                  end = start.add(const Duration(days: 6));
                } else if (selectedTab.value == 1) {
                  /// BULAN DIPILIH
                  if (pickedRange.value != null) {
                    start = pickedRange.value!.start;
                    end = pickedRange.value!.end;
                  } else {
                    start = DateTime(now.year, now.month, 1);
                    end = DateTime(
                      now.year,
                      now.month + 1,
                      1,
                    ).subtract(const Duration(days: 1));
                  }
                } else {
                  /// Search (ALL)
                  start = DateTime(2000);
                  end = DateTime(2100);
                }
                final list =
                    visitC.filterDataVisit.where((e) {
                      final d = DateTime.parse(e.tglVisit ?? '');
                      final date = DateTime(d.year, d.month, d.day);
                      final s = DateTime(start.year, start.month, start.day);
                      final en = DateTime(end.year, end.month, end.day);
                      return !date.isBefore(s) && !date.isAfter(en);
                    }).toList();

                if (visitC.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (list.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('Data not found')),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = list[index];
                    return AnimatedHistoryCard(
                      index: index,
                      child: InkWell(
                        onTap:
                            () => Get.to(() {
                              var detailData = {
                                "foto_profil":
                                    userData!.foto != ""
                                        ? userData!.foto
                                        : userData!.nama,
                                "nama": item.nama!,
                                "id_user": item.id!,
                                "store": item.namaCabang!,
                                "tgl_visit": item.tglVisit!,
                                "jam_in": item.jamIn!,
                                "foto_in": item.fotoIn!,
                                "jam_out":
                                    item.jamOut != "" ? item.jamOut! : "",
                                "foto_out":
                                    item.fotoOut != "" ? item.fotoOut! : "",
                                "lat_in": item.latIn!,
                                "long_in": item.longIn!,
                                "lat_out":
                                    item.latOut != "" ? item.latOut! : "",
                                "long_out":
                                    item.longOut != "" ? item.longOut! : "",
                                "device_info": item.deviceInfo!,
                                "device_info2":
                                    item.deviceInfo2 != ""
                                        ? item.deviceInfo2
                                        : "",
                              };

                              return DetailVisitView(detailData);
                            }, transition: Transition.cupertino),
                        child: HistoryCard(
                          date: DateTime.parse(item.tglVisit!),
                          checkIn: safe(item.jamIn),
                          checkOut: safe(item.jamOut),
                          duration: hitungDurasi(
                            tglMasuk: item.tglVisit,
                            jamMasuk: item.jamIn,
                            tglPulang: item.tglVisit,
                            jamPulang: item.jamOut,
                          ),
                          location: safe(item.namaCabang),
                          stsM: '',
                          stsP: '',
                        ),
                      ),
                    );
                  }, childCount: list.length),
                );
              }),
            ),
            // Stack(
            //   children: [
            //     // const CsBgImg(),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 15.0,
            //             top: 100.0,
            //             right: 15.0,
            //             bottom: 10,
            //           ),
            //           child: Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             elevation: 8,
            //             child: TextField(
            //               controller: visitC.filterVisit,
            //               onChanged: (data) => visitC.filterDataVisit(data),
            //               decoration: InputDecoration(
            //                 prefixIcon: const Icon(Icons.search),
            //                 hintText: 'Store',
            //                 labelText: 'Cari Data Visit Store',
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(10),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            //           child: Obx(
            //             () => Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text(
            //                   'Periode',
            //                   style: TextStyle(
            //                     color: subTitleColor,
            //                     fontSize: 18,
            //                   ),
            //                 ),
            //                 Text(
            //                   visitC.searchDate.value != ""
            //                       ? visitC.searchDate.value
            //                       : visitC.thisMonth,
            //                   style: const TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 18,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //         const Padding(
            //           padding: EdgeInsets.only(left: 20.0, right: 20.0),
            //           child: Divider(color: Colors.white, thickness: 2),
            //         ),
            //         Expanded(
            //           child: Obx(() {
            //             return visitC.isLoading.value
            //                 ? ListView.builder(
            //                   padding: EdgeInsets.zero,
            //                   itemCount: 3,
            //                   itemBuilder: (context, index) {
            //                     return Container(
            //                       margin: const EdgeInsets.only(bottom: 20),
            //                       padding: const EdgeInsets.all(10),
            //                       decoration: BoxDecoration(
            //                         color: Colors.grey[200],
            //                         borderRadius: BorderRadius.circular(20),
            //                       ),
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         children: [
            //                           Row(
            //                             mainAxisAlignment:
            //                                 MainAxisAlignment.spaceBetween,
            //                             children: [
            //                               Shimmer.fromColors(
            //                                 baseColor: Colors.grey,
            //                                 highlightColor: const Color.fromARGB(
            //                                   255,
            //                                   238,
            //                                   238,
            //                                   238,
            //                                 ),
            //                                 child: Container(
            //                                   width: 60,
            //                                   height: 15,
            //                                   decoration: BoxDecoration(
            //                                     color: Colors.white,
            //                                     borderRadius:
            //                                         BorderRadius.circular(10),
            //                                   ),
            //                                 ),
            //                               ),
            //                               Shimmer.fromColors(
            //                                 baseColor: Colors.grey,
            //                                 highlightColor: const Color.fromARGB(
            //                                   255,
            //                                   238,
            //                                   238,
            //                                   238,
            //                                 ),
            //                                 child: Container(
            //                                   width: 130,
            //                                   height: 15,
            //                                   decoration: BoxDecoration(
            //                                     color: Colors.white,
            //                                     borderRadius:
            //                                         BorderRadius.circular(10),
            //                                   ),
            //                                 ),
            //                               ),
            //                             ],
            //                           ),
            //                           const SizedBox(height: 8),
            //                           Shimmer.fromColors(
            //                             baseColor: Colors.grey,
            //                             highlightColor: const Color.fromARGB(
            //                               255,
            //                               238,
            //                               238,
            //                               238,
            //                             ),
            //                             child: Container(
            //                               width: 70,
            //                               height: 15,
            //                               decoration: BoxDecoration(
            //                                 color: Colors.white,
            //                                 borderRadius: BorderRadius.circular(
            //                                   10,
            //                                 ),
            //                               ),
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8),
            //                           Shimmer.fromColors(
            //                             baseColor: Colors.grey,
            //                             highlightColor: const Color.fromARGB(
            //                               255,
            //                               238,
            //                               238,
            //                               238,
            //                             ),
            //                             child: Container(
            //                               width: 60,
            //                               height: 15,
            //                               decoration: BoxDecoration(
            //                                 color: Colors.white,
            //                                 borderRadius: BorderRadius.circular(
            //                                   10,
            //                                 ),
            //                               ),
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8),
            //                           Shimmer.fromColors(
            //                             baseColor: Colors.grey,
            //                             highlightColor: const Color.fromARGB(
            //                               255,
            //                               238,
            //                               238,
            //                               238,
            //                             ),
            //                             child: Container(
            //                               width: 70,
            //                               height: 15,
            //                               decoration: BoxDecoration(
            //                                 color: Colors.white,
            //                                 borderRadius: BorderRadius.circular(
            //                                   10,
            //                                 ),
            //                               ),
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     );
            //                   },
            //                 )
            //                 : visitC.searchVisit.isEmpty
            //                 ? CustomMaterialIndicator(
            //                   onRefresh: () async {
            //                     visitC.isLoading.value = true;
            //                     await visitC.getAllVisited(userData!.id!);
            //                     visitC.searchDate.value = "";

            //                     showToast("Page Refreshed");

            //                     // return Future.delayed(
            //                     //   const Duration(seconds: 1),
            //                     //   () async {},
            //                     // );
            //                   },
            //                   backgroundColor: Colors.white,
            //                   indicatorBuilder: (context, controller) {
            //                     return Padding(
            //                       padding: const EdgeInsets.all(6.0),
            //                       child:
            //                           Platform.isAndroid
            //                               ? CircularProgressIndicator(
            //                                 color: AppColors.itemsBackground,
            //                                 value:
            //                                     controller.state.isLoading
            //                                         ? null
            //                                         : math.min(
            //                                           controller.value,
            //                                           1.0,
            //                                         ),
            //                               )
            //                               : const CupertinoActivityIndicator(),
            //                     );
            //                   },
            //                   child: ListView(
            //                     physics: const AlwaysScrollableScrollPhysics(),
            //                     children: [
            //                       Padding(
            //                         padding: EdgeInsets.only(
            //                           top: Get.size.height / 3,
            //                         ),
            //                         child: const Column(
            //                           children: [
            //                             Center(
            //                               child: Text('Belum ada data kunjungan'),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 )
            //                 : CustomMaterialIndicator(
            //                   onRefresh: () async {
            //                     visitC.isLoading.value = true;
            //                     await visitC.getAllVisited(userData!.id!);
            //                     visitC.searchDate.value = "";
            //                     showToast("Page Refreshed");

            //                     // return Future.delayed(
            //                     //   const Duration(seconds: 1),
            //                     //   () async {},
            //                     // );
            //                   },
            //                   backgroundColor: Colors.white,
            //                   indicatorBuilder: (context, controller) {
            //                     return Padding(
            //                       padding: const EdgeInsets.all(6.0),
            //                       child:
            //                           Platform.isAndroid
            //                               ? CircularProgressIndicator(
            //                                 color: AppColors.itemsBackground,
            //                                 value:
            //                                     controller.state.isLoading
            //                                         ? null
            //                                         : math.min(
            //                                           controller.value,
            //                                           1.0,
            //                                         ),
            //                               )
            //                               : const CupertinoActivityIndicator(),
            //                     );
            //                   },
            //                   child: Padding(
            //                     padding: const EdgeInsets.only(
            //                       left: 20.0,
            //                       right: 20.0,
            //                     ),
            //                     child: ListView.separated(
            //                       padding: EdgeInsets.zero,
            //                       shrinkWrap: true,
            //                       physics: const AlwaysScrollableScrollPhysics(),
            //                       itemCount: visitC.searchVisit.length,
            //                       separatorBuilder:
            //                           (context, index) =>
            //                               const SizedBox(height: 5),
            //                       itemBuilder: (c, i) {
            //                         var visit = visitC.searchVisit[i];
            //                         var diffHours = const Duration();
            //                         if (visit.jamOut != "") {
            //                           diffHours = DateTime.parse(
            //                             '${visit.tglVisit!} ${visit.jamOut!}',
            //                           ).difference(
            //                             DateTime.parse(
            //                               '${visit.tglVisit!} ${visit.jamIn!}',
            //                             ),
            //                           );
            //                         } else {
            //                           diffHours = const Duration();
            //                         }

            //                         return LayoutBuilder(
            //                           builder: (context, constraints) {
            //                             double maxWidth = constraints.maxWidth;
            //                             return InkWell(
            //                               onTap: () {
            //                                 var detailData = {
            //                                   "foto_profil":
            //                                       userData!.foto != ""
            //                                           ? userData!.foto
            //                                           : userData!.nama,
            //                                   "nama": visit.nama!,
            //                                   "id_user": visit.id!,
            //                                   "store": visit.namaCabang!,
            //                                   "tgl_visit": visit.tglVisit!,
            //                                   "jam_in": visit.jamIn!,
            //                                   "foto_in": visit.fotoIn!,
            //                                   "jam_out":
            //                                       visit.jamOut != ""
            //                                           ? visit.jamOut!
            //                                           : "",
            //                                   "foto_out":
            //                                       visit.fotoOut != ""
            //                                           ? visit.fotoOut!
            //                                           : "",
            //                                   "lat_in": visit.latIn!,
            //                                   "long_in": visit.longIn!,
            //                                   "lat_out":
            //                                       visit.latOut != ""
            //                                           ? visit.latOut!
            //                                           : "",
            //                                   "long_out":
            //                                       visit.longOut != ""
            //                                           ? visit.longOut!
            //                                           : "",
            //                                   "device_info": visit.deviceInfo!,
            //                                   "device_info2":
            //                                       visit.deviceInfo2 != ""
            //                                           ? visitC
            //                                               .searchVisit[i]
            //                                               .deviceInfo2
            //                                           : "",
            //                                 };
            //                                 Get.to(
            //                                   () => DetailVisitView(detailData),
            //                                 );
            //                               },
            //                               child: Container(
            //                                 width: maxWidth,
            //                                 decoration: BoxDecoration(
            //                                   borderRadius: BorderRadius.circular(
            //                                     5,
            //                                   ),
            //                                   color: Colors.white,
            //                                 ),
            //                                 height:
            //                                     i == 0 &&
            //                                             visitC.statsCon.value !=
            //                                                 ""
            //                                         ? 147
            //                                         : 85,
            //                                 child: Padding(
            //                                   padding: const EdgeInsets.all(8.0),
            //                                   child: Column(
            //                                     crossAxisAlignment:
            //                                         CrossAxisAlignment.start,
            //                                     children: [
            //                                       Row(
            //                                         children: [
            //                                           Container(
            //                                             width: maxWidth * 0.15,
            //                                             padding:
            //                                                 const EdgeInsets.all(
            //                                                   8,
            //                                                 ),
            //                                             decoration: BoxDecoration(
            //                                               borderRadius:
            //                                                   BorderRadius.circular(
            //                                                     5,
            //                                                   ),
            //                                               color:
            //                                                   AppColors
            //                                                       .itemsBackground,
            //                                             ),
            //                                             child: Column(
            //                                               children: [
            //                                                 // Tanggal
            //                                                 Text(
            //                                                   FormatWaktu.formatTanggal(
            //                                                     tanggal:
            //                                                         visit
            //                                                             .tglVisit!,
            //                                                   ),
            //                                                   style: titleTextStyle
            //                                                       .copyWith(
            //                                                         fontSize:
            //                                                             maxWidth *
            //                                                             0.06,
            //                                                         color:
            //                                                             AppColors
            //                                                                 .contentColorWhite,
            //                                                       ),
            //                                                   maxLines: 1,
            //                                                   overflow:
            //                                                       TextOverflow
            //                                                           .ellipsis,
            //                                                 ),
            //                                                 // Hari
            //                                                 Text(
            //                                                   FormatWaktu.formatHariEn(
            //                                                     tanggal:
            //                                                         visit
            //                                                             .tglVisit!,
            //                                                   ),
            //                                                   style: subtitleTextStyle
            //                                                       .copyWith(
            //                                                         color:
            //                                                             Colors
            //                                                                 .white,
            //                                                       ),
            //                                                   maxLines: 1,
            //                                                   overflow:
            //                                                       TextOverflow
            //                                                           .ellipsis,
            //                                                 ),
            //                                               ],
            //                                             ),
            //                                           ),
            //                                           const SizedBox(width: 12),
            //                                           SizedBox(
            //                                             width: maxWidth * 0.7,
            //                                             child: Column(
            //                                               crossAxisAlignment:
            //                                                   CrossAxisAlignment
            //                                                       .start,
            //                                               children: [
            //                                                 IntrinsicHeight(
            //                                                   child: Row(
            //                                                     children: [
            //                                                       Column(
            //                                                         children: [
            //                                                           Text(
            //                                                             visit
            //                                                                 .jamIn!,
            //                                                             style: TextStyle(
            //                                                               // color:
            //                                                               //     stsMasuk == "Late"
            //                                                               //         ? red
            //                                                               //         : green,
            //                                                               fontWeight:
            //                                                                   FontWeight.bold,
            //                                                               fontSize:
            //                                                                   maxWidth *
            //                                                                   0.05,
            //                                                             ),
            //                                                           ),
            //                                                           const Text(
            //                                                             'Check In',
            //                                                             style: TextStyle(
            //                                                               fontSize:
            //                                                                   14,
            //                                                               color:
            //                                                                   Colors.grey,
            //                                                             ),
            //                                                           ),
            //                                                         ],
            //                                                       ),
            //                                                       const SizedBox(
            //                                                         width: 5,
            //                                                       ),
            //                                                       const VerticalDivider(
            //                                                         color:
            //                                                             Colors
            //                                                                 .grey, // Warna garis
            //                                                         // thickness:
            //                                                         //     1, // Ketebalan garis
            //                                                         width:
            //                                                             25, // Lebar box pembungkus
            //                                                         // indent: 20, // Jarak dari atas
            //                                                         endIndent: 5,
            //                                                       ),
            //                                                       Column(
            //                                                         children: [
            //                                                           Text(
            //                                                             visit
            //                                                                 .jamOut!,
            //                                                             style: TextStyle(
            //                                                               // color:
            //                                                               //     stsPulang ==
            //                                                               //                 "Early" ||
            //                                                               //             stsPulang ==
            //                                                               //                 "Absent"
            //                                                               //         ? red
            //                                                               //         : green,
            //                                                               fontWeight:
            //                                                                   FontWeight.bold,
            //                                                               fontSize:
            //                                                                   maxWidth *
            //                                                                   0.05,
            //                                                             ),
            //                                                           ),
            //                                                           const Text(
            //                                                             'Check Out',
            //                                                             style: TextStyle(
            //                                                               color:
            //                                                                   Colors.grey,
            //                                                               fontSize:
            //                                                                   14,
            //                                                             ),
            //                                                           ),
            //                                                         ],
            //                                                       ),
            //                                                       const SizedBox(
            //                                                         width: 5,
            //                                                       ),
            //                                                       const VerticalDivider(
            //                                                         color:
            //                                                             Colors
            //                                                                 .grey, // Warna garis
            //                                                         // thickness:
            //                                                         //     1, // Ketebalan garis
            //                                                         width:
            //                                                             25, // Lebar box pembungkus
            //                                                         // indent: 20, // Jarak dari atas
            //                                                         endIndent: 5,
            //                                                       ),
            //                                                       Column(
            //                                                         children: [
            //                                                           Text(
            //                                                             visitC.searchVisit.isNotEmpty &&
            //                                                                     visit.jamIn! !=
            //                                                                         ""
            //                                                                 ? '${visit.jamOut != "" ? diffHours.inHours % 24 : '-'}j ${visit.jamOut != "" ? diffHours.inMinutes % 60 : '-'}m'
            //                                                                 : '-:-',
            //                                                             style: TextStyle(
            //                                                               // color:
            //                                                               //     stsPulang ==
            //                                                               //                 "Pulang Cepat" ||
            //                                                               //             stsPulang ==
            //                                                               //                 "Belum Absen"
            //                                                               //         ? red
            //                                                               //         : green,
            //                                                               fontWeight:
            //                                                                   FontWeight.bold,
            //                                                               fontSize:
            //                                                                   maxWidth *
            //                                                                   0.05,
            //                                                             ),
            //                                                           ),
            //                                                           const Text(
            //                                                             'Total Hours',
            //                                                             style: TextStyle(
            //                                                               color:
            //                                                                   Colors.grey,
            //                                                               fontSize:
            //                                                                   14,
            //                                                             ),
            //                                                           ),
            //                                                         ],
            //                                                       ),
            //                                                     ],
            //                                                   ),
            //                                                 ),
            //                                                 const SizedBox(
            //                                                   height: 3,
            //                                                 ),
            //                                                 Container(
            //                                                   decoration: BoxDecoration(
            //                                                     color:
            //                                                         AppColors
            //                                                             .itemsBackground,
            //                                                     borderRadius:
            //                                                         BorderRadius.circular(
            //                                                           8,
            //                                                         ),
            //                                                   ),
            //                                                   padding:
            //                                                       const EdgeInsets.only(
            //                                                         left: 5,
            //                                                         right: 5,
            //                                                       ),
            //                                                   child: Row(
            //                                                     mainAxisSize:
            //                                                         MainAxisSize
            //                                                             .min,
            //                                                     children: [
            //                                                       const Icon(
            //                                                         HeroIcons
            //                                                             .map_pin,
            //                                                         size: 16,
            //                                                         color:
            //                                                             AppColors
            //                                                                 .contentColorWhite,
            //                                                       ),
            //                                                       const SizedBox(
            //                                                         width: 5,
            //                                                       ),
            //                                                       Text(
            //                                                         visit
            //                                                             .namaCabang!
            //                                                             .capitalize!,
            //                                                         style: const TextStyle(
            //                                                           color:
            //                                                               AppColors
            //                                                                   .contentColorWhite,
            //                                                         ),
            //                                                       ),
            //                                                     ],
            //                                                   ),
            //                                                 ),
            //                                               ],
            //                                             ),
            //                                           ),
            //                                         ],
            //                                       ),
            //                                       const SizedBox(height: 2),
            //                                       i == 0 &&
            //                                               visitC.statsCon.value !=
            //                                                   ""
            //                                           ? Container(
            //                                             width:
            //                                                 Get
            //                                                     .mediaQuery
            //                                                     .size
            //                                                     .width,
            //                                             decoration: BoxDecoration(
            //                                               color:
            //                                                   const Color.fromARGB(
            //                                                     118,
            //                                                     255,
            //                                                     139,
            //                                                     128,
            //                                                   ),
            //                                               borderRadius:
            //                                                   BorderRadius.circular(
            //                                                     5,
            //                                                   ),
            //                                             ),
            //                                             child: Padding(
            //                                               padding:
            //                                                   const EdgeInsets.only(
            //                                                     left: 8.0,
            //                                                   ),
            //                                               child: Text(
            //                                                 visitC.statsCon.value,
            //                                                 style: TextStyle(
            //                                                   color:
            //                                                       Colors
            //                                                           .redAccent[700],
            //                                                 ),
            //                                               ),
            //                                             ),
            //                                           )
            //                                           : Container(),
            //                                     ],
            //                                   ),
            //                                 ),
            //                               ),
            //                             );
            //                           },
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                 );
            //           }),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.itemsBackground,
      //   onPressed: () {
      //     formFilter(userData!.id);
      //   },
      //   child: const Icon(
      //     Iconsax.calendar_tick_outline,
      //     color: AppColors.mainTextColor1,
      //   ),
      // ),
    );
  }

  // void formFilter(idUser) {
  //   Get.bottomSheet(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //     elevation: 10,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     SizedBox(
  //       height: 140,
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: DateTimeField(
  //                     controller: visitC.date1,
  //                     style: const TextStyle(fontSize: 14),
  //                     decoration: const InputDecoration(
  //                       contentPadding: EdgeInsets.all(0.5),
  //                       prefixIcon: Icon(Iconsax.calendar_edit_outline),
  //                       hintText: 'Tanggal Awal',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                     format: DateFormat("yyyy-MM-dd"),
  //                     onShowPicker: (context, currentValue) {
  //                       return showDatePicker(
  //                         context: context,
  //                         firstDate: DateTime(1900),
  //                         initialDate: currentValue ?? DateTime.now(),
  //                         lastDate: DateTime(2100),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: DateTimeField(
  //                     controller: visitC.date2,
  //                     style: const TextStyle(fontSize: 14),
  //                     decoration: const InputDecoration(
  //                       contentPadding: EdgeInsets.all(0.5),
  //                       prefixIcon: Icon(Iconsax.calendar_edit_outline),
  //                       hintText: 'Tanggal Akhir',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                     format: DateFormat("yyyy-MM-dd"),
  //                     onShowPicker: (context, currentValue) {
  //                       return showDatePicker(
  //                         context: context,
  //                         firstDate: DateTime(1900),
  //                         initialDate: currentValue ?? DateTime.now(),
  //                         lastDate: DateTime(2100),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 10),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 80),
  //               child: ElevatedButton(
  //                 onPressed: () async {
  //                   await visitC.getFilteredVisit(idUser);
  //                   visitC.date1.clear();
  //                   visitC.date2.clear();
  //                   //  Restart.restartApp();
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.itemsBackground,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(50),
  //                   ),
  //                   minimumSize: Size(Get.size.width / 2, 50),
  //                 ),
  //                 child: const Text(
  //                   'SIMPAN',
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     color: AppColors.contentColorWhite,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class HistoryRangeTab extends StatefulWidget {
  final RxInt selectedIndex;
  final ScrollController scrollController;
  final Function(String) onSearch;

  const HistoryRangeTab({
    super.key,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSearch,
  });

  @override
  State<HistoryRangeTab> createState() => _HistoryRangeTabState();
}

class _HistoryRangeTabState extends State<HistoryRangeTab> {
  final RxBool isSearching = false.obs;
  final TextEditingController searchC = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 52,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(.4)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSearching.value ? _searchField() : _segmentedIOS(),
            ),
          ),
        ),
      );
    });
  }

  // ================= CUPERTINO SEGMENTED =================
  Widget _segmentedIOS() {
    return CupertinoSlidingSegmentedControl<int>(
      key: const ValueKey('segmented'),
      groupValue: widget.selectedIndex.value,
      thumbColor: Colors.white,
      backgroundColor: Colors.transparent,
      children: const {
        0: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('This Week'),
        ),
        1: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('This Month'),
        ),
        2: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(CupertinoIcons.search, size: 18),
        ),
      },
      onValueChanged: (v) {
        if (v == 2) {
          isSearching.value = true;

          /// 🧲 AUTO SCROLL KE ATAS
          widget.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        } else {
          widget.selectedIndex.value = v!;
        }
      },
    );
  }

  // ================= SEARCH EXPAND =================
  Widget _searchField() {
    return Row(
      key: const ValueKey('search'),
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: searchC,
            autofocus: true,
            placeholder: 'Search data...',
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                CupertinoIcons.search,
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        const SizedBox(width: 6),

        GestureDetector(
          onTap: () {
            isSearching.value = false;
            searchC.clear();
            widget.onSearch('');
          },
          child: const Icon(
            CupertinoIcons.clear_circled_solid,
            size: 22,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
}

class HistoryTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  HistoryTabHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant HistoryTabHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

/// 🔥 ANIMATED CARD
class AnimatedHistoryCard extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedHistoryCard({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 40)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

String safe(String? v, [String fallback = '-']) {
  if (v == null || v.isEmpty) return fallback;
  return v;
}
