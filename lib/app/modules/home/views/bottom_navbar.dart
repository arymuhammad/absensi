import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/absen/views/absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/semua_absen/views/semua_absen_view.dart';
import 'package:absensi/app/modules/settings/views/settings_view.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/absen_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../semua_absen/views/riwayat_visit_view.dart';

class BottomNavBar extends GetView {
  BottomNavBar({super.key, this.listDataUser});
  final loginC = Get.put(LoginController());
  final loc = Get.put(AbsenController());
  final homeC = Get.put(HomeController());
  final List? listDataUser;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = <Widget>[
      HomeView(listDataUser: listDataUser!),
      listDataUser![12]=="1"? RiwayatVisitView(userData:listDataUser!): SemuaAbsenView(data: listDataUser!),
      AbsenView(data: listDataUser!),
      SettingsView(listDataUser: listDataUser!),
      ProfilView(listDataUser: listDataUser!)
    ];
    return Scaffold(
      body: Obx(() =>
          IndexedStack(index: loginC.selected.value, children: widgetList)),
      bottomNavigationBar: Obx(
        () => ConvexAppBar(
          items: const [
            TabItem(icon: CupertinoIcons.home, title: 'Home'),
            TabItem(icon: CupertinoIcons.doc_text_search, title: 'History'),
            TabItem(icon: CupertinoIcons.camera),
            TabItem(icon: CupertinoIcons.gear_alt, title: 'Setting'),
            TabItem(icon: CupertinoIcons.person_crop_circle, title: 'Profile'),
          ],
          initialActiveIndex: loginC.selected.value,
          activeColor: Colors.white,
          style: TabStyle.fixedCircle,
          backgroundColor: mainColor,
          onTap: (i) {
            if (i == 1) {
              loginC.selectedMenu(i);
              loc.isLoading.value = true;
              loc.searchDate.value = "";
              listDataUser![12]=="1"? loc.getAllVisited(listDataUser![0]): loc.getAllAbsen(listDataUser![0]);
            } else if (i == 2) {
              loginC.selectedMenu(i);
              loc.getLoc(listDataUser);
            } else {
              loginC.selectedMenu(i);
            }
          },
        ),
      ),
    );
  }
}
