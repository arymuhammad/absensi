import 'package:absensi/app/helper/const.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:ternav_icons/ternav_icons.dart';
import '../../../Repo/service_api.dart';
import '../controllers/detail_absen_controller.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by default

// ignore: must_be_immutable
class DetailAbsenView extends GetView<DetailAbsenController> {
  DetailAbsenView({Key? key}) : super(key: key);
  // late GoogleMapController mapsController;

  bool showMap = true;
  MapController mapController = MapController();
  double zoom = 7;

  final markersMasuk = <Marker>[
    Marker(
      width: 80,
      height: 80,
      point: LatLng(double.parse(Get.arguments["lat_masuk"]),
          double.parse(Get.arguments["long_masuk"])),
      builder: (ctx) => Card(
        elevation: 10,
        child: Image.network(
          "${ServiceApi().baseUrl}${Get.arguments['foto_masuk']}",
          fit: BoxFit.cover,
        ),
      ),
    ),
  ];

  final markersPulang = <Marker>[
    Marker(
      width: 80,
      height: 80,
      point: LatLng(
          double.parse(Get.arguments["lat_pulang"] != ""
              ? Get.arguments["lat_pulang"]
              : "0.0"),
          double.parse(Get.arguments["long_pulang"] != ""
              ? Get.arguments["long_pulang"]
              : "0.0")),
      builder: (ctx) => Card(
        elevation: 10,
        child: Image.network(
          "${ServiceApi().baseUrl}${Get.arguments['foto_pulang']}",
          fit: BoxFit.cover,
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: mainColor,
                  ),
                  child: Center(
                    child: Text(
                      DateFormat("EEEE, d MMMM yyyy", "id_ID")
                          .format(DateTime.parse(Get.arguments['tanggal'])),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Shift'),
                                        const SizedBox(width: 57),
                                        Text(
                                          ': ${Get.arguments['nama_shift']}',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Masuk'),
                                        const SizedBox(width: 45),
                                        Text(
                                          ': ${Get.arguments['jam_absen_masuk']}',
                                        ),
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
                                              color:
                                                  Get.arguments['jam_masuk'] ==
                                                          "Telat"
                                                      ? Colors.redAccent[700]
                                                      : Colors
                                                          .greenAccent[700]),
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Device Info'),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                          ),
                                          child: Text(
                                            ": ${Get.arguments['device_info']}",
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        center: LatLng(double.parse(Get.arguments["lat_masuk"]),
                            double.parse(Get.arguments["long_masuk"])),
                        zoom: 15,
                      ),
                      nonRotatedChildren: [
                        AttributionWidget.defaultWidget(
                          source: 'OpenStreetMap contributors',
                          onSourceTapped: () {},
                        ),
                      ],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        MarkerLayer(markers: markersMasuk),
                      ],
                    ),
                  ),
                ),
              ],
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
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: mainColor,
                  ),
                  child: Center(
                    child: Text(
                      DateFormat("EEEE, d MMMM yyyy", "id_ID")
                          .format(DateTime.parse(Get.arguments['tanggal'])),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Shift'),
                                        const SizedBox(width: 57),
                                        Text(
                                          ': ${Get.arguments['nama_shift']}',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Pulang'),
                                        const SizedBox(width: 42),
                                        Text(
                                          ': ${Get.arguments['jam_absen_pulang'] != "" ? Get.arguments['jam_absen_pulang'] : "-"}',
                                        ),
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
                                    Visibility(
                                      visible:
                                          Get.arguments['jam_absen_pulang'] !=
                                                  ""
                                              ? true
                                              : false,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Device Info'),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                            ),
                                            child: Text(
                                              ": ${Get.arguments['device_info2']}",
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
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
                Visibility(
                  visible:
                      Get.arguments['jam_absen_pulang'] != "" ? true : false,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: 200,
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(
                                  double.parse(Get.arguments["lat_masuk"]),
                                  double.parse(Get.arguments["long_masuk"])),
                              zoom: 15,
                            ),
                            nonRotatedChildren: [
                              AttributionWidget.defaultWidget(
                                source: 'OpenStreetMap contributors',
                                onSourceTapped: () {},
                              ),
                            ],
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'dev.fleaflet.flutter_map.example',
                              ),
                              MarkerLayer(markers: markersPulang),
                            ],
                          ))),
                )
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
