import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/absen/views/absen_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../../controllers/absen_controller.dart';
import '../../login/controllers/login_controller.dart';

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
      AbsenView(data: listDataUser!),
      ProfilView(listDataUser: listDataUser!)
    ];
    return Scaffold(
      body: Obx(() =>
          IndexedStack(index: loginC.selected.value, children: widgetList)),
      bottomNavigationBar: Obx(
        () => ConvexAppBar(
          items: [
            const TabItem(icon: HeroIcons.home, title: 'Home'),
            TabItem(icon: TernavIcons.lightOutline.camera),
            const TabItem(icon: CupertinoIcons.person_crop_circle_fill, title: 'Profile'),
          ],
          initialActiveIndex: loginC.selected.value,
          activeColor: Colors.white,
          style: TabStyle.fixedCircle,
          backgroundColor: mainColor,
          onTap: (i) {
            if (i == 1) {
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
