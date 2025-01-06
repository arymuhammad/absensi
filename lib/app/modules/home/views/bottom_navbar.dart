import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/views/absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/semua_absen/views/semua_absen_view.dart';
import 'package:absensi/app/modules/settings/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';

import '../../absen/controllers/absen_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../semua_absen/views/riwayat_visit_view.dart';

class BottomNavBar extends GetView {
  BottomNavBar({super.key, required this.listDataUser});
  final loginC = Get.put(LoginController());
  final loc = Get.put(AbsenController());
  final homeC = Get.put(HomeController());
  final Data listDataUser;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = <Widget>[
      HomeView(listDataUser: listDataUser),
      listDataUser.visit == "1"
          ? RiwayatVisitView(userData: listDataUser)
          : SemuaAbsenView(data: listDataUser),
      AbsenView(data: listDataUser),
      SettingsView(listDataUser: listDataUser),
      ProfilView(listDataUser: listDataUser)
    ];
    return Scaffold(
      body: Obx(() =>
          IndexedStack(index: loginC.selected.value, children: widgetList)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SpeedDial(
        elevation: 20,
        buttonSize: const Size(65, 65),
        closeDialOnPop: true,
        activeIcon: CupertinoIcons.chevron_down,
        renderOverlay: false,
        useRotationAnimation: true,
        switchLabelPosition: true,
        children: [
          SpeedDialChild(
            child: const Icon(
              CupertinoIcons.camera,
              color: Colors.white,
            ),
            onTap: () {
              loginC.selected.value = 2;
              loc.getLoc(listDataUser);
            },
            backgroundColor: Colors.greenAccent[700],
            elevation: 20,
            label: 'Absen',
            labelBackgroundColor: Colors.black,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          SpeedDialChild(
            child: const Icon(
              CupertinoIcons.qrcode_viewfinder,
              color: Colors.white,
            ),
            onTap: () {
              loginC.selected.value = 2;
              loc.scanQrLoc(listDataUser);
            },
            backgroundColor: Colors.blueAccent[700],
            elevation: 20,
            label: 'Scan QR',
            labelBackgroundColor: Colors.black,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
        child: const Icon(CupertinoIcons.chevron_up),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            backgroundColor: Colors.blue,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[400],
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.doc_text_search), label: 'History'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.chevron_up_circle_fill), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.gear_alt), label: 'Setting'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_crop_circle),
                  label: 'Profile'),
            ],
            currentIndex: loginC.selected.value,
            onTap: (i) {
              if (i == 1) {
                loginC.selectedMenu(i);
                loc.isLoading.value = true;
                loc.searchDate.value = "";
                listDataUser.visit == "1"
                    ? loc.getAllVisited(listDataUser.id!)
                    : loc.getAllAbsen(listDataUser.id!);
              } else {
                loginC.selectedMenu(i);
              }
            },
          )),
    );
  }
}
