import 'dart:async';

import 'package:absensi/app/helper/const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ternav_icons/ternav_icons.dart';
import '../../../Repo/service_api.dart';
import '../controllers/detail_absen_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailAbsenView extends GetView<DetailAbsenController> {
  DetailAbsenView({Key? key}) : super(key: key);
  final Completer<GoogleMapController> _controller = Completer();
  static CameraPosition locAbsen = CameraPosition(
    target: LatLng(double.parse(Get.arguments["long_masuk"]),
        double.parse(Get.arguments["lat_masuk"])),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    print(Get.arguments["lat_masuk"]);
    print(Get.arguments["long_masuk"]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL ABSEN'),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            elevation: 10,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Expanded(
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      color: Color.fromARGB(255, 5, 54, 94),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat("EEEE, d MMMM yyyy","id_ID")
                            .format(DateTime.parse(Get.arguments['tanggal'])),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: Container(
                                  height: 75,
                                  width: 75,
                                  color: Colors.white,
                                  child: Center(
                                    child: Image.network(
                                      "${ServiceApi().baseUrl}${Get.arguments['foto_masuk']}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Nama'),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const SizedBox(width: 44),
                                          Text(
                                              ': ${Get.arguments["nama"].toString().capitalize}',
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Shift'),
                                          const SizedBox(width: 57),
                                          Text(
                                              ': ${Get.arguments['nama_shift']}',
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Masuk'),
                                          const SizedBox(width: 45),
                                          Text(
                                              ': ${Get.arguments['jam_absen_masuk']}',
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Status Masuk'),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            height: 25,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Get.arguments[
                                                            'jam_masuk'] ==
                                                        "Telat"
                                                    ? Colors.redAccent[700]
                                                    : Colors.greenAccent[700]),
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                            ),
                                            child: Center(
                                              child: Text(
                                                  "${Get.arguments['jam_masuk']}",
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
                  // Container(
                  //   height: 80,
                  //   child: GoogleMap(
                  //     mapType: MapType.normal,
                  //     initialCameraPosition: locAbsen,
                  //     onMapCreated: (GoogleMapController controller) {
                  //       _controller.complete(controller);
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 10,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Color.fromARGB(255, 5, 54, 94),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat("EEEE, d MMMM yyyy","id_ID")
                          .format(DateTime.parse(Get.arguments['tanggal'])),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: Colors.white),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Container(
                                height: 75,
                                width: 75,
                                color: Colors.white,
                                child: Center(
                                  child: Get.arguments['foto_pulang'] != ""
                                      ? Image.network(
                                          "${ServiceApi().baseUrl}${Get.arguments['foto_pulang']}",
                                          fit: BoxFit.cover,
                                          // progressIndicatorBuilder:
                                          //     (context, url, progress) {
                                          //   print(
                                          //       "${ServiceApi().baseUrl}${Get.arguments['foto_masuk']}");
                                          //   return CircularProgressIndicator(
                                          //     value: progress.progress,
                                          //     strokeWidth: 5,
                                          //   );
                                          // },
                                        )
                                      : Icon(TernavIcons.lightOutline.image_4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Nama'),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const SizedBox(width: 44),
                                        Text(
                                            ': ${Get.arguments["nama"].toString().capitalize}',
                                            style:
                                                const TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Shift'),
                                        const SizedBox(width: 57),
                                        Text(': ${Get.arguments['nama_shift']}',
                                            style:
                                                const TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Pulang'),
                                        const SizedBox(width: 45),
                                        Text(
                                            ': ${Get.arguments['jam_absen_pulang'] != "" ? Get.arguments['jam_absen_pulang'] : "-"}',
                                            style:
                                                const TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Status Pulang'),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          height: 25,
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Get.arguments[
                                                              'jam_pulang'] ==
                                                          "Belum Absen" ||
                                                      Get.arguments[
                                                              'jam_pulang'] ==
                                                          "Pulang Cepat"
                                                  ? Colors.redAccent[700]
                                                  : Colors.greenAccent[700]),
                                          child: Center(
                                            child: Text(
                                                "${Get.arguments['jam_pulang']}",
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
      // bottomNavigationBar: ConvexAppBar(
      //   items: const [
      //     TabItem(icon: Icons.home, title: 'Home'),
      //     TabItem(icon: Icons.camera_outlined),
      //     TabItem(icon: Icons.person, title: 'Profile'),
      //   ],
      //   initialActiveIndex: pageC.pageIndex.value,
      //   activeColor: Colors.white,
      //   style: TabStyle.fixedCircle,
      //   onTap: (i) => pageC.changePage(i),
      // ),
    );
  }
}
