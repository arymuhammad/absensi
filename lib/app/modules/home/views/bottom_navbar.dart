import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/views/absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/semua_absen/views/semua_absen_view.dart';
import 'package:absensi/app/modules/settings/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../absen/controllers/absen_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../semua_absen/views/riwayat_visit_view.dart';
import 'modern_bottombar.dart';

class BottomNavBar extends GetView {
  BottomNavBar({super.key, required this.listDataUser});
  final loginC = Get.put(LoginController());
  final loc = Get.put(AbsenController());
  final homeC = Get.put(HomeController());
  final Data listDataUser;

  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = <Widget>[
      Navigator(
        key: navigatorKeys[0],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => HomeView(listDataUser: listDataUser),
          );
        },
      ),
      listDataUser.visit == "1"
          ? Navigator(
            key: navigatorKeys[1],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => RiwayatVisitView(userData: listDataUser),
              );
            },
          )
          : Navigator(
            key: navigatorKeys[1],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => SemuaAbsenView(data: listDataUser),
              );
            },
          ),
      AbsenView(data: listDataUser),
      Navigator(
        key: navigatorKeys[3],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => SettingsView(listDataUser: listDataUser),
          );
        },
      ),
      Navigator(
        key: navigatorKeys[4],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => ProfilView(listDataUser: listDataUser),
          );
        },
      ),
    ];

    // List<TabItem> items = [
    //   const TabItem(icon: CupertinoIcons.home, title: 'Home'),
    //   const TabItem(icon: CupertinoIcons.doc_text_search, title: 'History'),
    //   const TabItem(
    //     icon: Iconsax.camera_outline,
    //     title: '',
    //   ), // Label kosong tetap valid
    //   const TabItem(icon: CupertinoIcons.gear_alt, title: 'Setting'),
    //   const TabItem(icon: CupertinoIcons.person_crop_circle, title: 'Profile'),
    // ];
    return Scaffold(
      body: Obx(
        () => IndexedStack(index: loginC.selected.value, children: widgetList),
      ),

      bottomNavigationBar: Obx(
        () => ModernBottomBar(
          selectedIndex: loginC.selected.value,
          onTap: (index) async {
            // ✅ Jika tab aktif ditekan ulang, kembali ke halaman awal
            if (loginC.selected.value == index) {
              navigatorKeys[index].currentState?.popUntil(
                (route) => route.isFirst,
              );
            }

            if (index == 1) {
              loginC.selectedMenu(index);
              loc.isLoading.value = true;
              loc.searchDate.value = "";
              listDataUser.visit == "1"
                  ? loc.getAllVisited(listDataUser.id!)
                  : loc.getAllAbsen(listDataUser.id!, '', '');
            } else if (index == 2) {
              loc.isLoading.value = true;
              loc.lokasi.value = "";
              // loadingDialog('Finding your location', '');
              loginC.selectedMenu(index);
              await loc.getLoc(listDataUser);
              // Get.back();
            } else {
              loginC.selectedMenu(index);
            }
          },
        ),    
      ),
    );
  }
}
