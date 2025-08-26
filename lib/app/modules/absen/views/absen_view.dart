import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/views/widget/absen_form.dart';
import 'package:absensi/app/modules/absen/views/widget/check_in.dart';
import 'package:absensi/app/modules/absen/views/widget/visit_form.dart';
import 'package:absensi/app/modules/absen/views/widget/visit_out.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:slider_button/slider_button.dart';
import '../controllers/absen_controller.dart';
import 'widget/check_out.dart';
import 'widget/visit_in.dart';

class AbsenView extends GetView<AbsenController> {
  AbsenView({
    super.key,
    this.data,
    this.exitTimeout = const Duration(seconds: 2),
  });
  final Data? data;
  final absenC = Get.find<AbsenController>();
  final Duration exitTimeout;
  final mapController = MapController();

  LatLng? _lastMapPos;

  @override
  Widget build(BuildContext context) {
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
          actions: [
            IconButton(
              onPressed: () {
                absenC.isLoading.value = true;
                absenC.lokasi.value = "";
                absenC.distanceStore.value = 0.0;
                absenC.scanQrLoc(data);
              },
              icon: const Icon(Icons.qr_code_scanner_outlined),
            ),
          ],
        ),
        body: Obx(() {
          final currentPos =
              absenC.scannedLatLng.value ??
              LatLng(double.parse(data!.lat!), double.parse(data!.long!));

          // Move map only if position changed to avoid flickering
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_lastMapPos == null || _lastMapPos != currentPos) {
              mapController.move(currentPos, 17);
              _lastMapPos = currentPos;
            }
          });

          return Stack(
            children: [
              // Scrollable area fill excluding bottom fixed button
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                    ), // space for slider button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        data!.visit == "1"
                            ? buildVisit(data: data)
                            : buildAbsen(data: data),
                       
                        const SizedBox(height: 10),
                        Text(
                          'Your Current Location',
                          style: titleTextStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              HeroIcons.map_pin,
                              color: Colors.blueAccent[700],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            absenC.isLoading.value
                                ? Row(
                                  children: [
                                    const Text('Checking Your Location...'),
                                    const SizedBox(width: 5),
                                    Platform.isAndroid
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(),
                                        )
                                        : const CupertinoActivityIndicator(),
                                  ],
                                )
                                : SizedBox(
                                  width: Get.mediaQuery.size.width / 1.4,
                                  child: Text(
                                    absenC.lokasi.value,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          absenC.locNote.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                absenC.distanceStore.value >
                                        num.parse(data!.areaCover!)
                                    ? red
                                    : green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: currentPos,
                              initialZoom: 17,
                              maxZoom: 18.4,
                              minZoom: 17,
                              onMapReady: () {
                                mapController.move(currentPos, 17);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                userAgentPackageName:
                                    'dev.fleaflet.flutter_map.example',
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: LatLng(
                                      absenC.barcodeScanRes.isNotEmpty &&
                                                  absenC.barcodeScanRes.value
                                                          .split(' ')
                                                          .length >
                                                      2 &&
                                                  absenC.barcodeScanRes.value
                                                          .split(' ')[2] !=
                                                      "URBAN&CO" ||
                                              absenC
                                                      .barcodeScanRes
                                                      .isNotEmpty &&
                                                  absenC.barcodeScanRes.value
                                                          .split(' ')
                                                          .length <
                                                      2
                                          ? 0.0
                                          : double.parse(
                                            absenC.barcodeScanRes.isNotEmpty
                                                ? absenC.barcodeScanRes.value
                                                    .split(' ')[0]
                                                : data!.lat!,
                                          ),
                                      absenC.barcodeScanRes.isNotEmpty &&
                                                  absenC.barcodeScanRes.value
                                                          .split(' ')
                                                          .length >
                                                      2 &&
                                                  absenC.barcodeScanRes.value
                                                          .split(' ')[2] !=
                                                      "URBAN&CO" ||
                                              absenC
                                                      .barcodeScanRes
                                                      .isNotEmpty &&
                                                  absenC.barcodeScanRes.value
                                                          .split(' ')
                                                          .length <
                                                      2
                                          ? 0.0
                                          : double.parse(
                                            absenC.barcodeScanRes.isNotEmpty
                                                ? absenC.barcodeScanRes.value
                                                    .split(' ')[1]
                                                : data!.long!,
                                          ),
                                    ),
                                    radius: 100,
                                    useRadiusInMeter: true,
                                    color: const Color.fromARGB(
                                      71,
                                      16,
                                      134,
                                      230,
                                    ),
                                    borderStrokeWidth: 2,
                                    borderColor: const Color.fromARGB(
                                      66,
                                      4,
                                      97,
                                      173,
                                    ),
                                  ),
                                ],
                              ),
                              CurrentLocationLayer(
                                alignPositionOnUpdate: AlignOnUpdate.always,
                                alignDirectionOnUpdate: AlignOnUpdate.never,
                                style: const LocationMarkerStyle(
                                  marker: DefaultLocationMarker(
                                    child: Icon(
                                      HeroIcons.map_pin,
                                      color: Colors.white,
                                    ),
                                  ),
                                  markerSize: Size(40, 40),
                                  markerDirection: MarkerDirection.top,
                                ),
                              ),
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // SliderButton fixed at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: AppColors.contentColorWhite,
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SliderButton(
                      backgroundColor: AppColors.itemsBackground.withOpacity(
                        absenC.isEnabled.value ? 1.0 : 0.5,
                      ),
                      buttonSize: 55,
                      buttonColor:
                          absenC.isEnabled.value
                              ? AppColors.contentColorWhite
                              : Colors.grey,
                      alignLabel: Alignment.center,
                      baseColor:
                          absenC.isEnabled.value
                              ? AppColors.borderColor
                              : Colors.grey,
                      height: 65,
                      shimmer: absenC.isEnabled.value,
                      action: () async {
                        if (!absenC.isEnabled.value) return false;
                        if (data!.visit == "1") {
                          if (absenC.stsAbsenSelected.isEmpty) {
                            showToast("please select check in / out first");
                          } else if (absenC.optVisitSelected.isEmpty) {
                            showToast("please select RND / Visit first");
                          } else if (absenC.optVisitSelected.isNotEmpty &&
                              absenC.optVisitSelected.value ==
                                  "Research and Development" &&
                              absenC.rndLoc.text.isEmpty) {
                            showToast(
                              "please fill in the location of the mall/city",
                            );
                          } else {
                            loadingDialog("open the camera", "");
                            absenC.stsAbsenSelected.value == "Check In"
                                ? await visitIn(
                                  dataUser: data!,
                                  latitude: absenC.latFromGps.value,
                                  longitude: absenC.longFromGps.value,
                                )
                                : await visitOut(
                                  dataUser: data!,
                                  latitude: absenC.latFromGps.value,
                                  longitude: absenC.longFromGps.value,
                                );
                            // await Future.delayed(const Duration(seconds: 3));
                            // Get.back();
                          }
                        } else {
                          if (absenC.stsAbsenSelected.isEmpty) {
                            showToast("please select check in / out first");
                          } else if (absenC.stsAbsenSelected.value !=
                                  "Check Out" &&
                              absenC.selectedShift.isEmpty) {
                            showToast("please select shift first");
                          } else {
                            loadingDialog("open the camera", "");
                            absenC.stsAbsenSelected.value == "Check In"
                                ? await checkIn(
                                  data!,
                                  absenC.latFromGps.value,
                                  absenC.longFromGps.value,
                                )
                                : await checkOut(
                                  data!,
                                  absenC.latFromGps.value,
                                  absenC.longFromGps.value,
                                );
                            // await Future.delayed(const Duration(seconds: 3));
                            // Get.back();
                          }
                        }

                        return false;
                      },
                      label: Text(
                        data!.visit == "1"
                            ? absenC.stsAbsenSelected.isEmpty
                                ? 'please select \ncheck in / out first'
                                : absenC.optVisitSelected.isNotEmpty
                                ? ' Swipe to ${absenC.optVisitSelected.value == "Research and Development" ? 'RND' : absenC.optVisitSelected.value}'
                                : 'please select \nRND / Visit first'
                            : absenC.stsAbsenSelected.isNotEmpty
                            ? ' Swipe to ${absenC.stsAbsenSelected.value}'
                            : 'please select \ncheck in / out first',
                        style: const TextStyle(
                          color: AppColors.contentColorWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      icon: Icon(
                        absenC.stsAbsenSelected.value.contains("Break")
                            ? Iconsax.coffee_bold
                            : Icons.double_arrow_rounded,
                        color: AppColors.itemsBackground,
                      ),
                    ),
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
