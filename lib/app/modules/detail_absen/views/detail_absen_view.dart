import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/modules/detail_absen/views/widget/edit_data_absen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
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
        point: LatLng(
          double.parse(detailData["lat_masuk"]),
          double.parse(detailData["long_masuk"]),
        ),
        child: const Icon(HeroIcons.map_pin, color: AppColors.contentColorBlue),
      ),
    ];

    final markersPulang = <Marker>[
      Marker(
        width: 80,
        height: 80,
        point: LatLng(
          double.parse(
            detailData["lat_pulang"] != "" ? detailData["lat_pulang"] : "0.0",
          ),
          double.parse(
            detailData["long_pulang"] != "" ? detailData["long_pulang"] : "0.0",
          ),
        ),
        child: const Icon(HeroIcons.map_pin, color: AppColors.contentColorBlue),
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Detail Absen',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        // centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: 12,
              top: 100,
              right: 12,
              bottom: 10,
            ),
            children: [
              buildCard(
                context: context,
                data: detailData,
                marker: markersMasuk,
                isIn: true,
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: detailData['tanggal_pulang'] == "" ? true : false,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Tidak ada data absen pulang',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: detailData['tanggal_pulang'] != "" ? true : false,
                child: buildCard(
                  context: context,
                  data: detailData,
                  markerPulang: markersPulang,
                  isIn: false,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.itemsBackground,
        onPressed: () {
          Get.bottomSheet(EditDataAbsen(data: detailData));
        },
        label: const Text('Edit Data'),
        icon: const Icon(Icons.edit),
      ),
    );
  }

  Widget buildCard({
    BuildContext? context,
    Map<String, dynamic>? data,
    List<Marker>? marker,
    List<Marker>? markerPulang,
    required bool isIn,
  }) {
    // String formatLatLng(double lat, double lng) {
    //   // Tentukan Utara/Selatan
    //   String latDirection = lat >= 0 ? 'N' : 'S';
    //   String lngDirection = lng >= 0 ? 'E' : 'W';

    //   // Ambil nilai absolut agar derajat positif
    //   double absLat = lat.abs();
    //   double absLng = lng.abs();

    //   // Format ke derajat dengan 6 desimal (atau sesuai kebutuhan)
    //   String formattedLat = '${absLat.toStringAsFixed(6)}°$latDirection';
    //   String formattedLng = '${absLng.toStringAsFixed(6)}°$lngDirection';

    //   return '$formattedLat, $formattedLng';
    // }

    String getGoogleMapsUrl(double lat, double lng) {
      // Format koordinat ke format decimal raw untuk URL query
      return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }
    // format lt lng

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: mainColor,
            ),
            child: Center(
              child: Text(
                isIn
                    ? FormatWaktu.formatIndo(
                      tanggal: DateTime.parse(data!['tanggal_masuk']),
                    )
                    : data!['tanggal_pulang'] != ""
                    ? FormatWaktu.formatIndo(
                      tanggal: DateTime.parse(data['tanggal_pulang']),
                    )
                    : '',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 265,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      onTap: (tapPosition, point) {
                        // print(point.latitude);
                        // print(point.longitude);
                        var gmaps = getGoogleMapsUrl(
                          point.latitude,
                          point.longitude,
                        );
                        // print(gmaps);
                        launchUrl(Uri.parse(gmaps));
                       
                      },
                      initialCenter:
                          isIn
                              ? LatLng(
                                double.parse(data["lat_masuk"]),
                                double.parse(data["long_masuk"]),
                              )
                              : LatLng(
                                double.parse(
                                  data["lat_pulang"] != ""
                                      ? data["lat_pulang"]
                                      : '0.0',
                                ),
                                double.parse(
                                  data["long_pulang"] != ""
                                      ? data["long_pulang"]
                                      : '0.0',
                                ),
                              ),
                      initialZoom: 17,
                    ),
                    nonRotatedChildren: [
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                            onTap: () {},
                          ),
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
                      MarkerLayer(markers: isIn ? marker! : markerPulang!),
                    ],
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 155, 2, 5),
                      child: Container(
                        // height: 50,
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: const BoxDecoration(
                          color: AppColors.contentColorWhite,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 75,
                              width: 75,
                              child: Image.network(
                                "${ServiceApi().baseUrl}${isIn ? data['foto_masuk'] : data['foto_pulang']}",
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Image.asset('assets/image/selfie.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Text('Name'),
                                    const SizedBox(width: 5),
                                    const SizedBox(width: 44),
                                    Text(
                                      ': ${data["nama"].toString().substring(0, data["nama"].toString().length > 20 ? 20 : data["nama"].toString().length) + (data["nama"].toString().length > 18 ? '...' : '').toString().capitalize!}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Shift'),
                                    const SizedBox(width: 57),
                                    SizedBox(
                                      width: Get.mediaQuery.size.width * 0.35,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(': ${data['nama_shift']}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(isIn ? 'Check In' : 'Check Out'),
                                    SizedBox(width: isIn ? 33 : 21),
                                    Text(
                                      ': ${isIn ? data['jam_absen_masuk'] : data['jam_absen_pulang']}',
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Device Info'),
                                    const SizedBox(width: 17),
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context!).size.width *
                                            0.3,
                                      ),
                                      child: Text(
                                        ": ${isIn ? data['device_info'] : data['device_info2']}",
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Status'),
                                    const SizedBox(width: 50),
                                    Container(
                                      height: 25,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color:
                                            data['jam_masuk'] == "Late"
                                                ? Colors.redAccent[700]
                                                : Colors.greenAccent[700],
                                      ),

                                      child: Center(
                                        child: Text(
                                          "${isIn ? data['jam_masuk'] : data['jam_pulang']}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
