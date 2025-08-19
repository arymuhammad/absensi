import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/home/views/widget/summary_today.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/format_waktu.dart';
import '../../detail_absen/views/detail_visit_view.dart';
import 'main_menu.dart';

class SummaryAbsenArea extends GetView {
  SummaryAbsenArea({super.key, this.userData});
  final Data? userData;
  final absenC = Get.find<AbsenController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          var paramSingleVisit = {
            "mode": "single",
            "id_user": userData!.id,
            "tgl_visit": absenC.dateNow,
          };
          var paramLimitVisit = {
            "mode": "limit",
            "id_user": userData!.id!,
            "tanggal1": absenC.initDate1,
            "tanggal2": absenC.initDate2,
          };

          absenC.isLoading.value = true;
          await absenC.getLimitVisit(paramLimitVisit);
          await absenC.getVisitToday(paramSingleVisit);

          showToast("Page Refreshed");
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SummaryToday(listDataUser: userData!),

            const SizedBox(height: 5),
            MainMenu(userData: userData!),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Visit History',
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
                      : absenC.dataLimitVisit.isEmpty
                      ? SizedBox(
                        height: Get.size.height / 3,
                        child: const Center(
                          child: Text('Belum ada riwayat visit'),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemCount: absenC.dataLimitVisit.length,
                        itemBuilder: (c, i) {
                          var diffHours = const Duration();
                          if (absenC.dataLimitVisit.isNotEmpty &&
                              absenC.dataLimitVisit[i].jamOut != "") {
                            if (DateTime.parse(
                              absenC.dataLimitVisit[i].tglVisit!,
                            ).isAfter(
                              DateTime.parse(
                                absenC.dataLimitVisit[i].tglVisit!,
                              ),
                            )) {
                              diffHours = DateTime.parse(
                                    '${absenC.dataLimitVisit[i].tglVisit!} ${absenC.dataLimitVisit[i].jamOut!}',
                                  )
                                  .add(const Duration(hours: -1))
                                  .difference(
                                    DateTime.parse(
                                      '${absenC.dataLimitVisit[i].tglVisit!} ${absenC.dataLimitVisit[i].jamIn!}',
                                    ),
                                  );
                            } else {
                              diffHours = DateTime.parse(
                                '${absenC.dataLimitVisit[i].tglVisit!} ${absenC.dataLimitVisit[i].jamOut!}',
                              ).difference(
                                DateTime.parse(
                                  '${absenC.dataLimitVisit[i].tglVisit!} ${absenC.dataLimitVisit[i].jamIn!}',
                                ),
                              );
                            }
                          } else {
                            diffHours = const Duration();
                          }

                          return InkWell(
                            onTap:
                                () => Get.to(() {
                                  var detailData = {
                                    "foto_profil":
                                        userData!.foto != ""
                                            ? userData!.foto
                                            : userData!.nama,
                                    "nama": absenC.searchVisit[i].nama!,
                                    "id_user": absenC.searchVisit[i].id!,
                                    "store": absenC.searchVisit[i].namaCabang!,
                                    "tgl_visit":
                                        absenC.searchVisit[i].tglVisit!,
                                    "jam_in": absenC.searchVisit[i].jamIn!,
                                    "foto_in": absenC.searchVisit[i].fotoIn!,
                                    "jam_out":
                                        absenC.searchVisit[i].jamOut != ""
                                            ? absenC.searchVisit[i].jamOut!
                                            : "",
                                    "foto_out":
                                        absenC.searchVisit[i].fotoOut != ""
                                            ? absenC.searchVisit[i].fotoOut!
                                            : "",
                                    "lat_in": absenC.searchVisit[i].latIn!,
                                    "long_in": absenC.searchVisit[i].longIn!,
                                    "lat_out":
                                        absenC.searchVisit[i].latOut != ""
                                            ? absenC.searchVisit[i].latOut!
                                            : "",
                                    "long_out":
                                        absenC.searchVisit[i].longOut != ""
                                            ? absenC.searchVisit[i].longOut!
                                            : "",
                                    "device_info":
                                        absenC.searchVisit[i].deviceInfo!,
                                    "device_info2":
                                        absenC.searchVisit[i].deviceInfo2 != ""
                                            ? absenC.searchVisit[i].deviceInfo2
                                            : "",
                                  };

                                  return DetailVisitView(detailData);
                                }, transition: Transition.cupertino),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              height:
                                  i == 0 && absenC.statsCon.value != ""
                                      ? 147
                                      : 85,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 55,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            color: AppColors.itemsBackground,
                                          ),
                                          child: Column(
                                            children: [
                                              // Tanggal
                                              Text(
                                                FormatWaktu.formatTanggal(
                                                  tanggal:
                                                      absenC
                                                          .dataLimitVisit[i]
                                                          .tglVisit!,
                                                ),
                                                style: titleTextStyle.copyWith(
                                                  fontSize: 30,
                                                  color:
                                                      AppColors
                                                          .contentColorWhite,
                                                ),
                                              ),
                                              // Hari
                                              Text(
                                                FormatWaktu.formatHariEn(
                                                  tanggal:
                                                      absenC
                                                          .dataLimitVisit[i]
                                                          .tglVisit!,
                                                ),
                                                style: subtitleTextStyle
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        absenC
                                                            .dataLimitVisit[i]
                                                            .jamIn!,
                                                        style: const TextStyle(
                                                          // color:
                                                          //     stsMasuk == "Late"
                                                          //         ? red
                                                          //         : green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Check In',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 5),
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
                                                            .dataLimitVisit[i]
                                                            .jamOut!,
                                                        style: const TextStyle(
                                                          // color:
                                                          //     stsPulang ==
                                                          //                 "Early" ||
                                                          //             stsPulang ==
                                                          //                 "Absent"
                                                          //         ? red
                                                          //         : green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Check Out',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 5),
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
                                                                    .dataLimitVisit
                                                                    .isNotEmpty &&
                                                                absenC
                                                                        .dataLimitVisit[i]
                                                                        .jamIn! !=
                                                                    ""
                                                            ? '${absenC.dataLimitVisit[i].jamOut != "" ? diffHours.inHours % 24 : '-'}j ${absenC.dataLimitVisit[i].jamOut != "" ? diffHours.inMinutes % 60 : '-'}m'
                                                            : '-:-',
                                                        style: const TextStyle(
                                                          // color:
                                                          //     stsPulang ==
                                                          //                 "Pulang Cepat" ||
                                                          //             stsPulang ==
                                                          //                 "Belum Absen"
                                                          //         ? red
                                                          //         : green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Total Hours',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(
                                                  HeroIcons.map_pin,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  absenC
                                                      .dataLimitVisit[i]
                                                      .namaCabang!
                                                      .capitalize!,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    i == 0 && absenC.statsCon.value != ""
                                        ? Container(
                                          width: Get.mediaQuery.size.width,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              118,
                                              255,
                                              139,
                                              128,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              absenC.statsCon.value,
                                              style: TextStyle(
                                                color: Colors.redAccent[700],
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
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
