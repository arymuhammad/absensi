import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
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
        centerTitle: true,
        title: Text(
          'Detail Absen',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        flexibleSpace:Container(decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),)
        // centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: 20,
              top: 100,
              right: 20,
              bottom: 10,
            ),
            children: [
              buildCard(
                context: context,
                data: detailData,
                marker: markersMasuk,
                isIn: true,
              ),
              const SizedBox(height: 5),
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
          detailData['id_shift'] == "5"
              ? failedDialog(
                context,
                'ERROR',
                'data absen dengan Shift WEEKDAY-KUSTOM tidak dapat di edit!',
              )
              : Get.bottomSheet(EditDataAbsen(data: detailData));
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
    String getGoogleMapsUrl(double lat, double lng) {
      return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }

    final headerColor =
        isIn
            ? data!['jam_masuk'] == "Late"
                ? Colors.redAccent[700]
                : Colors.greenAccent[700]
            : data!['jam_pulang'] == "Over Time"
            ? Colors.blueAccent[700]
            : data['jam_pulang'] == "Early"
            ? Colors.redAccent[700]
            : Colors.greenAccent[700];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            offset: const Offset(0, 16),
            color: Colors.black.withOpacity(.18),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ================= HEADER =================
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  isIn ? 'CHECK IN' : 'CHECK OUT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  isIn ? data['jam_absen_masuk'] : data['jam_absen_pulang'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),

          /// ================= BODY =================
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              height: 300,
              child: Stack(
                children: [
                  /// ================= MAP =================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: FlutterMap(
                      options: MapOptions(
                        onTap: (tapPosition, point) {
                          launchUrl(
                            Uri.parse(
                              getGoogleMapsUrl(point.latitude, point.longitude),
                            ),
                          );
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
                  ),

                  /// ================= INFO CARD =================
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                "${ServiceApi().baseUrl}${isIn ? data['foto_masuk'] : data['foto_pulang']}",
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        Image.asset('assets/image/selfie.png'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["nama"].toString().capitalize!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isIn
                                      ? FormatWaktu.formatIndo(
                                        tanggal: DateTime.parse(
                                          data['tanggal_masuk'],
                                        ),
                                      )
                                      : data['tanggal_pulang'] != ""
                                      ? FormatWaktu.formatIndo(
                                        tanggal: DateTime.parse(
                                          data['tanggal_pulang'],
                                        ),
                                      )
                                      : '',
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      data['nama_shift'].toString().capitalize!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 5),
                                    Row(
                                      children: [
                                        // Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //     horizontal: 8,
                                        //     vertical: 4,
                                        //   ),
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.circular(6),
                                        //     color:
                                        //         data['jam_masuk'] == "Late"
                                        //             ? Colors.redAccent[700]
                                        //             : Colors.greenAccent[700],
                                        //   ),
                                        //   child:
                                        Icon(
                                          isIn
                                              ? data['jam_masuk'] == "Late"
                                                  ? Icons.cancel
                                                  : Icons.check_circle
                                              : data['jam_pulang'] == "Early"
                                              ? Icons.cancel
                                              : Icons.check_circle,
                                          color: headerColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isIn
                                              ? data['jam_masuk']
                                              : data['jam_pulang'],
                                          style: TextStyle(color: headerColor),
                                        ),

                                        //  const Text(
                                        //   color: Colors.white,
                                        //   fontSize: 12,
                                        //   fontWeight: FontWeight.w600,
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.smartphone, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        isIn
                                            ? data['device_info']
                                            : data['device_info2'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
