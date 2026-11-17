import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/semua_absen/views/semua_absen_view.dart';
import 'package:absensi/app/modules/settings/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/helper/navigator_helper.dart';
import '../../absen/controllers/absen_controller.dart';
import '../../absen/views/absen_view.dart';
import '../../login/controllers/login_controller.dart';
import '../../semua_absen/views/riwayat_visit_view.dart';
import 'modern_bottombar.dart';

class BottomNavBar extends GetView {
  BottomNavBar({super.key}) {
    if (!Get.isRegistered<AbsenController>()) {
      Get.put(AbsenController(), permanent: false);
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: false);
    }
  }

  final logC = Get.find<LoginController>();

  AbsenController get loc => Get.find<AbsenController>();

  HomeController get homeC => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final listDataUser = logC.logUser.value;
    final List<Widget> widgetList = <Widget>[
      Navigator(
        key: AppNavigator.homeKey,
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            settings: settings,
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) => HomeView(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      listDataUser.visit == "1"
          ? Navigator(
            key: AppNavigator.historyKey,
            onGenerateRoute: (settings) {
              return PageRouteBuilder(
                settings: settings,
                opaque: false,
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        RiwayatVisitView(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            },
          )
          : Navigator(
            key: AppNavigator.historyKey,
            onGenerateRoute: (settings) {
              return PageRouteBuilder(
                settings: settings,
                opaque: false,
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        SemuaAbsenView(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            },
          ),
      AbsenView(),
      Navigator(
        key: AppNavigator.settingKey,
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            settings: settings,
            opaque: false,
            pageBuilder:
                (context, animation, secondaryAnimation) => SettingsView(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      Navigator(
        key: AppNavigator.profileKey,
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            settings: settings,
            opaque: false,
            pageBuilder:
                (context, animation, secondaryAnimation) => ProfilView(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final systemBarStyle = SystemUiOverlayStyle(
      // Status bar selalu putih, tidak mengikuti tema.
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,

      // Area navigasi Android mengikuti tema.
      systemNavigationBarColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFF1B2541),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarStyle,
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // // BACKGROUND GLOBAL — cukup satu kali di sini
            // Image.asset(
            //   isDark
            //       ? 'assets/image/bg-ctn-drk.png'
            //       : 'assets/image/bg-ctn.png',
            //   fit: BoxFit.cover,
            // ),

            // KONTEN UTAMA MEMENUHI AREA SCAFFOLD
            Positioned.fill(
              child: Obx(
                () => IndexedStack(
                  index: logC.selected.value,
                  children: widgetList,
                ),
              ),
            ),

            // FLOATING GLASS NAVBAR
            Positioned(
              left: 18,
              right: 18,
              bottom: MediaQuery.of(context).padding.bottom + 8,
              child: Obx(
                () => ModernBottomBar(
                  selectedIndex: logC.selected.value,
                  onTap: (index) async {
                    final uData = logC.logUser.value;
                    // ✅ Jika tab aktif ditekan ulang, kembali ke halaman awal
                    if (logC.selected.value == index) {
                      AppNavigator.getKey(
                        index,
                      )?.currentState?.popUntil((route) => route.isFirst);
                    }

                    if (index == 1) {
                      logC.selectedMenu(index);
                      loc.isLoading.value = true;
                      loc.searchDate.value = "";
                      ///// RESET FORM CI / CO ////////
                      loc.stsAbsenSelected.value = "";
                      loc.optVisitSelected.value = "";
                      loc.selectedCabang.value = "";
                      loc.selectedCabangVisit.value = "";
                      loc.selectedShift.value = "";
                      loc.lat.value = "";
                      loc.long.value = "";
                      // loc.storeLatLng.value = LatLng(
                      //   double.parse(uData.lat!),
                      //   double.parse(uData.long!),
                      // );
                      // loc.refreshZoom(uData);
                      ///////////////////////////////
                      uData.visit == "1"
                          ? loc.getAllVisited(uData.id!, '', '')
                          : loc.getAllAbsen(uData.id!, '', '');
                    } else if (index == 2) {
                      loc.isLoading.value = true;
                      loc.lokasi.value = "";
                      loc.stsAbsenSelected.value = "";
                      loc.optVisitSelected.value = "";
                      loc.selectedCabang.value = "";
                      loc.selectedCabangVisit.value = "";
                      loc.selectedShift.value = "";
                      loc.lat.value = "";
                      loc.long.value = "";
                      // loadingDialog('Finding your location', '');
                      logC.selectedMenu(index);
                      loc.selectedAreaCoverage.value = uData.areaCover!;
                      await loc.getLoc(uData);
                      // loc.triggerSmartZoom();
                      // loc.refreshZoom(uData);
                      // loc.storeLatLng.value = LatLng(
                      //   double.parse(uData.lat!),
                      //   double.parse(uData.long!),
                      // );
                      // Get.back();
                    } else {
                      logC.selectedMenu(index);
                      ///// RESET FORM CI / CO ////////
                      loc.stsAbsenSelected.value = "";
                      loc.optVisitSelected.value = "";
                      loc.selectedCabang.value = "";
                      loc.selectedCabangVisit.value = "";
                      loc.selectedShift.value = "";
                      loc.lat.value = "";
                      loc.long.value = "";
                      // loc.storeLatLng.value = LatLng(
                      //   double.parse(uData.lat!),
                      //   double.parse(uData.long!),
                      // );
                      ///////////////////////////////
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
