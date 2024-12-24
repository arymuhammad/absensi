import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/absen_controller.dart';

class AbsenView extends GetView<AbsenController> {
  AbsenView(
      {super.key, this.data, this.exitTimeout = const Duration(seconds: 2)});
  final Data? data;
  final absenC = Get.put(AbsenController());
  final Duration exitTimeout;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
              data!.visit == "1" ? 'VISIT' : 'ABSEN',
              style: const TextStyle(color: AppColors.mainTextColor1),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/image/new_bg_app.jpg'), // Gantilah dengan path gambar Anda
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          body: Obx(
            () => Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                      initialCenter: LatLng(
                          absenC.barcodeScanRes.value.isAlphabetOnly
                              ? 0.0
                              : double.parse(absenC.barcodeScanRes.isNotEmpty &&
                                      absenC.barcodeScanRes.value != "-1"
                                  ? absenC.barcodeScanRes.value.split(' ')[0]
                                  : data!.lat!),
                          absenC.barcodeScanRes.value.isAlphabetOnly
                              ? 0.0
                              : double.parse(absenC.barcodeScanRes.isNotEmpty &&
                                      absenC.barcodeScanRes.value != "-1"
                                  ? absenC.barcodeScanRes.value.split(' ')[1]
                                  : data!.long!)),
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
                                absenC.barcodeScanRes.value.isAlphabetOnly
                                    ? 0.0
                                    : double.parse(absenC
                                                .barcodeScanRes.isNotEmpty &&
                                            absenC.barcodeScanRes.value != "-1"
                                        ? absenC.barcodeScanRes.value
                                            .split(' ')[0]
                                        : data!.lat!),
                                absenC.barcodeScanRes.value.isAlphabetOnly
                                    ? 0.0
                                    : double.parse(absenC
                                                .barcodeScanRes.isNotEmpty &&
                                            absenC.barcodeScanRes.value != "-1"
                                        ? absenC.barcodeScanRes.value
                                            .split(' ')[1]
                                        : data!.long!)),
                            radius: 100,
                            useRadiusInMeter: true,
                            color: const Color.fromARGB(71, 16, 134, 230),
                            borderStrokeWidth: 2,
                            borderColor: const Color.fromARGB(66, 4, 97, 173)),
                      ],
                    ),
                    CurrentLocationLayer(
                      alignPositionOnUpdate: AlignOnUpdate.always,
                      alignDirectionOnUpdate: AlignOnUpdate.never,
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
                            SizedBox(
                              width: 70,
                              child: Icon(
                                FontAwesome.map_location_dot_solid,
                                color: Colors.blueAccent[700],
                                size: 50,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: Get.mediaQuery.size.width / 1.4,
                                child: Text(absenC.lokasi.value)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
