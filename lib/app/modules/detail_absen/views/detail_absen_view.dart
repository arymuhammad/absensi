import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/detail_absen/views/widget/note.dart';
import 'package:absensi/app/modules/shared/rounded_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../services/service_api.dart';
import '../controllers/detail_absen_controller.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations

class DetailAbsenView extends GetView<DetailAbsenController> {
  const DetailAbsenView(this.detailData, {super.key});
  final Map<String, dynamic> detailData;

 

  @override
  Widget build(BuildContext context) {

     final markersMasuk = <Marker>[
    Marker(
      width: 80,
      height: 80,
      point: LatLng(double.parse(detailData["lat_masuk"]),
          double.parse(detailData["long_masuk"])),
      child: Card(
          elevation: 10,
          child: Image.network(
            "${ServiceApi().baseUrl}${detailData['foto_masuk']}",
            errorBuilder: (context, error, stackTrace) =>
                Image.asset('assets/image/selfie.png'),
            fit: BoxFit.cover,
          )),
    ),
  ];

  final markersPulang = <Marker>[
    Marker(
      width: 80,
      height: 80,
      point: LatLng(
          double.parse(detailData["lat_pulang"] != ""
              ? detailData["lat_pulang"]
              : "0.0"),
          double.parse(detailData["long_pulang"] != ""
              ? detailData["long_pulang"]
              : "0.0")),
      child: Card(
          elevation: 10,
          child: Image.network(
            "${ServiceApi().baseUrl}${detailData['foto_pulang']}",
            errorBuilder: (context, error, stackTrace) =>
                Image.asset('assets/image/selfie.png'),
            fit: BoxFit.cover,
          )),
    ),
  ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL ABSEN'),
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
        padding: const EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
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
                      DateFormat("EEEE, d MMMM yyyy", "id_ID").format(
                          DateTime.parse(detailData['tanggal_masuk'])),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            RoundedImage(
                                height: 75,
                                width: 75,
                                foto: detailData['foto_profil'],
                                name: detailData['foto_profil'],
                                headerProfile: true),
                            const SizedBox(width: 5),
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
                                          ': ${detailData["nama"].toString().capitalize}',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Shift'),
                                        const SizedBox(width: 57),
                                        SizedBox(
                                          width:
                                              Get.mediaQuery.size.width * 0.35,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ': ${detailData['nama_shift']}',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Masuk'),
                                        const SizedBox(width: 45),
                                        Text(
                                          ': ${detailData['jam_absen_masuk']}',
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
                                                  detailData['jam_masuk'] ==
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
                                                "${detailData['jam_masuk']}",
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
                                            ": ${detailData['device_info']}",
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
                            double.parse(detailData["lat_masuk"]),
                            double.parse(detailData["long_masuk"])),
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
              visible: detailData['tanggal_pulang'] == "" ? true : false,
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Tidak ada data absen pulang',
                    style: TextStyle(fontSize: 18)),
              ))),
          Visibility(
            visible: detailData['tanggal_pulang'] != "" ? true : false,
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
                        detailData['tanggal_pulang'] != ""
                            ? DateFormat("EEEE, d MMMM yyyy", "id_ID").format(
                                DateTime.parse(detailData['tanggal_pulang']))
                            : "",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              RoundedImage(
                                  height: 75,
                                  width: 75,
                                  foto: detailData['foto_profil'],
                                  name: detailData['foto_profil'],
                                  headerProfile: true),
                              const SizedBox(width: 5),
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
                                            ': ${detailData["nama"].toString().capitalize}',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Shift'),
                                          const SizedBox(width: 57),
                                          SizedBox(
                                            width: Get.mediaQuery.size.width *
                                                0.35,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ': ${detailData['nama_shift']}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Pulang'),
                                          const SizedBox(width: 42),
                                          Text(
                                            ': ${detailData['jam_absen_pulang'] != "" ? detailData['jam_absen_pulang'] : "-"}',
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
                                                color: detailData[
                                                                'jam_pulang'] ==
                                                            "Belum Absen" ||
                                                        detailData[
                                                                'jam_pulang'] ==
                                                            "Pulang Cepat"
                                                    ? Colors.redAccent[700]
                                                    : Colors.greenAccent[700]),
                                            child: Center(
                                              child: Text(
                                                  "${detailData['jam_pulang']}",
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            detailData['jam_absen_pulang'] !=
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
                                                ": ${detailData['device_info2']}",
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
                        detailData['jam_absen_pulang'] != "" ? true : false,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 200,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    double.parse(detailData["lat_masuk"]),
                                    double.parse(detailData["long_masuk"])),
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            note();
          },
          child: Icon(Icons.message_rounded)),
    );
  }
}
