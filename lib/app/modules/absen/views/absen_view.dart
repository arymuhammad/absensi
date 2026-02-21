import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/absen_controller.dart';
import 'widget/absen_bottom_sheet.dart';

class AbsenView extends GetView<AbsenController> {
  AbsenView({
    super.key,
    this.data,
    this.exitTimeout = const Duration(seconds: 2),
  });
  final Data? data;
  final absenC = Get.find<AbsenController>();
  final Duration exitTimeout;

  // LatLng? _lastMapPos;
  final DraggableScrollableController bottomSheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () async {
        if (absenC.lastTime == null ||
            DateTime.now().difference(absenC.lastTime!) > exitTimeout) {
          absenC.lastTime = DateTime.now();
          showToast('Tap back again to exit');
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.itemsBackground,
          title: Text(
            data!.visit == "1" ? 'VISIT' : 'ABSEN',
            style: const TextStyle(color: AppColors.mainTextColor1),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Obx(() {
          // final currentPos =
          //     absenC.scannedLatLng.value ??
          //     LatLng(double.parse(data!.lat!), double.parse(data!.long!));

          // Move map only if position changed to avoid flickering
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   final userLatLng =
          //       absenC.scannedLatLng.value ??
          //       LatLng(absenC.latFromGps.value, absenC.longFromGps.value);

          //   final storeLatLng = LatLng(
          //     double.parse(
          //       absenC.lat.isNotEmpty ? absenC.lat.value : data!.lat!,
          //     ),
          //     double.parse(
          //       absenC.long.isNotEmpty ? absenC.long.value : data!.long!,
          //     ),
          //   );

          //   absenC.autoSmartZoom(
          //     userLatLng: userLatLng,
          //     storeLatLng: storeLatLng,
          //     allowedRadius: double.parse(data!.areaCover!),
          //   );
          // });

          // absenC.isTimeUntrusted.value
          //     ? Container(
          //       padding: const EdgeInsets.all(10),
          //       margin: const EdgeInsets.only(bottom: 10),
          //       decoration: BoxDecoration(
          //         color: Colors.red.shade100,
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: const Text(
          //         "⚠️ Jam perangkat tidak valid.\nSilakan aktifkan waktu otomatis.",
          //         textAlign: TextAlign.center,
          //       ),
          //     )
          //     : const SizedBox();

          final userPoint = LatLng(
            absenC.latFromGps.value,
            absenC.longFromGps.value,
          );

          final storeLatLng = absenC.storeLatLng.value;

          if (storeLatLng == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final storePoint = storeLatLng;
          final animatedPoint = interpolate(
            userPoint,
            storePoint,
            absenC.lineProgress.value,
          );

          /// 🔥 SHADOW LINE
          return Stack(
            children: [
              /// ==========================
              /// MAP FULLSCREEN
              /// ==========================
              Positioned.fill(
                child: FlutterMap(
                  mapController: absenC.mapController,
                  options: MapOptions(
                    initialZoom: 17,
                    maxZoom: 19,
                    minZoom: 5,
                    onPositionChanged: (position, _) {
                      if (position.zoom != null) {
                        absenC.currentZoom.value = position.zoom!;
                      }

                      bottomSheetController.animateTo(
                        0.15,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    },
                    onMapReady: () {
                      controller.isMapReady.value = true;
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
                    CircleLayer(
                      circles:
                          absenC.storeLatLng.value != null
                              ? [
                                CircleMarker(
                                  point: absenC.storeLatLng.value!,
                                  radius: 30,
                                  useRadiusInMeter: false,
                                  // color: const Color.fromARGB(71, 16, 134, 230),
                                  borderStrokeWidth: 2,
                                  color:
                                      controller.isInsideRadius.value
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                  borderColor:
                                      controller.isInsideRadius.value
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ]
                              : [],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [userPoint, storePoint],
                          strokeWidth: 6,
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ],
                    ),

                    /// 🔥 DASHED LINE
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [userPoint, animatedPoint],
                          strokeWidth: 3,
                          color:
                              absenC.isInsideRadius.value
                                  ? Colors.green
                                  : Colors.red,
                          // pattern: StrokePattern.dashed(segments: [8, 6]),
                        ),
                      ],
                    ),

                  
                    // CircleLayer(
                    //   circles: [
                    //     if (!(absenC.barcodeScanRes.isNotEmpty &&
                    //             absenC.barcodeScanRes.value.split(' ').length >
                    //                 2 &&
                    //             absenC.barcodeScanRes.value.split(' ')[2] !=
                    //                 "URBAN&CO") &&
                    //         !(absenC.barcodeScanRes.isNotEmpty &&
                    //             absenC.barcodeScanRes.value.split(' ').length <
                    //                 2))
                    //       CircleMarker(
                    //         point: LatLng(
                    //           double.parse(
                    //             absenC.barcodeScanRes.isNotEmpty
                    //                 ? absenC.barcodeScanRes.value.split(' ')[0]
                    //                 : data!.lat!,
                    //           ),
                    //           double.parse(
                    //             absenC.barcodeScanRes.isNotEmpty
                    //                 ? absenC.barcodeScanRes.value.split(' ')[1]
                    //                 : data!.long!,
                    //           ),
                    //         ),
                    //         radius: absenC.dynamicRadius,
                    //         useRadiusInMeter: false,
                    //         color: const Color.fromARGB(71, 16, 134, 230),
                    //         borderStrokeWidth: 2,
                    //         borderColor: const Color.fromARGB(66, 4, 97, 173),
                    //       )
                    //     else
                    //       CircleMarker(
                    //         point: LatLng(
                    //           double.parse(
                    //             absenC.lat.isNotEmpty
                    //                 ? absenC.lat.value
                    //                 : data!.lat!,
                    //           ),
                    //           double.parse(
                    //             absenC.long.isNotEmpty
                    //                 ? absenC.long.value
                    //                 : data!.long!,
                    //           ),
                    //         ),
                    //         radius: absenC.dynamicRadius,
                    //         useRadiusInMeter: false,
                    //         color: const Color.fromARGB(71, 16, 134, 230),
                    //         borderStrokeWidth: 2,
                    //         borderColor: const Color.fromARGB(66, 4, 97, 173),
                    //       ),
                    //   ],
                    // ),
                    CurrentLocationLayer(
                      alignDirectionOnUpdate: AlignOnUpdate.never,
                      style: const LocationMarkerStyle(
                        showAccuracyCircle: false,
                        marker: Icon(
                          Icons.location_on,
                          color: Color(0xFFEA4335),
                          size: 42,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        markerSize: Size(42, 42),
                      ),
                    ),
                  ],
                ),
              ),

              /// ==========================
              /// DRAGGABLE BOTTOM SHEET
              /// ==========================
              DraggableScrollableSheet(
                controller: bottomSheetController,
                initialChildSize: 0.38,
                minChildSize: 0.25,
                maxChildSize: 0.40,
                builder: (context, scrollController) {
                  return AbsenBottomSheet(
                    data: data!,
                    controller: absenC,
                    scrollController: scrollController,
                  );
                },
              ),

              // FAB FIX DI TENGAH KANAN LAYAR
              Positioned(
                right: 16,
                top: (h - padding) / 2 - 28,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
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
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      absenC.isLoading.value = true;
                      absenC.lokasi.value = "";
                      absenC.distanceStore.value = 0.0;
                      absenC.scanQrLoc(data);
                    },
                    child: const Icon(Icons.qr_code_scanner_outlined),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

LatLng interpolate(LatLng start, LatLng end, double progress) {
  return LatLng(
    start.latitude + (end.latitude - start.latitude) * progress,
    start.longitude + (end.longitude - start.longitude) * progress,
  );
}
