import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/format_waktu.dart';

class DetailVisitView extends GetView {
  const DetailVisitView(this.detailData, {super.key});
  final Map<String, dynamic> detailData;

  @override
  Widget build(BuildContext context) {
    final markersMasuk = <Marker>[
      Marker(
        width: 80,
        height: 80,
        point: LatLng(
          double.parse(detailData["lat_in"]),
          double.parse(detailData["long_in"]),
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
            detailData["lat_out"] != "" ? detailData["lat_out"] : "0.0",
          ),
          double.parse(
            detailData["long_out"] != "" ? detailData["long_out"] : "0.0",
          ),
        ),
        child: const Icon(HeroIcons.map_pin, color: AppColors.contentColorBlue),
      ),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Detail Visit',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        // elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
        flexibleSpace:Container(decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),)
      ),
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 10),
            children: [
              buildCard(
                context: context,
                data: detailData,
                marker: markersMasuk,
                isIn: true,
              ),
              // const SizedBox(height: 10),
              Visibility(
                visible: detailData['jam_out'] == "" ? true : false,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Tidak ada data keluar ',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: detailData['jam_out'] != "" ? true : false,
                child: buildCard(
                  context: context,
                  data: detailData,
                  markerOut: markersPulang,
                  isIn: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildCard({
    required BuildContext context,
    required data,
    List<Marker>? marker,
    List<Marker>? markerOut,
    required bool isIn,
  }) {
    String getGoogleMapsUrl(double lat, double lng) {
      return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }

    final headerColor =
        isIn
            ? const Color(0xFF3E7C59) // hijau check in
            : const Color(0xFFC44747); // merah check out

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
                  isIn ? data['jam_in'] : data['jam_out'],
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
              height: 265,
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
                                  double.parse(data["lat_in"]),
                                  double.parse(data["long_in"]),
                                )
                                : LatLng(
                                  double.parse(
                                    data["lat_out"] != ""
                                        ? data["lat_out"]
                                        : '0.0',
                                  ),
                                  double.parse(
                                    data["long_out"] != ""
                                        ? data["long_out"]
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
                        MarkerLayer(markers: isIn ? marker! : markerOut!),
                      ],
                    ),
                  ),

                  /// ================= ERROR BANNER =================
                  if (!isIn && data['lat_out'] == "")
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8D2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFD9822B),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Failed to get location, please try again',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
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
                                "${ServiceApi().baseUrl}${isIn ? data['foto_in'] : data['foto_out']}",
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
                                  data['store'].toString().capitalize!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                const SizedBox(height: 4),
                                Text(
                                  FormatWaktu.formatIndo(
                                    tanggal: DateTime.parse(data!['tgl_visit']),
                                  ),
                                ),const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.smartphone, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        isIn
                                            ? data['device_info']
                                                .toString()
                                                .capitalize!
                                            : data['device_info2']
                                                .toString()
                                                .capitalize!,
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
