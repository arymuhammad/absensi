import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Repo/service_api.dart';
import '../../../controllers/absen_controller.dart';
import '../../../controllers/page_index_controller.dart';
import '../../../model/absen_model.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key, this.listDataUser});
  final loc = Get.put(AbsenController());
  final List? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Home'),
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 0
          // actions: [
          //   IconButton(
          //       onPressed: () => Get.toNamed(Routes.ADD_PEGAWAI),
          //       icon: const Icon(Icons.people))
          // ],
          ),
      body: Stack(
        children: [
          ClipPath(
            clipper: ClipPathClass(),
            child: Container(
              height: 200,
              width: Get.width,
              color: Colors.blue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () =>
                          Get.to(() => ProfilView(listDataUser: listDataUser!)),
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
                        Text(
                          listDataUser![1].toString().toUpperCase(),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Obx(() => Text(
                              loc.lokasi.value.isNotEmpty
                                  ? loc.lokasi.value
                                  : 'Belum ada lokasi',
                              style: const TextStyle(color: Colors.white),
                            ))
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 10,
                  child: Container(
                    width: Get.mediaQuery.size.width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${listDataUser![4]}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text('${listDataUser![0]}'),
                        const SizedBox(height: 5),
                        Text(listDataUser![2].toString().toUpperCase()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Masuk',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Obx(
                            () => Text(
                              loc.dataAbsen.isNotEmpty
                                  ? loc.dataAbsen[0].jamAbsenMasuk!
                                  : '-',
                              style: const TextStyle(fontSize: 18),
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
                            'Keluar',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Obx(
                            () => Text(
                              loc.dataAbsen.isNotEmpty
                                  ? loc.dataAbsen[0].jamAbsenPulang!
                                  : '-',
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: Colors.grey[300],
                  thickness: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Data absen terkini',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Get.toNamed(Routes.SEMUA_ABSEN);
                              // showDialog(
                              //     // The user CANNOT close this dialog  by pressing outsite it
                              //     barrierDismissible: false,
                              //     context: context,
                              //     builder: (_) {
                              //       return  const Dialog(
                              //         insetPadding: EdgeInsets.all(50),
                              //         child: SizedBox(
                              //           height: 100,
                              //           width: 10,
                              //           child: Center(child: CircularProgressIndicator())),

                              //           );
                              //     });
                              // if (loc.dataAllAbsen.isEmpty) {
                              loc.getAllAbsen(listDataUser![0]);
                              // } else {}
                              // Get.back();
                            },
                            child: const Text('Lihat Detail')),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Colors.blue,
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Obx(
                    () => loc.isLoading.value
                        ? ListView.builder(
                            padding: const EdgeInsets.only(
                                bottom: 20.0, left: 20.0, right: 20.0),
                            itemCount: 5,
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
                        : loc.dataLimitAbsen.isEmpty
                            ? const Center(
                                child: Text('Belum ada data absen'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                // physics: const NeverScrollableScrollPhysics(),
                                itemCount: loc.dataLimitAbsen.length,
                                itemBuilder: (c, i) {
                                  return InkWell(
                                    onTap: () => Get.toNamed(
                                        Routes.DETAIL_ABSEN,
                                        arguments: {
                                          "nama": loc.dataLimitAbsen[i].nama!,
                                          "id_user":
                                              loc.dataLimitAbsen[i].idUser!,
                                          "tanggal":
                                              loc.dataLimitAbsen[i].tanggal!,
                                          "jam_masuk": DateFormat("HH:mm:ss")
                                                  .parse(loc.dataLimitAbsen[i]
                                                      .jamAbsenMasuk!)
                                                  .isBefore(
                                                      DateFormat("HH:mm:ss")
                                                          .parse(loc
                                                              .dataLimitAbsen[i]
                                                              .jamMasuk!))
                                              ? "Awal Waktu"
                                              : "Telat",
                                          "jam_pulang": loc.dataLimitAbsen[i]
                                                      .jamAbsenPulang! ==
                                                  ""
                                              ? "Belum / Tidak\nAbsen Pulang"
                                              : DateFormat("HH:mm:ss")
                                                      .parse(loc
                                                          .dataLimitAbsen[i]
                                                          .jamAbsenPulang!)
                                                      .isBefore(DateFormat(
                                                              "HH:mm:ss")
                                                          .parse(loc
                                                              .dataLimitAbsen[i]
                                                              .jamPulang!))
                                                  ? "Pulang Cepat"
                                                  : "Lembur",
                                          "jam_absen_masuk": loc
                                              .dataLimitAbsen[i].jamAbsenMasuk!,
                                          "jam_absen_pulang": loc
                                              .dataLimitAbsen[i]
                                              .jamAbsenPulang!,
                                          "foto_masuk":
                                              loc.dataLimitAbsen[i].fotoMasuk!,
                                          "foto_pulang":
                                              loc.dataLimitAbsen[i].fotoPulang!
                                        }),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Masuk',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  DateFormat('EE, dd-MM-yyyy')
                                                      .format(DateTime.parse(loc
                                                          .dataLimitAbsen[i]
                                                          .tanggal!)),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Text(loc.dataLimitAbsen[i]
                                                      .jamAbsenMasuk !=
                                                  ""
                                              ? loc.dataLimitAbsen[i]
                                                  .jamAbsenMasuk!
                                              : "-"),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          const Text(
                                            'Keluar',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(loc.dataLimitAbsen[i]
                                                      .jamAbsenPulang !=
                                                  ""
                                              ? loc.dataLimitAbsen[i]
                                                  .jamAbsenPulang!
                                              : "-"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                )
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
