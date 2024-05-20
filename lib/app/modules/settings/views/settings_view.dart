import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/modules/profil/views/about_view.dart';
import 'package:absensi/app/modules/profil/views/backup_view.dart';
import 'package:absensi/app/modules/profil/views/update_profil.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../alarm/views/alarm_view.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key, this.listDataUser});
  final List<dynamic>? listDataUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        ClipPath(
          clipper: ClipPathClass(),
          child: Container(
            height: 380,
            width: Get.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/image/bgapp.jpg'),
                    fit: BoxFit.fill)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 160, left: 15.0, right: 15.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
              height: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        ListTile(
                          title: Text(
                            'Profile Settings',
                            style: TextStyle(
                                color: titleColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Update Profile',
                            style:
                                TextStyle(color: subTitleColor, fontSize: 13),
                          ),
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(TernavIcons.bold.profile,
                                color: mainColor),
                          ),
                          trailing:
                              const Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            Get.to(
                                () => UpdateProfil(
                                      userData: listDataUser!,
                                    ),
                                transition: Transition.cupertino);
                          },
                        ),
                        ListTile(
                          onTap: () {
                            Get.to(() => VerifikasiUpdatePassword(),
                                transition: Transition.cupertino);
                          },
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(TernavIcons.bold.key, color: mainColor),
                          ),
                          title: Text(
                            'Security',
                            style: TextStyle(
                                color: titleColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Change Password',
                              style: TextStyle(
                                  color: subTitleColor, fontSize: 13)),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor),
                        ),
                        ListTile(
                          onTap: () {
                            Get.to(() =>  BackupView(userData:listDataUser!),
                                transition: Transition.cupertino);
                          },
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Bootstrap.database_fill_exclamation,
                                color: mainColor),
                          ),
                          title: Text(
                            'Backup & Restore',
                            style: TextStyle(
                                color: titleColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Backup & Restore Database',
                              style: TextStyle(
                                  color: subTitleColor, fontSize: 13)),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor),
                        ),
                        ListTile(
                          onTap: () {
                            Get.to(() => AlarmView(),
                                transition: Transition.cupertino);
                          },
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Bootstrap.alarm_fill,
                                color: mainColor),
                          ),
                          title: Text(
                            'Alarm',
                            style: TextStyle(
                                color: titleColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Remind me  (BETA Test)',
                              style: TextStyle(
                                  color: subTitleColor, fontSize: 13)),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor),
                        ),
                        Visibility(
                          visible: listDataUser![9] == "1" ? true : false,
                          child: ListTile(
                            onTap: () {
                              Get.toNamed(Routes.ADD_PEGAWAI);
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: bgContainer,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(TernavIcons.bold.add_user,
                                  color: mainColor),
                            ),
                            title: Text(
                              'Manage User',
                              style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Add User',
                                style: TextStyle(
                                    color: subTitleColor, fontSize: 13)),
                            trailing: Icon(Icons.keyboard_arrow_right_rounded,
                                color: subTitleColor),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Get.to(() => AboutView(),
                                transition: Transition.cupertino);
                          },
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child:
                                Icon(TernavIcons.bold.info_1, color: mainColor),
                          ),
                          title: Text(
                            'Info',
                            style: TextStyle(
                                color: titleColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('about version app',
                              style: TextStyle(
                                  color: subTitleColor, fontSize: 13)),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor),
                        ),
                        ListTile(
                          onTap: () {
                            promptDialog(context, 'Anda yakin ingin keluar?');
                          },
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.power_settings_new_sharp,
                                color: Colors.redAccent[700]),
                          ),
                          title: Text('Logout',
                              style: TextStyle(
                                  color: Colors.redAccent[700],
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'exit app',
                            style:
                                TextStyle(color: subTitleColor, fontSize: 13),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
            top: 60,
            left: 20,
            right: 0,
            bottom: 0,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(
                    CupertinoIcons.gear_alt_fill,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Setting',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ))
      ],
    ));
  }
}


