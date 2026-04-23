import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
// import 'package:path/path.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/absen_controller.dart';
import 'widget/absen_bottom_sheet.dart';

class AbsenView extends GetView<AbsenController> {
  AbsenView({super.key, this.exitTimeout = const Duration(seconds: 2)});

  final auth = Get.find<LoginController>();
  final absenC = Get.find<AbsenController>();
  final Duration exitTimeout;

  final DraggableScrollableController bottomSheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final data = auth.logUser.value;
    final h = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (absenC.isAppLocked.value) {
          showToast("App is locked!");
          return false;
        }
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
          // backgroundColor: AppColors.itemsBackground,
          title: Text(
            data.visit == "1" ? 'VISIT' : 'PRESENCE',
            style: const TextStyle(color: AppColors.mainTextColor1),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient(
                context: context,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Obx(() {
          final userPoint = LatLng(
            absenC.latFromGps.value,
            absenC.longFromGps.value,
          );
          // print("isOffline: ${absenC.isOffline.value}");
          // print("storeLatLng: ${absenC.storeLatLng.value}");
          final storeLatLng = absenC.storeLatLng.value;

          /// ==========================
          /// 🔥 OFFLINE MODE (PRIORITAS)
          /// ==========================
          if (absenC.isOffline.value) {
            return Stack(
              children: [
                Positioned.fill(child: _offlineView(isDark)),

                _buildBottomSheet(data),

                _buildFAB(h, padding, context, isDark, data),

                _buildOnlineIndicator(),

                _buildSyncIndicator(),

                /// 🔥 LOCK OVERLAY
                if (absenC.isAppLocked.value)
                  Positioned.fill(child: _lockScreen(context, absenC)),
              ],
            );
          }

          /// ==========================
          /// ONLINE tapi data belum siap
          /// ==========================
          if (storeLatLng == null && !absenC.isOffline.value) {
            // print(storeLatLng);
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      const Text(
                        "Loading map data...",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // await controller.initTime(); // 🔥 retry
                          absenC.storeLatLng.value = LatLng(
                            double.parse(data.lat!),
                            double.parse(data.long!),
                          );
                          // print(storeLatLng);
                        },
                        child: const Text("Try again"),
                      ),
                    ],
                  ),
                ),

                if (absenC.isAppLocked.value)
                  Positioned.fill(child: _lockScreen(context, absenC)),
              ],
            );
          }

          final storePoint =
              absenC.storeLatLng.value ??
              LatLng(double.parse(data.lat!), double.parse(data.long!));
          final animatedPoint = interpolate(
            userPoint,
            storePoint,
            absenC.lineProgress.value,
          );

          /// ==========================
          /// NORMAL MODE (ONLINE)
          /// ==========================
          return Stack(
            children: [
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
                      absenC.isMapReady.value = true;
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
                      circles: [
                        CircleMarker(
                          point: storePoint,
                          radius: 30,
                          borderStrokeWidth: 2,
                          color:
                              absenC.isInsideRadius.value
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                          borderColor:
                              absenC.isInsideRadius.value
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ],
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
                              absenC.isInsideRadius.value
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ],
                    ),

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

              _buildBottomSheet(data),
              _buildFAB(h, padding, context, isDark, data),
              _buildOnlineIndicator(),
              _buildSyncIndicator(),

              /// 🔥 LOCK OVERLAY
              if (absenC.isAppLocked.value)
                Positioned.fill(child: _lockScreen(context, absenC)),
            ],
          );
        }),
      ),
    );
  }

  // =======================
  // WIDGET HELPER
  // =======================

  Widget _buildBottomSheet(Data data) {
    return DraggableScrollableSheet(
      controller: bottomSheetController,
      initialChildSize: 0.38,
      minChildSize: 0.35,
      maxChildSize: 0.40,
      builder: (context, scrollController) {
        return AbsenBottomSheet(
          controller: absenC,
          scrollController: scrollController,
        );
      },
    );
  }

  Widget _buildFAB(
    double h,
    double padding,
    BuildContext context,
    bool isDark,
    Data data,
  ) {
    return Positioned(
      right: 16,
      top: (h - padding) / 2 - 28,
      child: Container(
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
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            if (absenC.isAppLocked.value) {
              showToast("Access is locked!");
              return;
            }
            absenC.isLoading.value = true;
            absenC.lokasi.value = "";
            absenC.distanceStore.value = 0.0;
            absenC.scanQrLoc(data);
          },
          child: Icon(
            Icons.qr_code_scanner_outlined,
            color: isDark ? Colors.blue : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Positioned(
      top: 12,
      left: 12,
      child: Obx(() {
        final isOffline = absenC.isOffline.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOffline ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isOffline ? "Offline" : "Online",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSyncIndicator() {
    return Positioned(
      top: 50,
      left: 12,
      child: Obx(() {
        if (!absenC.isSyncing.value) return const SizedBox();
        final current = absenC.syncCurrent.value;
        final total = absenC.syncTotal.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Sync $current / $total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

Widget _lockScreen(BuildContext context, AbsenController controller) {
  return Container(
    color: Colors.black.withOpacity(0.85),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80, color: Colors.red),
          const SizedBox(height: 20),

          const Text(
            "Access Blocked",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Time manipulation detected.\nPlease enable internet or correct device clock.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 25),

          ElevatedButton(
            onPressed: () async {
              await controller.initTime(); // 🔥 retry
            },
            child: const Text("Try again"),
          ),
        ],
      ),
    ),
  );
}

// =======================
// UTIL
// =======================

LatLng interpolate(LatLng start, LatLng end, double progress) {
  return LatLng(
    start.latitude + (end.latitude - start.latitude) * progress,
    start.longitude + (end.longitude - start.longitude) * progress,
  );
}

Widget _offlineView(bool isDark) {
  return Container(
    color: Colors.grey.shade200,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            "Offline Mode",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Map is not available.\nYou can still check in.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey : Colors.black),
          ),
        ],
      ),
    ),
  );
}
