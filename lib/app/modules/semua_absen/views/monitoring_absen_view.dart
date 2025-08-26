import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/model/login_model.dart';
import 'search_form.dart';

class MonitoringAbsenView extends GetView {
  MonitoringAbsenView({super.key, this.userData});
  final absenC = Get.find<AbsenController>();
  final Data? userData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Monitoring Absen',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        // elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
                    controller: absenC.filterAbsen,
                    onChanged: (data) => absenC.filterDataAbsen(data),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari berdasarkan tanggal',
                      labelText: 'Cari Absen',
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
                        absenC.searchDate.value != ""
                            ? absenC.searchDate.value
                            : absenC.thisMonth,
                        style: TextStyle(color: mainColor, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(color: Colors.white, thickness: 2),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Obx(
                  () => Visibility(
                    visible: absenC.userMonitor.value != "" ? true : false,
                    child: Text(
                      'Absensi ${absenC.userMonitor.value != "" ? absenC.userMonitor.value : ""}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  return absenC.isLoading.value
                      ? ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 20.0,
                          left: 20.0,
                          right: 20.0,
                        ),
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
                      : absenC.searchAbsen.isEmpty
                      ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: Get.size.height / 3),
                            child: const Column(
                              children: [
                                Center(child: Text('Belum ada data absen')),
                              ],
                            ),
                          ),
                        ],
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                          bottom: 20.0,
                          left: 20.0,
                          right: 20.0,
                        ),
                        itemCount: absenC.searchAbsen.length,
                        itemBuilder: (c, i) {
                          return InkWell(
                            onTap: () {
                              // absenC.searchAbsen;
                              // Get.toNamed(Routes.DETAIL_ABSEN,
                              //     arguments: {
                              //       "foto_profil":
                              //           Get.arguments['foto_profil'],
                              //       "nama": absenC.searchAbsen[i].nama!,
                              //       "nama_shift":
                              //           absenC.searchAbsen[i].namaShift!,
                              //       "id_user":
                              //           absenC.searchAbsen[i].idUser!,
                              //       "tanggal_masuk": absenC
                              //           .searchAbsen[i].tanggalMasuk!,
                              //       "tanggal_pulang": absenC
                              //                   .searchAbsen[i]
                              //                   .tanggalPulang !=
                              //               null
                              //           ? absenC
                              //               .searchAbsen[i].tanggalPulang!
                              //           : "",
                              //       "jam_masuk": DateFormat("HH:mm")
                              //               .parse(absenC.searchAbsen[i]
                              //                   .jamAbsenMasuk!)
                              //               .isBefore(DateFormat("HH:mm")
                              //                   .parse(absenC
                              //                       .searchAbsen[i]
                              //                       .jamMasuk!))
                              //           ? "Awal Waktu"
                              //           : DateFormat("HH:mm")
                              //                   .parse(absenC
                              //                       .searchAbsen[i]
                              //                       .jamAbsenMasuk!)
                              //                   .isAtSameMomentAs(
                              //                       DateFormat("HH:mm")
                              //                           .parse(absenC
                              //                               .searchAbsen[i]
                              //                               .jamMasuk!))
                              //               ? "Tepat Waktu"
                              //               : "Telat",
                              //       "jam_pulang": absenC.searchAbsen[i]
                              //                   .jamAbsenPulang! ==
                              //               ""
                              //           ? "Belum Absen"
                              //           : DateFormat("HH:mm")
                              //                   .parse(absenC
                              //                       .searchAbsen[i]
                              //                       .jamAbsenPulang!)
                              //                   .isBefore(
                              //                       DateFormat("HH:mm")
                              //                           .parse("06:00"))
                              //               ? "Lembur"
                              //               : DateFormat("HH:mm")
                              //                       .parse(absenC
                              //                           .searchAbsen[i]
                              //                           .jamAbsenPulang!)
                              //                       .isBefore(DateFormat("HH:mm")
                              //                           .parse(absenC
                              //                               .searchAbsen[i]
                              //                               .jamPulang!))
                              //                   ? "Pulang Cepat"
                              //                   : "Lembur",
                              //       "jam_absen_masuk": absenC
                              //           .searchAbsen[i].jamAbsenMasuk!,
                              //       "jam_absen_pulang": absenC
                              //           .searchAbsen[i].jamAbsenPulang!,
                              //       "foto_masuk":
                              //           absenC.searchAbsen[i].fotoMasuk!,
                              //       "foto_pulang":
                              //           absenC.searchAbsen[i].fotoPulang!,
                              //       "lat_masuk":
                              //           absenC.searchAbsen[i].latMasuk!,
                              //       "long_masuk":
                              //           absenC.searchAbsen[i].longMasuk!,
                              //       "lat_pulang":
                              //           absenC.searchAbsen[i].latPulang!,
                              //       "long_pulang":
                              //           absenC.searchAbsen[i].longPulang!,
                              //       "device_info":
                              //           absenC.searchAbsen[i].devInfo!,
                              //       "device_info2":
                              //           absenC.searchAbsen[i].devInfo2!,
                              //     });
                              // absenC.filterAbsen.clear();
                              // absenC.filterDataAbsen("");
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: Get.mediaQuery.size.height / 12,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          DateFormat("HH:mm")
                                                  .parse(
                                                    absenC
                                                        .searchAbsen[i]
                                                        .jamAbsenMasuk!,
                                                  )
                                                  .isBefore(
                                                    DateFormat("HH:mm").parse(
                                                      absenC
                                                          .searchAbsen[i]
                                                          .jamMasuk!,
                                                    ),
                                                  )
                                              ? Colors.greenAccent[700]
                                              : DateFormat("HH:mm")
                                                  .parse(
                                                    absenC
                                                        .searchAbsen[i]
                                                        .jamAbsenMasuk!,
                                                  )
                                                  .isAtSameMomentAs(
                                                    DateFormat("HH:mm").parse(
                                                      absenC
                                                          .searchAbsen[i]
                                                          .jamMasuk!,
                                                    ),
                                                  )
                                              ? Colors.greenAccent[700]
                                              : Colors.redAccent[700],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    children: [
                                      Text(
                                        DateFormat('MMM')
                                            .format(
                                              DateTime.parse(
                                                absenC
                                                    .searchAbsen[i]
                                                    .tanggalMasuk!,
                                              ),
                                            )
                                            .toUpperCase(),
                                        style: TextStyle(color: subTitleColor),
                                      ),
                                      Text(
                                        DateFormat('dd').format(
                                          DateTime.parse(
                                            absenC.searchAbsen[i].tanggalMasuk!,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: titleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    children: [
                                      Text(
                                        DateFormat("EEEE", "id_ID").format(
                                          DateTime.parse(
                                            absenC.searchAbsen[i].tanggalMasuk!,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: titleColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        DateFormat("HH:mm")
                                                .parse(
                                                  absenC
                                                      .searchAbsen[i]
                                                      .jamAbsenMasuk!,
                                                )
                                                .isBefore(
                                                  DateFormat("HH:mm").parse(
                                                    absenC
                                                        .searchAbsen[i]
                                                        .jamMasuk!,
                                                  ),
                                                )
                                            ? "Awal Waktu"
                                            : DateFormat("HH:mm")
                                                .parse(
                                                  absenC
                                                      .searchAbsen[i]
                                                      .jamAbsenMasuk!,
                                                )
                                                .isAtSameMomentAs(
                                                  DateFormat("HH:mm").parse(
                                                    absenC
                                                        .searchAbsen[i]
                                                        .jamMasuk!,
                                                  ),
                                                )
                                            ? "Tepat Waktu"
                                            : "Telat",
                                        style: TextStyle(
                                          color:
                                              DateFormat("HH:mm")
                                                      .parse(
                                                        absenC
                                                            .searchAbsen[i]
                                                            .jamAbsenMasuk!,
                                                      )
                                                      .isBefore(
                                                        DateFormat(
                                                          "HH:mm",
                                                        ).parse(
                                                          absenC
                                                              .searchAbsen[i]
                                                              .jamMasuk!,
                                                        ),
                                                      )
                                                  ? Colors.greenAccent[700]
                                                  : DateFormat("HH:mm")
                                                      .parse(
                                                        absenC
                                                            .searchAbsen[i]
                                                            .jamAbsenMasuk!,
                                                      )
                                                      .isAtSameMomentAs(
                                                        DateFormat(
                                                          "HH:mm",
                                                        ).parse(
                                                          absenC
                                                              .searchAbsen[i]
                                                              .jamMasuk!,
                                                        ),
                                                      )
                                                  ? Colors.greenAccent[700]
                                                  : Colors.redAccent[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            const Text('Masuk'),
                                            Text(
                                              absenC
                                                  .searchAbsen[i]
                                                  .jamAbsenMasuk!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: titleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 15),
                                        Column(
                                          children: [
                                            const Text('Pulang'),
                                            Text(
                                              absenC
                                                          .searchAbsen[i]
                                                          .jamAbsenPulang! !=
                                                      ""
                                                  ? absenC
                                                      .searchAbsen[i]
                                                      .jamAbsenPulang!
                                                  : "-",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: titleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                }),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.itemsBackground,
        onPressed: () {
          searchForm(userData!);
        },
        child: const Icon(Iconsax.calendar_search_outline,),
      ),
    );
  }
}
