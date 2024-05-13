import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/modules/detail_absen/views/detail_absen_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class SummaryAbsen extends GetView {
  SummaryAbsen({super.key, this.userData});
  final List? userData;
  final absenC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () async {
            var paramLimit = {
              "mode": "limit",
              "id_user": userData![0],
              "tanggal1": absenC.initDate1,
              "tanggal2": absenC.initDate2
            };

            var paramSingle = {
              "mode": "single",
              "id_user": userData![0],
              "tanggal_masuk":
                  DateFormat('yyyy-MM-dd').format(absenC.tglStream.value)
            };

            absenC.isLoading.value = true;
            await absenC.getAbsenToday(paramSingle);
            await absenC.getLimitAbsen(paramLimit);

            showToast("Halaman Disegarkan.");
          });
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 20),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Obx(
                      () => Text(
                          DateFormat("EEEE, d MMMM yyyy", "id_ID")
                              .format(absenC.tglStream.value)
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          const Icon(Bootstrap.clock, size: 20),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Text(
                              absenC.dataAbsen.isNotEmpty &&
                                      absenC.dataAbsen[0].jamAbsenMasuk! != ""
                                  ? absenC.dataAbsen[0].jamAbsenMasuk!
                                  : '-:-',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: absenC.dataAbsen.isNotEmpty &&
                                          absenC.dataAbsen[0].jamAbsenMasuk! !=
                                              ""
                                      ? timeColor
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
                          Transform.flip(
                              flipX: true,
                              flipY: true,
                              child: const Icon(Bootstrap.clock, size: 20)),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Text(
                              absenC.dataAbsen.isNotEmpty &&
                                      absenC.dataAbsen[0].jamAbsenPulang! != ""
                                  ? absenC.dataAbsen[0].jamAbsenPulang!
                                  : '-:-',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: absenC.dataAbsen.isNotEmpty &&
                                          absenC.dataAbsen[0].jamAbsenPulang! !=
                                              ""
                                      ? timeColor
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
                          const Icon(Bootstrap.clock_history, size: 20),
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
                              return Text(
                                absenC.dataAbsen.isNotEmpty &&
                                        absenC.dataAbsen[0].jamAbsenMasuk! != ""
                                    ? '${absenC.dataAbsen[0].jamAbsenPulang != "" ? diffHours.inHours % 24 : '-'} j ${absenC.dataAbsen[0].jamAbsenPulang != "" ? diffHours.inMinutes % 60 : '-'} m'
                                    : '-:-',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: absenC.dataAbsen.isNotEmpty &&
                                            absenC.dataAbsen[0]
                                                    .jamAbsenMasuk! !=
                                                "" &&
                                            absenC.dataAbsen[0]
                                                    .jamAbsenPulang! !=
                                                ""
                                        ? timeColor
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
            const SizedBox(height: 8),
            const Divider(
              color: Colors.white,
              thickness: 2,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat absen minggu ini',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
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
                                highlightColor:
                                    const Color.fromARGB(255, 238, 238, 238),
                                child: Container(
                                  width: 70,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
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
                                      borderRadius: BorderRadius.circular(10)),
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
                                      borderRadius: BorderRadius.circular(10)),
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
                            return InkWell(
                              onTap: () => Get.to(() => DetailAbsenView(),
                                  arguments: {
                                    "foto_profil": userData![5] != ""
                                        ? userData![5]
                                        : userData![1],
                                    "nama": absenC.dataLimitAbsen[i].nama!,
                                    "nama_shift":
                                        absenC.dataLimitAbsen[i].namaShift!,
                                    "id_user": absenC.dataLimitAbsen[i].idUser!,
                                    "tanggal_masuk":
                                        absenC.dataLimitAbsen[i].tanggalMasuk!,
                                    "tanggal_pulang": absenC.dataLimitAbsen[i]
                                                .tanggalPulang !=
                                            null
                                        ? absenC
                                            .dataLimitAbsen[i].tanggalPulang!
                                        : "",
                                    "jam_masuk": DateFormat("HH:mm")
                                            .parse(absenC.dataLimitAbsen[i]
                                                .jamAbsenMasuk!)
                                            .isBefore(DateFormat("HH:mm").parse(
                                                absenC.dataLimitAbsen[i]
                                                    .jamMasuk!))
                                        ? "Awal Waktu"
                                        : DateFormat("HH:mm")
                                                .parse(absenC.dataLimitAbsen[i]
                                                    .jamAbsenMasuk!)
                                                .isAtSameMomentAs(
                                                    DateFormat("HH:mm").parse(
                                                        absenC.dataLimitAbsen[i]
                                                            .jamMasuk!))
                                            ? "Tepat Waktu"
                                            : "Telat",
                                    "jam_pulang": absenC.dataLimitAbsen[i]
                                                .jamAbsenPulang! ==
                                            ""
                                        ? "Belum Absen"
                                        : DateTime.parse(absenC.dataLimitAbsen[i].tanggalPulang!)
                                                    .isAfter(DateTime.parse(absenC
                                                        .dataLimitAbsen[i]
                                                        .tanggalMasuk!)) &&
                                                DateFormat("HH:mm")
                                                    .parse(absenC
                                                        .dataLimitAbsen[i]
                                                        .jamAbsenPulang!)
                                                    .isBefore(DateFormat("HH:mm")
                                                        .parse("08:01"))
                                            ? "Lembur"
                                            : DateFormat("HH:mm")
                                                    .parse(absenC.dataLimitAbsen[i].jamAbsenPulang!)
                                                    .isBefore(DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamPulang!))
                                                ? "Pulang Cepat"
                                                : "Lembur",
                                    "jam_absen_masuk":
                                        absenC.dataLimitAbsen[i].jamAbsenMasuk!,
                                    "jam_absen_pulang": absenC
                                        .dataLimitAbsen[i].jamAbsenPulang!,
                                    "foto_masuk":
                                        absenC.dataLimitAbsen[i].fotoMasuk!,
                                    "foto_pulang":
                                        absenC.dataLimitAbsen[i].fotoPulang!,
                                    "lat_masuk":
                                        absenC.dataLimitAbsen[i].latMasuk!,
                                    "long_masuk":
                                        absenC.dataLimitAbsen[i].longMasuk!,
                                    "lat_pulang":
                                        absenC.dataLimitAbsen[i].latPulang!,
                                    "long_pulang":
                                        absenC.dataLimitAbsen[i].longPulang!,
                                    "device_info":
                                        absenC.dataLimitAbsen[i].devInfo!,
                                    "device_info2":
                                        absenC.dataLimitAbsen[i].devInfo2!,
                                  },
                                  transition: Transition.cupertino),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  children: [
                                    Container(
                                        width: 10,
                                        height: Get.mediaQuery.size.height / 12,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: DateFormat("HH:mm")
                                                    .parse(absenC
                                                        .dataLimitAbsen[i]
                                                        .jamAbsenMasuk!)
                                                    .isBefore(DateFormat("HH:mm")
                                                        .parse(absenC
                                                            .dataLimitAbsen[i]
                                                            .jamMasuk!))
                                                ? Colors.greenAccent[700]
                                                : DateFormat("HH:mm")
                                                        .parse(absenC
                                                            .dataLimitAbsen[i]
                                                            .jamAbsenMasuk!)
                                                        .isAtSameMomentAs(
                                                            DateFormat("HH:mm")
                                                                .parse(absenC
                                                                    .dataLimitAbsen[i]
                                                                    .jamMasuk!))
                                                    ? Colors.greenAccent[700]
                                                    : Colors.redAccent[700],
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5),
                                            ))),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          DateFormat('MMM')
                                              .format(DateTime.parse(absenC
                                                  .dataLimitAbsen[i]
                                                  .tanggalMasuk!))
                                              .toUpperCase(),
                                          style:
                                              TextStyle(color: subTitleColor),
                                        ),
                                        Text(
                                          DateFormat('dd').format(
                                              DateTime.parse(absenC
                                                  .dataLimitAbsen[i]
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
                                            DateFormat("EEEE", "id_ID").format(
                                                DateTime.parse(absenC
                                                    .dataLimitAbsen[i]
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
                                                      .dataLimitAbsen[i]
                                                      .jamAbsenMasuk!)
                                                  .isBefore(DateFormat("HH:mm")
                                                      .parse(absenC
                                                          .dataLimitAbsen[i]
                                                          .jamMasuk!))
                                              ? "Awal Waktu"
                                              : DateFormat("HH:mm")
                                                      .parse(absenC
                                                          .dataLimitAbsen[i]
                                                          .jamAbsenMasuk!)
                                                      .isAtSameMomentAs(
                                                          DateFormat("HH:mm")
                                                              .parse(absenC
                                                                  .dataLimitAbsen[
                                                                      i]
                                                                  .jamMasuk!))
                                                  ? "Tepat Waktu"
                                                  : "Telat",
                                          style: TextStyle(
                                              color: DateFormat("HH:mm")
                                                      .parse(absenC
                                                          .dataLimitAbsen[i]
                                                          .jamAbsenMasuk!)
                                                      .isBefore(DateFormat("HH:mm")
                                                          .parse(absenC
                                                              .dataLimitAbsen[i]
                                                              .jamMasuk!))
                                                  ? Colors.greenAccent[700]
                                                  : DateFormat("HH:mm")
                                                          .parse(absenC
                                                              .dataLimitAbsen[i]
                                                              .jamAbsenMasuk!)
                                                          .isAtSameMomentAs(
                                                              DateFormat("HH:mm")
                                                                  .parse(absenC
                                                                      .dataLimitAbsen[i]
                                                                      .jamMasuk!))
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
                                                absenC.dataLimitAbsen[i]
                                                    .jamAbsenMasuk!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                                                absenC.dataLimitAbsen[i]
                                                            .jamAbsenPulang! !=
                                                        ""
                                                    ? absenC.dataLimitAbsen[i]
                                                        .jamAbsenPulang!
                                                    : "-",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
            )
          ],
        ),
      ),
    );
  }
}
