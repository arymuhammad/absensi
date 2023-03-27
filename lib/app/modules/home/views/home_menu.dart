import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../../controllers/absen_controller.dart';
import '../../login/controllers/login_controller.dart';

class HomeMenu extends GetView {
  HomeMenu({super.key, this.listDataUser});
  final loginC = Get.put(LoginController());
  final loc = Get.put(AbsenController());
  final List? listDataUser;

  selectedMenu(index) {
    loginC.selected.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = <Widget>[
      HomeView(listDataUser: listDataUser!),
      Container(),
      ProfilView(listDataUser: listDataUser!)
    ];

    return Scaffold(
      body: Obx(() =>
          IndexedStack(index: loginC.selected.value, children: widgetList)),
      bottomNavigationBar: Obx(
        () => ConvexAppBar(
          items:  [
            TabItem(icon: TernavIcons.light.home, title: 'Home'),
            TabItem(icon: TernavIcons.lightOutline.camera),
            TabItem(icon: TernavIcons.light.profile, title: 'Profile'),
          ],
          initialActiveIndex: loginC.selected.value,
          activeColor: Colors.white,
          style: TabStyle.fixedCircle,
          backgroundColor: mainColor,
          onTap: (i) {
            if (i == 1) {
              // Get.defaultDialog(
              //     title: 'Absen',
              //     middleText:
              //         'Sedang memindai lokasi absen Anda\nHarap Menunggu selama proses berjalan');
              loc.getLoc(listDataUser!);
              // Future.delayed(const Duration(seconds: 2), () {
              //   Get.back();
              // });
            } else {
              selectedMenu(i);
            }
            // print(i);
          },
        ),
      ),
    );
  }
}
