import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_visit_view.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ternav_icons/ternav_icons.dart';

class RiwayatVisitView extends GetView {
  RiwayatVisitView({super.key, this.userData});

  final List? userData;
  final visitC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RIWAYAT KUNJUNGAN'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/image/bgapp.jpg'), // Gantilah dengan path gambar Anda
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, top: 10.0, right: 15.0, bottom: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 8,
              child: TextField(
                controller: visitC.filterVisit,
                onChanged: (data) => visitC.filterDataVisit(data),
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Store',
                    labelText: 'Cari Data Visit Store',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Periode',
                        style: TextStyle(color: subTitleColor, fontSize: 18)),
                    Text(
                      visitC.searchDate.value != ""
                          ? visitC.searchDate.value
                          : visitC.thisMonth,
                      style: TextStyle(color: mainColor, fontSize: 18),
                    ),
                  ],
                )),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Divider(
              color: Colors.white,
              thickness: 2,
            ),
          ),
          Expanded(
            child: Obx(
              () {
                return visitC.isLoading.value
                    ? ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 20.0, left: 20.0, right: 20.0),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20)),
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
                                          255, 238, 238, 238),
                                      child: Container(
                                        width: 60,
                                        height: 15,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey,
                                      highlightColor: const Color.fromARGB(
                                          255, 238, 238, 238),
                                      child: Container(
                                        width: 130,
                                        height: 15,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor:
                                      const Color.fromARGB(255, 238, 238, 238),
                                  child: Container(
                                    width: 70,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor:
                                      const Color.fromARGB(255, 238, 238, 238),
                                  child: Container(
                                    width: 60,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor:
                                      const Color.fromARGB(255, 238, 238, 238),
                                  child: Container(
                                    width: 70,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : visitC.searchVisit.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () {
                              return Future.delayed(const Duration(seconds: 1),
                                  () async {
                                visitC.isLoading.value = true;
                                await visitC
                                    .getAllVisited(Get.arguments["id_user"]);
                                visitC.searchDate.value = "";
                                showToast("Halaman Disegarkan.");
                              });
                            },
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.size.height / 3),
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
                        : RefreshIndicator(
                            onRefresh: () {
                              return Future.delayed(const Duration(seconds: 1),
                                  () async {
                                visitC.isLoading.value = true;
                                await visitC
                                    .getAllVisited(userData![0]);
                                visitC.searchDate.value = "";
                                showToast("Halaman Disegarkan.");
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: visitC.searchVisit.length,
                                itemBuilder: (c, i) {
                                  var diffHours = const Duration();
                                  if (visitC.searchVisit[i].jamOut != "") {
                                    diffHours = DateTime.parse(
                                            '${visitC.searchVisit[i].tglVisit!} ${visitC.searchVisit[i].jamOut!}')
                                        .difference(DateTime.parse(
                                            '${visitC.searchVisit[i].tglVisit!} ${visitC.searchVisit[i].jamIn!}'));
                                  } else {
                                    diffHours = const Duration();
                                  }

                                  return InkWell(
                                    onTap: () => Get.to(() => DetailVisitView(),
                                        arguments: {
                                          "foto_profil": userData![5] != ""
                                              ? userData![5]
                                              : userData![1],
                                          "nama": visitC.searchVisit[i].nama!,
                                          "id_user": visitC.searchVisit[i].id!,
                                          "store":
                                              visitC.searchVisit[i].namaCabang!,
                                          "tgl_visit":
                                              visitC.searchVisit[i].tglVisit!,
                                          "jam_in":
                                              visitC.searchVisit[i].jamIn!,
                                          "foto_in":
                                              visitC.searchVisit[i].fotoIn!,
                                          "jam_out":
                                              visitC.searchVisit[i].jamOut != ""
                                                  ? visitC
                                                      .searchVisit[i].jamOut!
                                                  : "",
                                          "foto_out": visitC
                                                      .searchVisit[i].fotoOut !=
                                                  ""
                                              ? visitC.searchVisit[i].fotoOut!
                                              : "",
                                          "lat_in":
                                              visitC.searchVisit[i].latIn!,
                                          "long_in":
                                              visitC.searchVisit[i].longIn!,
                                          "lat_out":
                                              visitC.searchVisit[i].latOut != ""
                                                  ? visitC
                                                      .searchVisit[i].latOut!
                                                  : "",
                                          "long_out": visitC
                                                      .searchVisit[i].longOut !=
                                                  ""
                                              ? visitC.searchVisit[i].longOut!
                                              : "",
                                          "device_info":
                                              visitC.searchVisit[i].deviceInfo!,
                                          "device_info2": visitC.searchVisit[i]
                                                      .deviceInfo2 !=
                                                  ""
                                              ? visitC
                                                  .searchVisit[i].deviceInfo2
                                              : ""
                                        }),
                                    child: Card(color: bgContainer,
                                              elevation: 8,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  DateFormat('MMM')
                                                      .format(DateTime.parse(
                                                          visitC.searchVisit[i]
                                                              .tglVisit!))
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: subTitleColor),
                                                ),
                                                Text(
                                                  DateFormat('dd').format(
                                                      DateTime.parse(visitC
                                                          .searchVisit[i]
                                                          .tglVisit!)),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: titleColor),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    DateFormat("EEEE", "id_ID")
                                                        .format(DateTime.parse(
                                                            visitC
                                                                .searchVisit[i]
                                                                .tglVisit!)),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: titleColor)),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  // padding: const EdgeInsets.all(10.0),
                                                  width: Get.mediaQuery.size
                                                          .width *
                                                      0.4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                          visitC.searchVisit[i]
                                                              .namaCabang!,
                                                          textAlign:
                                                              TextAlign.left)
                                                    ],
                                                  ),
                                                ),
                                                // Text(
                                                //   visitC
                                                //       .searchVisit[i].namaCabang!,
                                                //   softWrap: false,
                                                //   overflow: TextOverflow.ellipsis,
                                                //   maxLines: 3,
                                                //   style:
                                                //       TextStyle(color: subTitleColor, fontSize: 14),
                                                // ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.timer_sharp,
                                                      color: Colors.lightBlue,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        '${visitC.searchVisit[i].jamOut != "" ? diffHours.inHours : '-'} jam ${visitC.searchVisit[i].jamOut != "" ? diffHours.inMinutes % 60 : '-'} menit'),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      const Text('Masuk'),
                                                      Text(
                                                        visitC.searchVisit[i]
                                                            .jamIn!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: titleColor),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text('Keluar'),
                                                      Text(
                                                        visitC.searchVisit[i]
                                                                    .jamOut! !=
                                                                ""
                                                            ? visitC
                                                                .searchVisit[i]
                                                                .jamOut!
                                                            : "-",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: titleColor),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.contentDefBtn,
          onPressed: () {
            formFilter(userData![0]);
          },
          child: Icon(
            TernavIcons.lightOutline.calender_3,
            color: AppColors.mainTextColor1,
          )),
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
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0.5),
                          prefixIcon: Icon(TernavIcons.lightOutline.calender_3),
                          hintText: 'Tanggal Awal',
                          border: const OutlineInputBorder()),
                      format: DateFormat("yyyy-MM-dd"),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DateTimeField(
                      controller: visitC.date2,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0.5),
                          prefixIcon: Icon(TernavIcons.lightOutline.calender_3),
                          hintText: 'Tanggal Akhir',
                          border: const OutlineInputBorder()),
                      format: DateFormat("yyyy-MM-dd"),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                    ),
                  )
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
                      backgroundColor: AppColors.contentDefBtn,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minimumSize: Size(Get.size.width / 2, 50)),
                  child: const Text(
                    'SIMPAN',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.mainTextColor1),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
