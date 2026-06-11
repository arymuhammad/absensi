import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/absen_controller.dart';

class MapSectionView extends StatelessWidget {
  MapSectionView({
    super.key,
    required this.controller,
    required this.userPoint,
    required this.storePoint,
    required this.animatedPoint,
  });

  final AbsenController controller;
  final LatLng userPoint;
  final LatLng storePoint;
  final LatLng animatedPoint;

  final DraggableScrollableController bottomSheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: userPoint,
        initialZoom: 17,
        maxZoom: 19,
        minZoom: 5,
        onPositionChanged: (position, hasGesture) async {
          if (!controller.isMapReady.value) return;

          if (position.zoom != null) {
            controller.currentZoom.value = position.zoom!;
          }
          if (!hasGesture) return;

          if (controller.isSheetAnimating.value) return;

          controller.isSheetAnimating.value = true;

          try {
            await bottomSheetController.animateTo(
              bottomSheetController.size > 0.35
                  ? 0.35
                  : bottomSheetController.size,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } catch (_) {}
          controller.isSheetAnimating.value = false;
        },
        onMapReady: () {
          controller.isMapReady.value = true;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.absensi.urbanco',
          maxNativeZoom: 19,
          tileSize: 256,
          retinaMode: true,
        ),

        Obx(
          () => CircleLayer(
            circles: [
              CircleMarker(
                point: storePoint,
                radius: 30,
                borderStrokeWidth: 2,
                color:
                    controller.isInsideRadius.value
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                borderColor:
                    controller.isInsideRadius.value ? Colors.green : Colors.red,
              ),
            ],
          ),
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

        PolylineLayer(
          polylines: [
            Polyline(
              points: [userPoint, animatedPoint],
              strokeWidth: 3,
              color:
                  controller.isInsideRadius.value ? Colors.green : Colors.red,
            ),
          ],
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: userPoint,
              width: 50,
              height: 50,
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFEA4335),
                size: 42,
              ),
            ),
          ],
        ),
        // CurrentLocationLayer(
        //   alignDirectionOnUpdate: AlignOnUpdate.never,
        //   style: const LocationMarkerStyle(
        //     showAccuracyCircle: false,
        //     marker: Icon(
        //       Icons.location_on,
        //       color: Color(0xFFEA4335),
        //       size: 42,
        //       shadows: [
        //         Shadow(
        //           color: Colors.black38,
        //           blurRadius: 6,
        //           offset: Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     markerSize: Size(42, 42),
        //   ),
        // ),
      ],
    );
  }
}
