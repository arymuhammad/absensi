import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/views/widget/map_section_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
// import 'package:path/path.dart';
import '../../../data/helper/loading_platform.dart';
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
          final dataUsr = auth.logUser.value;
          final lat = absenC.latFromGps.value;
          final lng = absenC.longFromGps.value;

          final gpsReady =
              lat != 0 &&
              lng != 0 &&
              lat >= -90 &&
              lat <= 90 &&
              lng >= -180 &&
              lng <= 180;

          if (!gpsReady) {
            /// masih loading GPS
            if (absenC.isGpsLoading.value) {
              return Center(child: platFormDevice());
            }

            /// GPS gagal
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 60, color: Colors.red),

                  const SizedBox(height: 12),

                  Text(
                    absenC.gpsError.value.isEmpty
                        ? "Failed to get GPS"
                        : absenC.gpsError.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      absenC.isGpsLoading.value = true;

                      try {
                        final pos = await absenC.determinePosition();

                        absenC.latFromGps.value = pos.latitude;
                        absenC.longFromGps.value = pos.longitude;
                      } catch (_) {}
                    },
                    child: const Text("Retry GPS"),
                  ),
                ],
              ),
            );
          }
          final userPoint = LatLng(lat, lng);
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

                _buildBottomSheet(dataUsr),

                _buildFAB(h, padding, context, isDark, dataUsr),

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
                            double.parse(dataUsr.lat!),
                            double.parse(dataUsr.long!),
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
              LatLng(double.parse(dataUsr.lat!), double.parse(dataUsr.long!));
          final animatedPoint = interpolate(
            userPoint,
            storePoint,
            absenC.lineProgress.value,
          );

          /// ==========================
          /// NORMAL MODE (ONLINE)
          /// ==========================
          // print("STORE POINT => $storePoint");
          return Stack(
            children: [
              Positioned.fill(
                child: MapSectionView(
                  controller: controller,
                  userPoint: userPoint,
                  storePoint: storePoint,
                  animatedPoint: animatedPoint,
                ),
              ),

              _buildBottomSheet(dataUsr),
              _buildFAB(h, padding, context, isDark, dataUsr),
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
