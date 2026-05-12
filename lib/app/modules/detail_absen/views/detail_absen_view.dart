import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/duration_count.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // print(detailData);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Detail Presence',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient(
              context: context,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                isDark: isDark,
              ),
              // const SizedBox(height: 5),
              Visibility(
                visible: detailData['tanggal_pulang'] == "" ? true : false,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No Checkout data',
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
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient(
            context: context,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            // detailData['id_shift'] == "5"
            //     ? failedDialog(
            //       context,
            //       'ERROR',
            //       'data absen dengan Shift WEEKDAY-KUSTOM tidak dapat di edit!',
            //     )
            //     : 
                Get.bottomSheet(EditDataAbsen(data: detailData));
          },
          label: Text(
            'Edit Data',
            style: TextStyle(color: isDark ? Colors.blue : Colors.white),
          ),
          icon: Icon(Icons.edit, color: isDark ? Colors.blue : Colors.white),
        ),
      ),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    List<Marker>? marker,
    List<Marker>? markerPulang,
    required bool isIn,
    required bool isDark,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 370;

    String getGoogleMapsUrl(double lat, double lng) {
      return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }

    final headerColor =
        isIn
            ? data['sts_masuk'] == "Late"
                ? const Color(0xFFC44747)
                : const Color(0xFF3E7C59)
            : data['sts_pulang'] == "Overtime"
            ? Colors.blue
            : data['sts_pulang'] == "Minus Time"
            ? const Color(0xFFC44747)
            : const Color(0xFF3E7C59);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 18),
            color: Colors.black.withOpacity(.12),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ================= HEADER =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    isIn ? 'CHECK IN' : 'CHECK OUT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                Text(
                  isIn ? data['jam_absen_masuk'] : data['jam_absen_pulang'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// ================= BODY =================
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                /// ================= MAP =================
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 220,
                    child: FlutterMap(
                      options: MapOptions(
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
                        onTap: (_, point) {
                          launchUrl(
                            Uri.parse(
                              getGoogleMapsUrl(point.latitude, point.longitude),
                            ),
                          );
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.absensi.urbanco',
                          maxNativeZoom: 19,
                          tileSize: 256,
                          retinaMode: true,
                        ),
                        MarkerLayer(markers: isIn ? marker! : markerPulang!),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// ================= INFO SECTION =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PHOTO
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        "${ServiceApi().baseUrl}${isIn ? data['foto_masuk'] : data['foto_pulang']}",
                        width: isSmall ? 60 : 70,
                        height: isSmall ? 60 : 70,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Image.asset(
                              'assets/image/selfie.png',
                              width: 70,
                              height: 70,
                            ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// TEXT AREA
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// NAME
                          Text(
                            data["nama"].toString().capitalize!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: isSmall ? 14 : 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          /// DATE
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
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 13,
                              color: isDark ? Colors.white60 : Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// SHIFT + STATUS (WRAP AUTO RESPONSIVE)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                shiftName(shift: data['nama_shift']),
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Icon(
                                isIn
                                    ? data['sts_masuk'] == "Late"
                                        ? Icons.cancel
                                        : Icons.check_circle
                                    : data['sts_pulang'] == "Minus Time"
                                    ? Icons.cancel
                                    : Icons.check_circle,
                                color: headerColor,
                                size: 16,
                              ),

                              Text(
                                isIn ? data['sts_masuk'] : data['sts_pulang'],
                                style: TextStyle(
                                  color: headerColor,
                                  fontSize: isSmall ? 11 : 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                isIn
                                    ? hitungIn(
                                      jamMasuk: data['jam_masuk'],
                                      jamAbsenMasuk: data['jam_absen_masuk'],
                                    )
                                    : hitungOut(
                                      tglMasuk: data['tanggal_masuk'],
                                      jamMasuk: data['jam_absen_masuk'],
                                      tglPulang: data['tanggal_pulang'],
                                      jamPulang: data['jam_absen_pulang'],
                                    ),
                                style: TextStyle(
                                  color: headerColor,
                                  fontSize: isSmall ? 11 : 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// DEVICE INFO
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
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 12,
                                    color:
                                        isDark
                                            ? Colors.white60
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String shiftName({required String shift}) {
  switch (shift) {
    case 'WEEKDAY-PAGI':
      return 'Pagi';
    case 'WEEKDAY-MIDLE':
      return 'Middle';
    case 'WEEKDAY-SIANG/LATE':
      return 'Siang/Late';
    case 'WEEKDAY-LATE DELIVERY':
      return 'Late Delivery';
    case 'WEEKDAY-MIDLE II':
      return 'Middle II';
    default:
      return 'Custom';
  }
}
