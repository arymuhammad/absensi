import 'dart:io';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_visit_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../shared/elevated_button_icon.dart';
import 'tools_menu.dart';

class SummaryAbsenArea extends GetView {
  SummaryAbsenArea({super.key, this.userData});
  final Data? userData;
  final absenC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () async {
            var paramLimitVisit = {
              "mode": "limit",
              "id_user": userData!.id,
              "tanggal1": absenC.initDate1,
              "tanggal2": absenC.initDate2
            };

            var paramSingleVisit = {
              "mode": "single",
              "id_user": userData!.id,
              "tgl_visit": absenC.dateNow
            };
            absenC.isLoading.value = true;
            await absenC.getVisitToday(paramSingleVisit);
            await absenC.getLimitVisit(paramLimitVisit);

            showToast("Halaman Disegarkan.");
          });
        },
        child: Column(
          // padding: const EdgeInsets.only(top: 20),
          // shrinkWrap: true,
          // physics: const AlwaysScrollableScrollPhysics(),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Bootstrap.calendar3,
                                size: 17,
                                color: mainColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                  DateFormat("EEEE, d MMMM yyyy", "id_ID")
                                      .format(DateTime.parse(absenC.dateNow))
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.map_location_dot_solid,
                                size: 17,
                                color: mainColor,
                              ),
                              const SizedBox(width: 5),
                              Obx(
                                () => Text(
                                  absenC.dataVisit.isNotEmpty &&
                                          absenC.dataVisit[0].namaCabang! != ""
                                      ? absenC.dataVisit[0].namaCabang!
                                      : '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 1,
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
                                      absenC.dataVisit.isNotEmpty &&
                                              absenC.dataVisit[0].jamIn! != ""
                                          ? absenC.dataVisit[0].jamIn!
                                          : '-:-',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: absenC.dataVisit.isNotEmpty &&
                                                  absenC.dataVisit[0].jamIn! !=
                                                      ""
                                              ? green
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
                                      absenC.dataVisit.isNotEmpty &&
                                              absenC.dataVisit[0].jamOut! != ""
                                          ? absenC.dataVisit[0].jamOut!
                                          : '-:-',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: absenC.dataVisit.isNotEmpty &&
                                                  absenC.dataVisit[0].jamOut! !=
                                                      ""
                                              ? green
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
                                if (absenC.dataVisit.isNotEmpty &&
                                    absenC.dataVisit[0].jamOut != "") {
                                  diffHours = DateTime.parse(
                                          '${absenC.dataVisit[0].tglVisit!} ${absenC.dataVisit[0].jamOut!}')
                                      .difference(DateTime.parse(
                                          '${absenC.dataVisit[0].tglVisit!} ${absenC.dataVisit[0].jamIn!}'));
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
                                        absenC.dataVisit.isNotEmpty &&
                                                absenC.dataVisit[0].jamIn! != ""
                                            ? '${absenC.dataVisit[0].jamOut != "" ? diffHours.inHours : '0'}j ${absenC.dataVisit[0].jamOut != "" ? diffHours.inMinutes % 60 : '0'}m'
                                            : '-:-',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                absenC.dataVisit.isNotEmpty &&
                                                        absenC.dataVisit[0]
                                                                .jamIn! !=
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
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Kunjungan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Obx(
                        () => CsElevatedButtonIcon(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                          ),
                          label:
                              'Resend ${absenC.timerStat.value == true ? '(${absenC.remainingSec.value})' : ''}',
                          onPressed: absenC.timerStat.value == true ||absenC.dataVisit.isEmpty
                              ? null
                              : () async {
                                  if (absenC.dataVisit.isEmpty) {
                                    absenC.startTimer(0);
                                    showToast("Tidak ada data visit hari ini");
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
                        : absenC.dataLimitVisit.isEmpty
                            ? SizedBox(
                                height: Get.size.height / 3,
                                child: const Center(
                                  child: Text('Belum ada riwayat kunjungan'),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 8),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: absenC.dataLimitVisit.length,
                                itemBuilder: (c, i) {
                                  var diffHours = const Duration();
                                  if (absenC.dataLimitVisit[i].jamOut != "") {
                                    diffHours = DateTime.parse(
                                            '${absenC.dataLimitVisit[i].tglVisit!} ${absenC.dataLimitVisit[i].jamOut!}')
                                        .difference(DateTime.parse(
                                            '${absenC.dataLimitVisit[i].tglVisit!} ${absenC.dataLimitVisit[i].jamIn!}'));
                                  } else {
                                    diffHours = const Duration();
                                  }

                                  return InkWell(
                                    onTap: () => Get.to(() => DetailVisitView(),
                                        arguments: {
                                          "foto_profil": userData!.foto != ""
                                              ? userData!.foto
                                              : userData!.nama,
                                          "nama":
                                              absenC.dataLimitVisit[i].nama!,
                                          "store": absenC
                                              .dataLimitVisit[i].namaCabang!,
                                          "id_user":
                                              absenC.dataLimitVisit[i].id!,
                                          "tgl_visit": absenC
                                              .dataLimitVisit[i].tglVisit!,
                                          "jam_in":
                                              absenC.dataLimitVisit[i].jamIn!,
                                          "foto_in":
                                              absenC.dataLimitVisit[i].fotoIn!,
                                          "jam_out": absenC.dataLimitVisit[i]
                                                      .jamOut !=
                                                  ""
                                              ? absenC.dataLimitVisit[i].jamOut!
                                              : "",
                                          "foto_out": absenC.dataLimitVisit[i]
                                                      .fotoOut !=
                                                  ""
                                              ? absenC
                                                  .dataLimitVisit[i].fotoOut!
                                              : "",
                                          "lat_in":
                                              absenC.dataLimitVisit[i].latIn!,
                                          "long_in":
                                              absenC.dataLimitVisit[i].longIn!,
                                          "lat_out": absenC.dataLimitVisit[i]
                                                      .latOut !=
                                                  ""
                                              ? absenC.dataLimitVisit[i].latOut!
                                              : "",
                                          "long_out": absenC.dataLimitVisit[i]
                                                      .longOut !=
                                                  ""
                                              ? absenC
                                                  .dataLimitVisit[i].longOut!
                                              : "",
                                          "device_info": absenC
                                              .dataLimitVisit[i].deviceInfo!,
                                          "device_info2": absenC
                                                      .dataLimitVisit[i]
                                                      .deviceInfo2 !=
                                                  ""
                                              ? absenC
                                                  .dataLimitVisit[i].deviceInfo2
                                              : ""
                                        }),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      DateFormat('MMM')
                                                          .format(DateTime
                                                              .parse(absenC
                                                                  .dataLimitVisit[
                                                                      i]
                                                                  .tglVisit!))
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color: subTitleColor),
                                                    ),
                                                    Text(
                                                      DateFormat('dd').format(
                                                          DateTime.parse(absenC
                                                              .dataLimitVisit[i]
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
                                                        DateFormat("EEEE",
                                                                "id_ID")
                                                            .format(DateTime
                                                                .parse(absenC
                                                                    .dataLimitVisit[
                                                                        i]
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
                                                              absenC
                                                                  .dataLimitVisit[
                                                                      i]
                                                                  .namaCabang!,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ],
                                                      ),
                                                    ),
                                                    // Text(
                                                    //   absenC
                                                    //       .dataLimitVisit[i].namaCabang!,
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
                                                          color:
                                                              Colors.lightBlue,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                            '${absenC.dataLimitVisit[i].jamOut != "" ? diffHours.inHours : '-'} jam ${absenC.dataLimitVisit[i].jamOut != "" ? diffHours.inMinutes % 60 : '-'} menit'),
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
                                                            absenC
                                                                .dataLimitVisit[
                                                                    i]
                                                                .jamIn!,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    titleColor),
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
                                                            absenC
                                                                        .dataLimitVisit[
                                                                            i]
                                                                        .jamOut! !=
                                                                    ""
                                                                ? absenC
                                                                    .dataLimitVisit[
                                                                        i]
                                                                    .jamOut!
                                                                : "-",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    titleColor),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            i == 0 &&
                                                    absenC.statsCon.value != ""
                                                ? Container(
                                                    width: Get
                                                        .mediaQuery.size.width,
                                                    decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            118, 255, 139, 128),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                  );
                                },
                              ),
                  )
                ])),
          ],
        ),
      ),
    );
  }
}
