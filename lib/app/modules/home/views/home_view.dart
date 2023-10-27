import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/helper/loading_dialog.dart';
import 'package:absensi/app/modules/cek_stok/views/cek_stok_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/report_sales/views/report_sales_view.dart';
import 'package:absensi/app/modules/semua_absen/views/semua_absen_view.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../services/service_api.dart';
import '../../../controllers/absen_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key, this.listDataUser});
  final absenC = Get.put(AbsenController());
  final loginC = Get.put(LoginController());
  final List? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, elevation: 0, toolbarHeight: 0),
      body: Stack(
        children: [
          ClipPath(
            clipper: ClipPathClass(),
            child: Container(
              height: 250,
              width: Get.size.width,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/image/bgapp.jpg'),
                      fit: BoxFit.fill)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // loginC.selectedMenu(2);
                            Get.to(
                                () => ProfilView(listDataUser: listDataUser!));
                          },
                          child: ClipOval(
                            child: Hero(
                              tag: 'pro',
                              transitionOnUserGestures: true,
                              child: Container(
                                height: 75,
                                width: 75,
                                color: Colors.grey[200],
                                child: listDataUser![5] != ""
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            "${ServiceApi().baseUrl}${listDataUser![5]}",
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                CircularProgressIndicator(
                                          value: progress.progress,
                                          strokeWidth: 15,
                                        ),
                                        cacheKey:
                                            "${ServiceApi().baseUrl}${listDataUser![5]} + ${DateTime.now().day.toString()}",
                                      )
                                    : Image.network(
                                        "https://ui-avatars.com/api/?name=${listDataUser![1]}",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              listDataUser![1].toString().capitalize!,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                            // Obx(() => Text(
                            //       absenC.devInfoAnd.value.isNotEmpty
                            //           ? absenC.devInfoAnd.value
                            //           : 'Belum ada info andr',
                            //       style: const TextStyle(color: Colors.white),
                            //     ))
                          ],
                        )
                      ],
                    ),
                    IconButton(onPressed: (){ promptDialog(context, 'Anda yakin ingin keluar?');}, icon:  const Icon(Icons.logout_rounded, color: Colors.white, size: 35,))
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 10,
                          child: Container(
                            width: Get.mediaQuery.size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${listDataUser![4]}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text('${listDataUser![0]}'),
                                          const SizedBox(height: 5),
                                          Text(listDataUser![2]
                                              .toString()
                                              .toUpperCase()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 1,
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                Get.to(
                                                    () => CekStokView(
                                                        kodeCabang:
                                                            listDataUser![8]),
                                                    transition:
                                                        Transition.cupertino);
                                              },
                                              icon: Icon(
                                                // CupertinoIcons.doc_text_search,
                                                FontAwesome.box_open,
                                                color: mainColor,
                                                size: 30,
                                              )),
                                          const Text(
                                            'Cek Stok',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                Get.to(() => ReportSalesView(),
                                                    transition:
                                                        Transition.cupertino);
                                              },
                                              icon: Icon(
                                                FontAwesome
                                                    .circle_dollar_to_slot,
                                                color: mainColor,
                                                size: 30,
                                              )),
                                          const Text(
                                            'Laporan Sales',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        // CardMenu(dataUser: listDataUser!),
                        const SizedBox(height: 10),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () {
                              return Future.delayed(const Duration(seconds: 1),
                                  () async {
                                var paramLimit = {
                                  "mode": "limit",
                                  "id_user": listDataUser![0],
                                  "tanggal1": absenC.initDate1,
                                  "tanggal2": absenC.initDate2
                                };

                                var paramSingle = {
                                  "mode": "single",
                                  "id_user": listDataUser![0],
                                  "tanggal": absenC.dateNow
                                };
                                // loadingDialog("Memuat halaman...", "");
                                absenC.isLoading.value = true;
                                await absenC.getAbsenToday(paramSingle);
                                await absenC.getLimitAbsen(paramLimit);
                                // await Future.delayed(
                                //     const Duration(milliseconds: 400));
                                // Get.back();

                                showToast("Halaman Disegarkan.");
                              });
                            },
                            child: ListView(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                            DateFormat("EEEE, d MMMM yyyy",
                                                    "id_ID")
                                                .format(DateTime.parse(
                                                    absenC.dateNow)),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const Divider(
                                        thickness: 1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              const Text(
                                                'Masuk',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Obx(
                                                () => Text(
                                                  absenC.dataAbsen.isNotEmpty &&
                                                          absenC.dataAbsen[0]
                                                                  .jamAbsenMasuk! !=
                                                              ""
                                                      ? absenC.dataAbsen[0]
                                                          .jamAbsenMasuk!
                                                      : '-',
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            width: 2,
                                            height: 40,
                                            color: Colors.grey,
                                          ),
                                          Column(
                                            children: [
                                              const Text(
                                                'Pulang',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Obx(
                                                () => Text(
                                                  absenC.dataAbsen.isNotEmpty &&
                                                          absenC.dataAbsen[0]
                                                                  .jamAbsenPulang! !=
                                                              ""
                                                      ? absenC.dataAbsen[0]
                                                          .jamAbsenPulang!
                                                      : '-',
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              )
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Riwayat absen',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              absenC.isLoading.value = true;
                                              absenC.searchDate.value = "";
                                              Get.to(() => SemuaAbsenView(),
                                                  arguments: {
                                                    "foto_profil":
                                                        listDataUser![5] != ""
                                                            ? listDataUser![5]
                                                            : listDataUser![1],
                                                    "id_user": listDataUser![0]
                                                  },
                                                  transition:
                                                      Transition.cupertino);
                                              absenC.getAllAbsen(
                                                  listDataUser![0]);
                                            },
                                            child: const Text(
                                              'Lihat Semua',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Obx(
                                  () => absenC.isLoading.value
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: 3,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Shimmer.fromColors(
                                                        baseColor: Colors.grey,
                                                        highlightColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                238, 238, 238),
                                                        child: Container(
                                                          width: 60,
                                                          height: 15,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                      ),
                                                      Shimmer.fromColors(
                                                        baseColor: Colors.grey,
                                                        highlightColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                238, 238, 238),
                                                        child: Container(
                                                          width: 130,
                                                          height: 15,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
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
                                                        const Color.fromARGB(
                                                            255, 238, 238, 238),
                                                    child: Container(
                                                      width: 70,
                                                      height: 15,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey,
                                                    highlightColor:
                                                        const Color.fromARGB(
                                                            255, 238, 238, 238),
                                                    child: Container(
                                                      width: 60,
                                                      height: 15,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey,
                                                    highlightColor:
                                                        const Color.fromARGB(
                                                            255, 238, 238, 238),
                                                    child: Container(
                                                      width: 70,
                                                      height: 15,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
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
                                                child: Text(
                                                    'Belum ada riwayat absen'),
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  absenC.dataLimitAbsen.length,
                                              itemBuilder: (c, i) {
                                                return InkWell(
                                                  onTap: () => Get.toNamed(
                                                      Routes.DETAIL_ABSEN,
                                                      arguments: {
                                                        "foto_profil":
                                                            listDataUser![5] !=
                                                                    ""
                                                                ? listDataUser![
                                                                    5]
                                                                : listDataUser![
                                                                    1],
                                                        "nama": absenC
                                                            .dataLimitAbsen[i]
                                                            .nama!,
                                                        "nama_shift": absenC
                                                            .dataLimitAbsen[i]
                                                            .namaShift!,
                                                        "id_user": absenC
                                                            .dataLimitAbsen[i]
                                                            .idUser!,
                                                        "tanggal": absenC
                                                            .dataLimitAbsen[i]
                                                            .tanggal!,
                                                        "jam_masuk": DateFormat(
                                                                    "HH:mm")
                                                                .parse(absenC
                                                                    .dataLimitAbsen[
                                                                        i]
                                                                    .jamAbsenMasuk!)
                                                                .isBefore(DateFormat(
                                                                        "HH:mm")
                                                                    .parse(absenC
                                                                        .dataLimitAbsen[
                                                                            i]
                                                                        .jamMasuk!))
                                                            ? "Awal Waktu"
                                                            : DateFormat("HH:mm")
                                                                    .parse(absenC
                                                                        .dataLimitAbsen[i]
                                                                        .jamAbsenMasuk!)
                                                                    .isAtSameMomentAs(DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamMasuk!))
                                                                ? "Tepat Waktu"
                                                                : "Telat",
                                                        "jam_pulang": absenC
                                                                    .dataLimitAbsen[
                                                                        i]
                                                                    .jamAbsenPulang! ==
                                                                ""
                                                            ? "Belum Absen"
                                                            : DateFormat("HH:mm")
                                                                    .parse(absenC
                                                                        .dataLimitAbsen[
                                                                            i]
                                                                        .jamAbsenPulang!)
                                                                    .isBefore(DateFormat("HH:mm").parse(absenC
                                                                        .dataLimitAbsen[
                                                                            i]
                                                                        .jamPulang!))
                                                                ? "Pulang Cepat"
                                                                : DateFormat("HH:mm")
                                                                        .parse(absenC
                                                                            .dataLimitAbsen[i]
                                                                            .jamAbsenPulang!)
                                                                        .isAtSameMomentAs(DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamPulang!))
                                                                    ? "Tepat Waktu"
                                                                    : "Lembur",
                                                        "jam_absen_masuk":
                                                            absenC
                                                                .dataLimitAbsen[
                                                                    i]
                                                                .jamAbsenMasuk!,
                                                        "jam_absen_pulang":
                                                            absenC
                                                                .dataLimitAbsen[
                                                                    i]
                                                                .jamAbsenPulang!,
                                                        "foto_masuk": absenC
                                                            .dataLimitAbsen[i]
                                                            .fotoMasuk!,
                                                        "foto_pulang": absenC
                                                            .dataLimitAbsen[i]
                                                            .fotoPulang!,
                                                        "lat_masuk": absenC
                                                            .dataLimitAbsen[i]
                                                            .latMasuk!,
                                                        "long_masuk": absenC
                                                            .dataLimitAbsen[i]
                                                            .longMasuk!,
                                                        "lat_pulang": absenC
                                                            .dataLimitAbsen[i]
                                                            .latPulang!,
                                                        "long_pulang": absenC
                                                            .dataLimitAbsen[i]
                                                            .longPulang!,
                                                        "device_info": absenC
                                                            .dataLimitAbsen[i]
                                                            .devInfo!,
                                                        "device_info2": absenC
                                                            .dataLimitAbsen[i]
                                                            .devInfo2!,
                                                      }),
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                            width: 10,
                                                            height: Get
                                                                    .mediaQuery
                                                                    .size
                                                                    .height /
                                                                12,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            decoration: BoxDecoration(
                                                                color: DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamAbsenMasuk!).isBefore(DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamMasuk!))
                                                                    ? Colors.greenAccent[700]
                                                                    : DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamAbsenMasuk!).isAtSameMomentAs(DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamMasuk!))
                                                                        ? Colors.greenAccent[700]
                                                                        : Colors.redAccent[700],
                                                                borderRadius: const BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                ))),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              DateFormat('MMM')
                                                                  .format(DateTime
                                                                      .parse(absenC
                                                                          .dataLimitAbsen[
                                                                              i]
                                                                          .tanggal!))
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  color:
                                                                      subTitleColor),
                                                            ),
                                                            Text(
                                                              DateFormat('dd').format(
                                                                  DateTime.parse(absenC
                                                                      .dataLimitAbsen[
                                                                          i]
                                                                      .tanggal!)),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color:
                                                                      titleColor),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          children: [
                                                            Text(
                                                                DateFormat(
                                                                        "EEEE",
                                                                        "id_ID")
                                                                    .format(DateTime.parse(absenC
                                                                        .dataLimitAbsen[
                                                                            i]
                                                                        .tanggal!)),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        titleColor)),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              DateFormat("HH:mm")
                                                                      .parse(absenC
                                                                          .dataLimitAbsen[
                                                                              i]
                                                                          .jamAbsenMasuk!)
                                                                      .isBefore(DateFormat("HH:mm").parse(absenC
                                                                          .dataLimitAbsen[
                                                                              i]
                                                                          .jamMasuk!))
                                                                  ? "Awal Waktu"
                                                                  : DateFormat(
                                                                              "HH:mm")
                                                                          .parse(absenC
                                                                              .dataLimitAbsen[
                                                                                  i]
                                                                              .jamAbsenMasuk!)
                                                                          .isAtSameMomentAs(DateFormat("HH:mm").parse(absenC
                                                                              .dataLimitAbsen[i]
                                                                              .jamMasuk!))
                                                                      ? "Tepat Waktu"
                                                                      : "Telat",
                                                              style: TextStyle(
                                                                  color: DateFormat(
                                                                              "HH:mm")
                                                                          .parse(absenC
                                                                              .dataLimitAbsen[
                                                                                  i]
                                                                              .jamAbsenMasuk!)
                                                                          .isBefore(DateFormat("HH:mm").parse(absenC
                                                                              .dataLimitAbsen[
                                                                                  i]
                                                                              .jamMasuk!))
                                                                      ? Colors.greenAccent[
                                                                          700]
                                                                      : DateFormat("HH:mm")
                                                                              .parse(absenC.dataLimitAbsen[i].jamAbsenMasuk!)
                                                                              .isAtSameMomentAs(DateFormat("HH:mm").parse(absenC.dataLimitAbsen[i].jamMasuk!))
                                                                          ? Colors.greenAccent[700]
                                                                          : Colors.redAccent[700]),
                                                            )
                                                          ],
                                                        ),
                                                        const Spacer(),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  const Text(
                                                                      'Masuk'),
                                                                  Text(
                                                                    absenC
                                                                        .dataLimitAbsen[
                                                                            i]
                                                                        .jamAbsenMasuk!,
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
                                                                  const Text(
                                                                      'Pulang'),
                                                                  Text(
                                                                    absenC.dataLimitAbsen[i].jamAbsenPulang! !=
                                                                            ""
                                                                        ? absenC
                                                                            .dataLimitAbsen[i]
                                                                            .jamAbsenPulang!
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
                                                        // Container(
                                                        //   // margin: const EdgeInsets.only(bottom: 20),
                                                        //   padding: const EdgeInsets.all(10),
                                                        //   decoration: const BoxDecoration(
                                                        //     color: Colors.white,
                                                        //     // borderRadius:
                                                        //     //     BorderRadius.circular(20)
                                                        //   ),
                                                        //   child: Column(
                                                        //     crossAxisAlignment:
                                                        //         CrossAxisAlignment.start,
                                                        //     children: [
                                                        //       Row(
                                                        //         mainAxisAlignment:
                                                        //             MainAxisAlignment
                                                        //                 .spaceBetween,
                                                        //         children: [
                                                        //           const Text(
                                                        //             'Masuk',
                                                        //             style: TextStyle(
                                                        //                 fontWeight:
                                                        //                     FontWeight.bold),
                                                        //           ),
                                                        //           // Text(
                                                        //           //     DateFormat(
                                                        //           //             "EEEE, d MMMM yyyy",
                                                        //           //             "id_ID")
                                                        //           //         .format(DateTime.parse(
                                                        //           //             absenC
                                                        //           //                 .dataLimitAbsen[i]
                                                        //           //                 .tanggal!)),
                                                        //           //     style: const TextStyle(
                                                        //           //         fontWeight:
                                                        //           //             FontWeight.bold)),
                                                        //         ],
                                                        //       ),
                                                        //       Text(absenC
                                                        //           .dataLimitAbsen[i].jamAbsenMasuk!),
                                                        //       const SizedBox(
                                                        //         height: 8,
                                                        //       ),
                                                        //       const Text(
                                                        //         'Keluar',
                                                        //         style: TextStyle(
                                                        //             fontWeight: FontWeight.bold),
                                                        //       ),
                                                        //       Text(absenC.dataLimitAbsen[i]
                                                        //                   .jamAbsenPulang !=
                                                        //               ""
                                                        //           ? absenC.dataLimitAbsen[i]
                                                        //               .jamAbsenPulang!
                                                        //           : "-"),
                                                        //     ],
                                                        //   ),
                                                        // ),
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
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 60);

    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 60);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
