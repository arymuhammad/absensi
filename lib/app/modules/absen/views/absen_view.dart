import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../controllers/absen_controller.dart';

class AbsenView extends GetView<AbsenController> {
  AbsenView(
      {super.key, this.data, this.exitTimeout = const Duration(seconds: 2)});
  final List? data;
  final absenC = Get.put(AbsenController());
  final Duration exitTimeout;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          if (absenC.lastTime == null ||
              DateTime.now().difference(absenC.lastTime!) > exitTimeout) {
            absenC.lastTime = DateTime.now();
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text('Tap back again to exit'),
            //     duration: exitTimeout,
            //   ),
            // );
            showToast('Tap back again to exit');
            return false;
          }
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                data![9] == "26" ? 'VISIT' : 'ABSEN',
                style: const TextStyle(color: AppColors.mainTextColor1),
              ),
              automaticallyImplyLeading: false,
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/image/bgapp.jpg'), // Gantilah dengan path gambar Anda
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                      initialCenter: LatLng(
                          double.parse(data![6]), double.parse(data![7])),
                      initialZoom: 17,
                      maxZoom: 18.4,
                      minZoom: 17),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                            point: LatLng(
                                double.parse(data![6]), double.parse(data![7])),
                            radius: 100,
                            useRadiusInMeter: true,
                            color: const Color.fromARGB(71, 16, 134, 230),
                            borderStrokeWidth: 2,
                            borderColor: const Color.fromARGB(66, 4, 97, 173)),
                      ],
                    ),
                    CurrentLocationLayer(
                      followOnLocationUpdate: FollowOnLocationUpdate.always,
                      turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                      style: const LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          child: Icon(
                            Icons.navigation,
                            color: Colors.white,
                          ),
                        ),
                        markerSize: Size(40, 40),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        )
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 28, // Mengatur posisi di bagian bawah
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: SizedBox(
                        height: 100,
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.map_1_bold,
                              color: Colors.blueAccent[700],
                              size: 80,
                            ),
                            Obx(() => Text(absenC.lokasi.value)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
