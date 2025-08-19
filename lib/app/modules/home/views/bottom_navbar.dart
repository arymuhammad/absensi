import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/views/absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/semua_absen/views/semua_absen_view.dart';
import 'package:absensi/app/modules/settings/views/settings_view.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

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
      ProfilView(listDataUser: listDataUser),
    ];

    List<TabItem> items = [
      const TabItem(icon: CupertinoIcons.home, title: 'Home'),
      const TabItem(icon: CupertinoIcons.doc_text_search, title: 'History'),
      const TabItem(
        icon: Iconsax.camera_outline,
        title: '',
      ), // Label kosong tetap valid
      const TabItem(icon: CupertinoIcons.gear_alt, title: 'Setting'),
      const TabItem(icon: CupertinoIcons.person_crop_circle, title: 'Profile'),
    ];
    return Scaffold(
      body: Obx(
        () => IndexedStack(index: loginC.selected.value, children: widgetList),
      ),
     
      bottomNavigationBar: Obx(
        () => BottomBarInspiredOutside(
          items: items,
          backgroundColor: AppColors.contentColorWhite,
          indexSelected: loginC.selected.value,
          color: Colors.grey,
          colorSelected: AppColors.contentColorWhite,
          itemStyle: ItemStyle.hexagon,
          elevation: 8,
          padTop: 5,
          padbottom: 2,
          sizeInside: 50,
          chipStyle: const ChipStyle(
            background: AppColors.itemsBackground,
            drawHexagon: true,
          ),
          // chipStyle: ChipStyle(drawHexagon: false),
          fixedIndex: 2,
          fixed: true,
          // Anda bisa sesuaikan warna dan animasi lainnya di sini
          onTap: (int index) {
            if (index == 1) {
              loginC.selectedMenu(index);
              loc.isLoading.value = true;
              loc.searchDate.value = "";
              listDataUser.visit == "1"
                  ? loc.getAllVisited(listDataUser.id!)
                  : loc.getAllAbsen(listDataUser.id!,'','');
            } else if (index == 2) {
              loc.isLoading.value = true;
              loc.lokasi.value = "";
              loc.getLoc(listDataUser);
              loginC.selectedMenu(index);
            } else {
              loginC.selectedMenu(index);
            }
          },
        ),
      ),
    );
  }
}
