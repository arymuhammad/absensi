
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class DetailVisitView extends GetView {
  DetailVisitView({super.key});

  final markersMasuk = <Marker>[
    Marker(
      width: 80,
      height: 80,
      point: LatLng(double.parse(Get.arguments["lat_in"]),
          double.parse(Get.arguments["long_in"])),
      child: Card(
        elevation: 10,
        child: 
        Image.network("${ServiceApi().baseUrl}${Get.arguments['foto_in']}",
          errorBuilder: (context, error, stackTrace) =>Image.asset('assets/image/selfie.png'),
          fit: BoxFit.cover,)
        // Image.network(
        //   "${ServiceApi().baseUrl}${Get.arguments['foto_in']}",
        //   errorBuilder: (context, error, stackTrace) =>Image.asset('assets/image/selfie.png'),
        //   fit: BoxFit.cover,
        // ),
      ),
    ),
  ];

  final markersPulang = <Marker>[
    Marker(
      width: 80,
      height: 80,
      point: LatLng(
          double.parse(Get.arguments["lat_out"] != ""
              ? Get.arguments["lat_out"]
              : "0.0"),
          double.parse(Get.arguments["long_out"] != ""
              ? Get.arguments["long_out"]
              : "0.0")),
      child: Card(
        elevation: 10,
        child: 
        Image.network("${ServiceApi().baseUrl}${Get.arguments['foto_out']}",
          errorBuilder: (context, error, stackTrace) =>Image.asset('assets/image/selfie.png'),
          fit: BoxFit.cover,)
  //       Image.network(
  //         "${ServiceApi().baseUrl}${Get.arguments['foto_out']}",
  //         fit: BoxFit.cover,
  // errorBuilder: (context, error, stackTrace) =>Image.asset('assets/image/selfie.png'),
  //       ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL VISIT'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/new_bg_app.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
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
                          .format(DateTime.parse(Get.arguments['tgl_visit'])),
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
                                  child: Get.arguments['foto_profil']
                                              .toString()
                                              .substring(0, 5) ==
                                          "profi"
                                      ? Image.network(
                                          "${ServiceApi().baseUrl}${Get.arguments['foto_profil']}",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          "https://ui-avatars.com/api/?name=${Get.arguments['foto_profil']}",
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
                                        const Text('Masuk'),
                                        const SizedBox(width: 45),
                                        Text(
                                          ': ${Get.arguments['jam_in']}',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Store'),
                                        const SizedBox(width: 45),
                                        SizedBox(
                                          // padding: const EdgeInsets.all(10.0),
                                          width:
                                              Get.mediaQuery.size.width * 0.42,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '  : ${Get.arguments['store']}',
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
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
                        initialCenter: LatLng(
                            double.parse(Get.arguments["lat_in"]),
                            double.parse(Get.arguments["long_in"])),
                        initialZoom: 15,
                      ),
                      nonRotatedChildren: [
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () {},
                            )
                          ],
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
          Visibility(
              visible: Get.arguments['jam_out'] == "" ? true : false,
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Tidak ada data keluar ',
                    style: TextStyle(fontSize: 18)),
              ))),
          Visibility(
            visible: Get.arguments['jam_out'] != "" ? true : false,
            child: Card(
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
                        Get.arguments['tgl_visit'] != ""
                            ? DateFormat("EEEE, d MMMM yyyy", "id_ID").format(
                                DateTime.parse(Get.arguments['tgl_visit']))
                            : "",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
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
                                    child: Get.arguments['foto_profil']
                                                .toString()
                                                .substring(0, 5) ==
                                            "profi"
                                        ? Image.network(
                                            "${ServiceApi().baseUrl}${Get.arguments['foto_profil']}",
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            "https://ui-avatars.com/api/?name=${Get.arguments['foto_profil']}",
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
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Keluar'),
                                          const SizedBox(width: 42),
                                          Text(
                                            ' : ${Get.arguments['jam_out'] != "" ? Get.arguments['jam_out'] : "-"}',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Store'),
                                          const SizedBox(width: 45),
                                          SizedBox(
                                            // padding: const EdgeInsets.all(10.0),
                                            width: Get.mediaQuery.size.width *
                                                0.42,
                                            child: Text(
                                              '  : ${Get.arguments['store']}',
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: Get.arguments['jam_out'] != ""
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
                    visible: Get.arguments['jam_out'] != "" ? true : false,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 200,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    double.parse(Get.arguments["lat_in"]),
                                    double.parse(Get.arguments["long_in"])),
                                initialZoom: 15,
                              ),
                              nonRotatedChildren: [
                                RichAttributionWidget(
                                  attributions: [
                                    TextSourceAttribution(
                                      'OpenStreetMap contributors',
                                      onTap: () {},
                                    )
                                  ],
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
            ),
          )
        ],
      ),
    );
  }
}
