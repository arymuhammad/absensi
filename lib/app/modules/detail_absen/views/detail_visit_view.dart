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
      ),
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(12, 100, 12, 10),
            children: [
              buildCard(
                context: context,
                data: detailData,
                marker: markersMasuk,
                isIn: true,
              ),
              const SizedBox(height: 10),
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: AppColors.itemsBackground,
            ),
            child: Center(
              child: Text(
                FormatWaktu.formatIndo(
                  tanggal: DateTime.parse(data!['tgl_visit']),
                ),
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
                      MarkerLayer(markers: isIn ? marker! : markerOut!),
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
                                "${ServiceApi().baseUrl}${isIn ? data['foto_in'] : data['foto_out']}",
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
                                    const SizedBox(
                                      width: 72,
                                      child: Text('Name')),
                                 
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
                                    const SizedBox(
                                      width: 72,
                                      child: Text('Store')),
                                    SizedBox(
                                      width: Get.mediaQuery.size.width * 0.35,
                                      child: Text(': ${data['store'].toString().capitalize}',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      child: Text(isIn ? 'Check In' : 'Check Out')),
                                    Text(
                                      ': ${isIn ? data['jam_in'] : data['jam_out']}',
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 72,
                                      child: Text('Device Info')),
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                      ),
                                      child: Text(
                                        ": ${isIn ? data['device_info'].toString().capitalize : data['device_info2'].toString().capitalize}",
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
                  // Row(
                  //   children: [
                  //     RoundedImage(
                  //       height: 75,
                  //       width: 75,
                  //       foto: data['foto_profil'],
                  //       name: data['foto_profil'],
                  //       headerProfile: true,
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Row(
                  //       children: [
                  //         Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 const Text('Nama'),
                  //                 const SizedBox(width: 5),
                  //                 const SizedBox(width: 44),
                  //                 Text(
                  //                   ': ${data["nama"].toString().capitalize}',
                  //                 ),
                  //               ],
                  //             ),
                  //             Row(
                  //               children: [
                  //                 const Text('Masuk'),
                  //                 const SizedBox(width: 45),
                  //                 Text(': ${data['jam_in']}'),
                  //               ],
                  //             ),
                  //             Row(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 const Text('Store'),
                  //                 const SizedBox(width: 45),
                  //                 SizedBox(
                  //                   // padding: const EdgeInsets.all(10.0),
                  //                   width: Get.mediaQuery.size.width * 0.42,
                  //                   child: Column(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Text(
                  //                         '  : ${data['store']}',
                  //                         textAlign: TextAlign.left,
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.end,
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 const Text('Device Info'),
                  //                 const SizedBox(width: 16),
                  //                 Container(
                  //                   constraints: BoxConstraints(
                  //                     maxWidth:
                  //                         MediaQuery.of(context).size.width *
                  //                         0.3,
                  //                   ),
                  //                   child: Text(": ${data['device_info']}"),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SizedBox(
          //     height: 200,
          //     child: ,
          //   ),
          // ),
        ],
      ),
    );
  }
}
