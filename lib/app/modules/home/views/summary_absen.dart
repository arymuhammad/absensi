import 'dart:io';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_absen_view.dart';
import 'package:absensi/app/modules/shared/container.dart';
import 'package:absensi/app/modules/shared/elevated_button_icon.dart';
import 'package:absensi/app/modules/shared/rounded_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'tools_menu.dart';

class SummaryAbsen extends GetView {
  SummaryAbsen({super.key, this.userData});
  final Data? userData;
  final absenC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () async {
            var paramLimit = {
              "mode": "limit",
              "id_user": userData!.id,
              "tanggal1": absenC.initDate1,
              "tanggal2": absenC.initDate2
            };

            var paramSingle = {
              "mode": "single",
              "id_user": userData!.id,
              "tanggal_masuk":
                  DateFormat('yyyy-MM-dd').format(absenC.tglStream.value)
            };

            absenC.isLoading.value = true;
            await absenC.getAbsenToday(paramSingle);
            await absenC.getLimitAbsen(paramLimit);
            // log(BASEURL.URL, name: 'Base Url');
            // log(BASEURL.PATH, name: 'Base Url path');
            showToast("Page Refreshed");
          });
        },
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Icon(
                            Bootstrap.calendar3,
                            size: 17,
                            color: mainColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                              FormatWaktu.formatIndo(
                                  tanggal: absenC.tglStream.value),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: mainColor),
                                child: const Icon(
                                  Icons.login_rounded,
                                  size: 20,
                                  color: Colors.white,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(
                              () => absenC.isLoading.value
                                  ? Platform.isAndroid
                                      ? const SizedBox(
                                          height: 17,
                                          width: 17,
                                          child: CircularProgressIndicator())
                                      : const SizedBox(
                                          height: 17,
                                          width: 17,
                                          child: CupertinoActivityIndicator())
                                  : Text(
                                      absenC.dataAbsen.isNotEmpty &&
                                              absenC.dataAbsen[0]
                                                      .jamAbsenMasuk! !=
                                                  ""
                                          ? absenC.dataAbsen[0].jamAbsenMasuk!
                                          : '-:-',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: absenC.dataAbsen.isNotEmpty &&
                                                  absenC.dataAbsen[0].jamAbsenMasuk! !=
                                                      ""
                                              ? FormatWaktu.formatJamMenit(
                                                          jamMenit: absenC
                                                              .dataAbsen[0]
                                                              .jamAbsenMasuk!)
                                                      .isBefore(
                                                          FormatWaktu.formatJamMenit(
                                                              jamMenit: absenC
                                                                  .dataAbsen[0]
                                                                  .jamAbsenMasuk!))
                                                  ? green
                                                  : FormatWaktu.formatJamMenit(
                                                              jamMenit: absenC
                                                                  .dataAbsen[0]
                                                                  .jamAbsenMasuk!)
                                                          .isAtSameMomentAs(
                                                              FormatWaktu.formatJamMenit(jamMenit: absenC.dataAbsen[0].jamAbsenMasuk!))
                                                      ? green
                                                      : red
                                              : defaultColor),
                                    ),
                            ),
                            Text(
                              'Masuk',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: subTitleColor),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.redAccent[700],
                              ),
                              child: Transform.flip(
                                  flipX: true,
                                  flipY: true,
                                  child: const Icon(
                                    Icons.logout,
                                    size: 20,
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(
                              () => absenC.isLoading.value
                                  ? Platform.isAndroid
                                      ? const SizedBox(
                                          height: 17,
                                          width: 17,
                                          child: CircularProgressIndicator())
                                      : const SizedBox(
                                          height: 17,
                                          width: 17,
                                          child: CupertinoActivityIndicator())
                                  : Text(
                                      absenC.dataAbsen.isNotEmpty &&
                                              absenC.dataAbsen[0]
                                                      .jamAbsenPulang! !=
                                                  ""
                                          ? absenC.dataAbsen[0].jamAbsenPulang!
                                          : '-:-',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: absenC.dataAbsen.isNotEmpty &&
                                                  absenC.dataAbsen[0]
                                                          .jamAbsenPulang! !=
                                                      ""
                                              ? DateTime.parse(absenC.dataAbsen[0].tanggalPulang!).isAfter(DateTime.parse(absenC.dataAbsen[0].tanggalMasuk!)) &&
                                                      FormatWaktu.formatJamMenit(
                                                              jamMenit: absenC
                                                                  .dataAbsen[0]
                                                                  .jamAbsenPulang!)
                                                          .isBefore(FormatWaktu.formatJamMenit(
                                                              jamMenit:
                                                                  "08:01"))
                                                  ? green
                                                  : FormatWaktu.formatJamMenit(
                                                              jamMenit: absenC
                                                                  .dataAbsen[0]
                                                                  .jamAbsenPulang!)
                                                          .isBefore(FormatWaktu.formatJamMenit(jamMenit: absenC.dataAbsen[0].jamPulang!))
                                                      ? red
                                                      : FormatWaktu.formatJamMenit(jamMenit: absenC.dataAbsen[0].jamAbsenPulang!).isAtSameMomentAs(FormatWaktu.formatJamMenit(jamMenit: absenC.dataAbsen[0].jamPulang!))
                                                          ? green
                                                          : green
                                              : defaultColor),
                                    ),
                            ),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: subTitleColor),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.greenAccent[700],
                                ),
                                child: const Icon(Icons.hourglass_bottom,
                                    color: Colors.white, size: 20)),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(
                              () {
                                var diffHours = const Duration();
                                if (absenC.dataAbsen.isNotEmpty &&
                                    absenC.dataAbsen[0].jamAbsenPulang != "") {
                                  if (DateTime.parse(
                                          absenC.dataAbsen[0].tanggalPulang!)
                                      .isAfter(DateTime.parse(
                                          absenC.dataAbsen[0].tanggalMasuk!))) {
                                    diffHours = DateTime.parse(
                                            '${absenC.dataAbsen[0].tanggalMasuk!} ${absenC.dataAbsen[0].jamAbsenPulang!}')
                                        .add(const Duration(hours: -1))
                                        .difference(DateTime.parse(
                                            '${absenC.dataAbsen[0].tanggalPulang!} ${absenC.dataAbsen[0].jamAbsenMasuk!}'));
                                  } else {
                                    diffHours = DateTime.parse(
                                            '${absenC.dataAbsen[0].tanggalMasuk!} ${absenC.dataAbsen[0].jamAbsenPulang!}')
                                        .difference(DateTime.parse(
                                            '${absenC.dataAbsen[0].tanggalPulang!} ${absenC.dataAbsen[0].jamAbsenMasuk!}'));
                                  }
                                } else {
                                  diffHours = const Duration();
                                }
                                return absenC.isLoading.value
                                    ? Platform.isAndroid
                                        ? const SizedBox(
                                            height: 17,
                                            width: 17,
                                            child: CircularProgressIndicator())
                                        : const SizedBox(
                                            height: 17,
                                            width: 17,
                                            child: CupertinoActivityIndicator())
                                    : Text(
                                        absenC.dataAbsen.isNotEmpty &&
                                                absenC.dataAbsen[0]
                                                        .jamAbsenMasuk! !=
                                                    ""
                                            ? '${absenC.dataAbsen[0].jamAbsenPulang != "" ? diffHours.inHours % 24 : '-'} j ${absenC.dataAbsen[0].jamAbsenPulang != "" ? diffHours.inMinutes % 60 : '-'} m'
                                            : '-:-',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: absenC
                                                        .dataAbsen.isNotEmpty &&
                                                    absenC.dataAbsen[0]
                                                            .jamAbsenMasuk! !=
                                                        "" &&
                                                    absenC.dataAbsen[0]
                                                            .jamAbsenPulang! !=
                                                        ""
                                                ? green
                                                : defaultColor),
                                      );
                              },
                            ),
                            Text(
                              'Durasi Kerja',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: subTitleColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(
            //   height: 8,
            // ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ToolsMenu(userData: userData!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat kehadiran',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Obx(
                        () => CsElevatedButtonIcon(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                          ),
                          label:
                              'Resend ${absenC.timerStat.value == true ? '(${absenC.remainingSec.value})' : ''}',
                          onPressed: absenC.timerStat.value == true ||
                                  absenC.dataAbsen.isEmpty
                              ? null
                              : () async {
                                  if (absenC.dataAbsen.isEmpty) {
                                    absenC.startTimer(0);
                                    showToast("Tidak ada data absen hari ini");
                                  } else {
                                    loadingDialog("Sending data", "");
                                    absenC.startTimer(20);
                                    absenC.resend();
                                    await Future.delayed(
                                        const Duration(seconds: 2), () {
                                      Get.back();
                                    });
                                  }
                                },
                          size: Size(
                              absenC.timerStat.value == true ? 130 : 105, 18),
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () => absenC.isLoading.value
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
                                      highlightColor: const Color.fromARGB(
                                          255, 238, 238, 238),
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
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey,
                                      highlightColor: const Color.fromARGB(
                                          255, 238, 238, 238),
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
                        : absenC.dataLimitAbsen.isEmpty
                            ? SizedBox(
                                height: Get.size.height / 3,
                                child: const Center(
                                  child: Text('Belum ada riwayat absen'),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 8),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: absenC.dataLimitAbsen.length,
                                itemBuilder: (c, i) {
                                  var stsMasuk = FormatWaktu.formatJamMenit(
                                              jamMenit: absenC.dataLimitAbsen[i]
                                                  .jamAbsenMasuk!)
                                          .isBefore(FormatWaktu.formatJamMenit(
                                              jamMenit: absenC
                                                  .dataLimitAbsen[i].jamMasuk!))
                                      ? "Awal Waktu"
                                      : FormatWaktu.formatJamMenit(
                                                  jamMenit: absenC
                                                      .dataLimitAbsen[i]
                                                      .jamAbsenMasuk!)
                                              .isAtSameMomentAs(
                                                  FormatWaktu.formatJamMenit(
                                                      jamMenit: absenC
                                                          .dataLimitAbsen[i]
                                                          .jamMasuk!))
                                          ? "Tepat Waktu"
                                          : "Telat";
                                  var stsPulang = absenC.dataLimitAbsen[i]
                                              .jamAbsenPulang! ==
                                          ""
                                      ? "Belum Absen"
                                      : DateTime.parse(absenC.dataLimitAbsen[i].tanggalPulang!).isAfter(DateTime.parse(absenC.dataLimitAbsen[i].tanggalMasuk!)) &&
                                              FormatWaktu.formatJamMenit(
                                                      jamMenit: absenC
                                                          .dataLimitAbsen[i]
                                                          .jamAbsenPulang!)
                                                  .isBefore(
                                                      FormatWaktu.formatJamMenit(
                                                          jamMenit: "08:01"))
                                          ? "Lembur"
                                          : FormatWaktu.formatJamMenit(
                                                      jamMenit: absenC
                                                          .dataLimitAbsen[i]
                                                          .jamAbsenPulang!)
                                                  .isBefore(
                                                      FormatWaktu.formatJamMenit(jamMenit: absenC.dataLimitAbsen[i].jamPulang!))
                                              ? "Pulang Cepat"
                                              : FormatWaktu.formatJamMenit(jamMenit: absenC.dataLimitAbsen[i].jamAbsenPulang!).isAtSameMomentAs(FormatWaktu.formatJamMenit(jamMenit: absenC.dataLimitAbsen[i].jamPulang!))
                                                  ? 'Tepat Waktu'
                                                  : "Lembur";

                                  return InkWell(
                                    onTap: () => Get.to(() {
                                      var detailData = {
                                        "foto_profil": userData!.foto != ""
                                            ? userData!.foto
                                            : userData!.nama,
                                        "nama": absenC.dataLimitAbsen[i].nama!,
                                        "nama_shift":
                                            absenC.dataLimitAbsen[i].namaShift!,
                                        "id_user":
                                            absenC.dataLimitAbsen[i].idUser!,
                                        "tanggal_masuk": absenC
                                            .dataLimitAbsen[i].tanggalMasuk!,
                                        "tanggal_pulang": absenC
                                                    .dataLimitAbsen[i]
                                                    .tanggalPulang !=
                                                null
                                            ? absenC.dataLimitAbsen[i]
                                                .tanggalPulang!
                                            : "",
                                        "jam_masuk": stsMasuk,
                                        "jam_pulang": stsPulang,
                                        "jam_absen_masuk": absenC
                                            .dataLimitAbsen[i].jamAbsenMasuk!,
                                        "jam_absen_pulang": absenC
                                            .dataLimitAbsen[i].jamAbsenPulang!,
                                        "foto_masuk":
                                            absenC.dataLimitAbsen[i].fotoMasuk!,
                                        "foto_pulang": absenC
                                            .dataLimitAbsen[i].fotoPulang!,
                                        "lat_masuk":
                                            absenC.dataLimitAbsen[i].latMasuk!,
                                        "long_masuk":
                                            absenC.dataLimitAbsen[i].longMasuk!,
                                        "lat_pulang":
                                            absenC.dataLimitAbsen[i].latPulang!,
                                        "long_pulang": absenC
                                            .dataLimitAbsen[i].longPulang!,
                                        "device_info":
                                            absenC.dataLimitAbsen[i].devInfo!,
                                        "device_info2":
                                            absenC.dataLimitAbsen[i].devInfo2!,
                                      };
                                      return DetailAbsenView(detailData);
                                    }, transition: Transition.cupertino),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: SizedBox(
                                        height: i == 0 &&
                                                absenC.statsCon.value != ""
                                            ? 147
                                            : 110,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    FormatWaktu.formatIndo(
                                                        tanggal: DateTime.parse(
                                                            absenC
                                                                .dataLimitAbsen[
                                                                    i]
                                                                .tanggalMasuk!)),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Row(
                                                    children: [
                                                      CsContainer(
                                                        title: stsMasuk,
                                                        color: stsMasuk ==
                                                                "Telat"
                                                            ? Colors
                                                                .redAccent[700]!
                                                            : Colors.greenAccent[
                                                                700]!,
                                                        textColor: Colors.white,
                                                        fontSize: 11,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      CsContainer(
                                                        title: stsPulang,
                                                        color: stsPulang ==
                                                                    "Pulang Cepat" ||
                                                                stsPulang ==
                                                                    "Belum Absen"
                                                            ? Colors
                                                                .redAccent[700]!
                                                            : Colors.greenAccent[
                                                                700]!,
                                                        textColor: Colors.white,
                                                        fontSize: 11,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                thickness: 2,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      RoundedImage(
                                                        height: 50,
                                                        width: 50,
                                                        foto: absenC
                                                            .dataLimitAbsen[i]
                                                            .fotoMasuk!,
                                                        name: absenC
                                                            .dataLimitAbsen[i]
                                                            .nama!,
                                                        headerProfile: false,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          const Text('MASUK',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16)),
                                                          Text(
                                                            absenC
                                                                .dataLimitAbsen[
                                                                    i]
                                                                .jamAbsenMasuk!,
                                                            style: TextStyle(
                                                                color: stsMasuk ==
                                                                        "Telat"
                                                                    ? red
                                                                    : green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      RoundedImage(
                                                        height: 50,
                                                        width: 50,
                                                        foto: absenC
                                                            .dataLimitAbsen[i]
                                                            .fotoPulang!,
                                                        name: absenC
                                                            .dataLimitAbsen[i]
                                                            .nama!,
                                                        headerProfile: false,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          const Text('PULANG',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16)),
                                                          Text(
                                                            absenC
                                                                .dataLimitAbsen[
                                                                    i]
                                                                .jamAbsenPulang!,
                                                            style: TextStyle(
                                                                color: stsPulang ==
                                                                            "Pulang Cepat" ||
                                                                        stsPulang ==
                                                                            "Belum Absen"
                                                                    ? red
                                                                    : green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              i == 0 &&
                                                      absenC.statsCon.value !=
                                                          ""
                                                  ? Container(
                                                      width: Get.mediaQuery.size
                                                          .width,
                                                      decoration: BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(118,
                                                              255, 139, 128),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          absenC.statsCon.value,
                                                          style: TextStyle(
                                                            color: Colors
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
                                    ),
                                  );
                                },
                              ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
