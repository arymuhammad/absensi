import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../../routes/app_pages.dart';
import '../controllers/semua_absen_controller.dart';
import 'package:intl/intl.dart';

class SemuaAbsenView extends GetView<SemuaAbsenController> {
  SemuaAbsenView({super.key, this.data});
  final absenC = Get.put(AbsenController());
  final List<dynamic>? data;
  // final String? foto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Stack(
        children: [  ClipPath(
          clipper: ClipPathClass(),
          child: Container(
            height: 380,
            width: Get.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/image/bgapp.jpg'),
                    fit: BoxFit.fill)),
          ),
        ),
          Padding(
             padding: const EdgeInsets.only(top: 110, left: 15.0, right: 15.0),
            child: Card(
               elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SizedBox(
                height: 620,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 10.0, right: 15.0, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: Get.mediaQuery.size.width/1.4,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 8,
                              child: TextField(
                                controller: absenC.filterAbsen,
                                onChanged: (data) => absenC.filterDataAbsen(data),
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search),
                                    hintText: 'format thn-bln-tgl',
                                    labelText: 'Cari Absen',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10))),
                              ),
                            ),
                          ),
                           Obx(
            () => absenC.ascending.value
                ? SizedBox(
                  width: 45,height: 65,
                  child: Card(
                    color: mainColor,
                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 8,
                    child: IconButton(
                        tooltip: 'Sort ASC',
                        onPressed: () {
                          absenC.searchAbsen.sort(
                              (a, b) => a.tanggalMasuk!.compareTo(b.tanggalMasuk!));
                          absenC.ascending.value = false;
                        },
                        icon: const Icon(
                          CupertinoIcons.line_horizontal_3_decrease,
                          color: Colors.white,
                        )),
                  ),
                )
                : SizedBox(width: 45,
                height: 65,
                  child: Card(
                    color: mainColor,
                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 8,
                    child: IconButton(
                        tooltip: 'Sort DESC',
                        onPressed: () {
                          absenC.searchAbsen.sort(
                              (a, b) => b.tanggalMasuk!.compareTo(a.tanggalMasuk!));
                          absenC.ascending.value = true;
                        },
                        icon: Transform.rotate(
                          angle: 180 * math.pi / 180,
                          child: const Icon(
                            CupertinoIcons.line_horizontal_3_decrease,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ),
          )
                        ],
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
                                absenC.searchDate.value != ""
                                    ? absenC.searchDate.value
                                    : absenC.thisMonth,
                                style: TextStyle(color: mainColor, fontSize: 18),
                              ),
                            ],
                          )),
                    ),
                     Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Divider(
                        color: subTitleColor,
                        thickness: 1,
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () {
                          return absenC.isLoading.value
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
                              : absenC.searchAbsen.isEmpty
                                  ? RefreshIndicator(
                                      onRefresh: () {
                                        return Future.delayed(const Duration(seconds: 1),
                                            () async {
                                          await absenC
                                              .getAllAbsen(data![0]);
                                          absenC.searchDate.value = "";
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
                                                  child: Text('Belum ada data absen'),
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
                                          await absenC
                                              .getAllAbsen(data![0]);
                                          absenC.searchDate.value = "";
                                          showToast("Halaman Disegarkan.");
                                        });
                                      },
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.only(
                                            bottom: 20.0, left: 20.0, right: 20.0),
                                        itemCount: absenC.searchAbsen.length,
                                        itemBuilder: (c, i) {
                                          return InkWell(
                                            onTap: () {
                                              absenC.searchAbsen;
                                              Get.toNamed(Routes.DETAIL_ABSEN,
                                                  arguments: {
                                                    "foto_profil":
                                                        data![5] != "" ? data![5] : data![1],
                                                    "nama": absenC.searchAbsen[i].nama!,
                                                    "nama_shift":
                                                        absenC.searchAbsen[i].namaShift!,
                                                    "id_user":
                                                        absenC.searchAbsen[i].idUser!,
                                                    "tanggal_masuk": absenC
                                                        .searchAbsen[i].tanggalMasuk!,
                                                    "tanggal_pulang": absenC
                                                                .searchAbsen[i]
                                                                .tanggalPulang !=
                                                            null
                                                        ? absenC
                                                            .searchAbsen[i].tanggalPulang!
                                                        : "",
                                                    "jam_masuk": DateFormat("HH:mm")
                                                            .parse(absenC.searchAbsen[i]
                                                                .jamAbsenMasuk!)
                                                            .isBefore(DateFormat("HH:mm")
                                                                .parse(absenC
                                                                    .searchAbsen[i]
                                                                    .jamMasuk!))
                                                        ? "Awal Waktu"
                                                        : DateFormat("HH:mm")
                                                                .parse(absenC
                                                                    .searchAbsen[i]
                                                                    .jamAbsenMasuk!)
                                                                .isAtSameMomentAs(
                                                                    DateFormat("HH:mm")
                                                                        .parse(absenC
                                                                            .searchAbsen[i]
                                                                            .jamMasuk!))
                                                            ? "Tepat Waktu"
                                                            : "Telat",
                                                    "jam_pulang": absenC.searchAbsen[i]
                                                                .jamAbsenPulang! ==
                                                            ""
                                                        ? "Belum Absen"
                                                        : DateTime.parse(absenC.searchAbsen[i].tanggalPulang!)
                                                                    .isAfter(DateTime.parse(absenC
                                                                        .searchAbsen[i]
                                                                        .tanggalMasuk!)) &&
                                                                DateFormat("HH:mm")
                                                                    .parse(absenC
                                                                        .searchAbsen[i]
                                                                        .jamAbsenPulang!)
                                                                    .isBefore(DateFormat("HH:mm")
                                                                        .parse("08:01"))
                                                            ? "Lembur"
                                                            : DateFormat("HH:mm")
                                                                    .parse(absenC.searchAbsen[i].jamAbsenPulang!)
                                                                    .isBefore(DateFormat("HH:mm").parse(absenC.searchAbsen[i].jamPulang!))
                                                                ? "Pulang Cepat"
                                                                : "Lembur",
                                                    "jam_absen_masuk": absenC
                                                        .searchAbsen[i].jamAbsenMasuk!,
                                                    "jam_absen_pulang": absenC
                                                        .searchAbsen[i].jamAbsenPulang!,
                                                    "foto_masuk":
                                                        absenC.searchAbsen[i].fotoMasuk!,
                                                    "foto_pulang":
                                                        absenC.searchAbsen[i].fotoPulang!,
                                                    "lat_masuk":
                                                        absenC.searchAbsen[i].latMasuk!,
                                                    "long_masuk":
                                                        absenC.searchAbsen[i].longMasuk!,
                                                    "lat_pulang":
                                                        absenC.searchAbsen[i].latPulang!,
                                                    "long_pulang":
                                                        absenC.searchAbsen[i].longPulang!,
                                                    "device_info":
                                                        absenC.searchAbsen[i].devInfo!,
                                                    "device_info2":
                                                        absenC.searchAbsen[i].devInfo2!,
                                                  });
                                              absenC.filterAbsen.clear();
                                              absenC.filterDataAbsen("");
                                            },
                                            child: Card(
                                              color: bgContainer,
                                              elevation: 8,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      width: 10,
                                                      height:
                                                          Get.mediaQuery.size.height / 12,
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color: DateFormat("HH:mm")
                                                                  .parse(absenC
                                                                      .searchAbsen[i]
                                                                      .jamAbsenMasuk!)
                                                                  .isBefore(DateFormat("HH:mm")
                                                                      .parse(absenC
                                                                          .searchAbsen[i]
                                                                          .jamMasuk!))
                                                              ? Colors.greenAccent[700]
                                                              : DateFormat("HH:mm")
                                                                      .parse(absenC
                                                                          .searchAbsen[i]
                                                                          .jamAbsenMasuk!)
                                                                      .isAtSameMomentAs(DateFormat("HH:mm")
                                                                          .parse(absenC.searchAbsen[i].jamMasuk!))
                                                                  ? Colors.greenAccent[700]
                                                                  : Colors.redAccent[700],
                                                          borderRadius: const BorderRadius.only(
                                                            topLeft: Radius.circular(5),
                                                            bottomLeft:
                                                                Radius.circular(5),
                                                          ))),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        DateFormat('MMM')
                                                            .format(DateTime.parse(absenC
                                                                .searchAbsen[i]
                                                                .tanggalMasuk!))
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            color: subTitleColor),
                                                      ),
                                                      Text(
                                                        DateFormat('dd').format(
                                                            DateTime.parse(absenC
                                                                .searchAbsen[i]
                                                                .tanggalMasuk!)),
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
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
                                                                  absenC.searchAbsen[i]
                                                                      .tanggalMasuk!)),
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                              color: titleColor)),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        DateFormat("HH:mm")
                                                                .parse(absenC
                                                                    .searchAbsen[i]
                                                                    .jamAbsenMasuk!)
                                                                .isBefore(DateFormat(
                                                                        "HH:mm")
                                                                    .parse(absenC
                                                                        .searchAbsen[i]
                                                                        .jamMasuk!))
                                                            ? "Awal Waktu"
                                                            : DateFormat("HH:mm")
                                                                    .parse(absenC
                                                                        .searchAbsen[i]
                                                                        .jamAbsenMasuk!)
                                                                    .isAtSameMomentAs(
                                                                        DateFormat("HH:mm")
                                                                            .parse(absenC
                                                                                .searchAbsen[
                                                                                    i]
                                                                                .jamMasuk!))
                                                                ? "Tepat Waktu"
                                                                : "Telat",
                                                        style: TextStyle(
                                                            color: DateFormat("HH:mm")
                                                                    .parse(absenC
                                                                        .searchAbsen[i]
                                                                        .jamAbsenMasuk!)
                                                                    .isBefore(
                                                                        DateFormat("HH:mm")
                                                                            .parse(absenC
                                                                                .searchAbsen[
                                                                                    i]
                                                                                .jamMasuk!))
                                                                ? Colors.greenAccent[700]
                                                                : DateFormat("HH:mm")
                                                                        .parse(absenC
                                                                            .searchAbsen[
                                                                                i]
                                                                            .jamAbsenMasuk!)
                                                                        .isAtSameMomentAs(
                                                                            DateFormat("HH:mm").parse(absenC.searchAbsen[i].jamMasuk!))
                                                                    ? Colors.greenAccent[700]
                                                                    : Colors.redAccent[700]),
                                                      )
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
                                                              absenC.searchAbsen[i]
                                                                  .jamAbsenMasuk!,
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
                                                            const Text('Pulang'),
                                                            Text(
                                                              absenC.searchAbsen[i]
                                                                          .jamAbsenPulang! !=
                                                                      ""
                                                                  ? absenC.searchAbsen[i]
                                                                      .jamAbsenPulang!
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
                                          );
                                        },
                                      ),
                                    );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 60,
            left: 20,
            right: 20,
            bottom: 0,
            child:  Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(
                    CupertinoIcons.doc_text_search,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                 Text(
                  'History',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ), 
               
              ],
            ))
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
                    loadingDialog('Mohon menunggu...', 'Data siap dicetak');
                    if (absenC.searchAbsen.isNotEmpty) {
                      await absenC.exportPdf();
                      Get.back();
                    } else {
                      showToast('Data absensi kosong');
                    }
                  },
                  child: const Icon(
                    FontAwesome.file_pdf_solid,
                    color: AppColors.mainTextColor1,
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
              heroTag: 'form-filter',
              backgroundColor: AppColors.contentDefBtn,
              onPressed: () {
                formFilter(data![0]);
              },
              child: Icon(
                TernavIcons.lightOutline.calender_3,
                color: AppColors.mainTextColor1,
              )),
        ],
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
        height: 185,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cari Data Absensi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: DateTimeField(
                      controller: absenC.date1,
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
                      controller: absenC.date2,
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
                    await absenC.getFilteredAbsen(idUser);
                    absenC.date1.clear();
                    absenC.date2.clear();
                    //  Restart.restartApp();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.contentDefBtn,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minimumSize: Size(Get.size.width / 2, 50)),
                  child: const Text(
                    'CARI',
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
