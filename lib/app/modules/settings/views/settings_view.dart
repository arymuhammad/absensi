import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/add_pegawai/views/add_pegawai_view.dart';
import 'package:absensi/app/modules/settings/views/about_view.dart';
import 'package:absensi/app/modules/settings/views/backup_view.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
// import '../../alarm/views/alarm_view.dart';
import '../../../data/theme_controller.dart';
import '../../../data/theme_switcher.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/settings_controller.dart';
import 'faq_view.dart';

class SettingsView extends GetView<SettingsController> {
  SettingsView({super.key});

  final auth = Get.find<LoginController>();
  final ctrl = Get.put(AddPegawaiController());
  final themeC = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    final listDataUser = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // const CsBgImg(
          // ),
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient(
                context: context,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 110, left: 15.0, right: 15.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(
                          left: 10,
                          top: 10,
                          right: 10,
                        ),
                        children: [
                          // ListTile(
                          //   title: Text(
                          //     'Profile Settings',
                          //     style: TextStyle(
                          //       color: titleColor,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     'Update Profile',
                          //     style: TextStyle(
                          //       color: subTitleColor,
                          //       fontSize: 13,
                          //     ),
                          //   ),
                          //   leading: Container(
                          //     height: 40,
                          //     width: 40,
                          //     decoration: BoxDecoration(
                          //       color: bgContainer,
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: const Icon(
                          //       Iconsax.profile_circle_bold,
                          //       color: AppColors.itemsBackground,
                          //     ),
                          //   ),
                          //   trailing: const Icon(
                          //     Icons.keyboard_arrow_right_rounded,
                          //   ),
                          //   onTap: () {
                          //     Get.to(
                          //       () => UpdateProfil(userData: listDataUser!),
                          //       transition: Transition.cupertino,
                          //     );
                          //   },
                          // ),
                          // ListTile(
                          //   title: Text(
                          //     'Data Wajah',
                          //     style: TextStyle(
                          //         color: titleColor, fontWeight: FontWeight.bold),
                          //   ),
                          //   subtitle: Text(
                          //     'Data Wajah Pengguna',
                          //     style:
                          //         TextStyle(color: subTitleColor, fontSize: 13),
                          //   ),
                          //   leading: Container(
                          //     height: 40,
                          //     width: 40,
                          //     decoration: BoxDecoration(
                          //         color: bgContainer,
                          //         borderRadius: BorderRadius.circular(8)),
                          //     child:
                          //         Icon(FontAwesome.face_smile, color: AppColors.itemsBackground),
                          //   ),
                          //   trailing:
                          //       const Icon(Icons.keyboard_arrow_right_rounded),
                          //   onTap: () {
                          //     Get.to(() {
                          //       ctrl.getFaceData(listDataUser!.id!);
                          //       return FaceDataView(
                          //         idUser: listDataUser!.id!,
                          //       );
                          //     }, transition: Transition.cupertino);
                          //   },
                          // ),
                          ListTile(
                            onTap: () {
                              // Get.to(
                              //   () => VerifikasiUpdatePassword(),
                              //   transition: Transition.cupertino,
                              // );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VerifikasiUpdatePassword(),
                                ),
                              );
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.blue.withOpacity(0.15)
                                        : bgContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Iconsax.key_bulk,
                                color:
                                    isDark
                                        ? Colors.blue
                                        : AppColors.itemsBackground,
                              ),
                            ),
                            title: const Text(
                              'Security',
                              style: TextStyle(
                                // color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Change Password',
                              style: TextStyle(
                                color: subTitleColor,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor,
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              // Get.to(
                              //   () => BackupView(userData: listDataUser!),
                              //   transition: Transition.cupertino,
                              // );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          BackupView(),
                                ),
                              );
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.blue.withOpacity(0.15)
                                        : bgContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Bootstrap.database_fill_exclamation,
                                color:
                                    isDark
                                        ? Colors.blue
                                        : AppColors.itemsBackground,
                              ),
                            ),
                            title: const Text(
                              'Backup & Restore',
                              style: TextStyle(
                                // color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Backup & Restore Database',
                              style: TextStyle(
                                color: subTitleColor,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor,
                            ),
                          ),

                          // REMOVE ALARM FITURE
                          // ListTile(
                          //   onTap: () {
                          //     Get.to(() => AlarmView(),
                          //         transition: Transition.cupertino);
                          //   },
                          //   leading: Container(
                          //     height: 40,
                          //     width: 40,
                          //     decoration: BoxDecoration(
                          //         color: bgContainer,
                          //         borderRadius: BorderRadius.circular(8)),
                          //     child: Icon(Bootstrap.alarm_fill, color: AppColors.itemsBackground),
                          //   ),
                          //   title: Text(
                          //     'Alarm',
                          //     style: TextStyle(
                          //         color: titleColor, fontWeight: FontWeight.bold),
                          //   ),
                          //   subtitle: Text('Remind me  (BETA Test)',
                          //       style: TextStyle(
                          //           color: subTitleColor, fontSize: 13)),
                          //   trailing: Icon(Icons.keyboard_arrow_right_rounded,
                          //       color: subTitleColor),
                          // ),
                          Visibility(
                            visible: listDataUser.level == "1" ? true : false,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddPegawaiView(),
                                  ),
                                );
                              },
                              leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.blue.withOpacity(0.15)
                                          : bgContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Iconsax.user_add_bold,
                                  color:
                                      isDark
                                          ? Colors.blue
                                          : AppColors.itemsBackground,
                                ),
                              ),
                              title: const Text(
                                'Manage User',
                                style: TextStyle(
                                  // color: titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Add User',
                                style: TextStyle(
                                  color: subTitleColor,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: subTitleColor,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              // Get.to(
                              //   () => AboutView(),
                              //   transition: Transition.cupertino,
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FaqView(),
                                ),
                              );
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.blue.withOpacity(0.15)
                                        : bgContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Iconsax.message_question_bold,
                                color:
                                    isDark
                                        ? Colors.blue
                                        : AppColors.itemsBackground,
                              ),
                            ),
                            title: const Text(
                              'FAQ',
                              style: TextStyle(
                                // color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '(Frequently Asked Questions)',
                              style: TextStyle(
                                color: subTitleColor,
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor,
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              // Get.to(
                              //   () => AboutView(),
                              //   transition: Transition.cupertino,
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AboutView()),
                              );
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.blue.withOpacity(0.15)
                                        : bgContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Iconsax.info_circle_bold,
                                color:
                                    isDark
                                        ? Colors.blue
                                        : AppColors.itemsBackground,
                              ),
                            ),
                            title: const Text(
                              'Info',
                              style: TextStyle(
                                // color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'about version app',
                              style: TextStyle(
                                color: subTitleColor,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor,
                            ),
                          ),
                          // ListTile(
                          //   onTap: () async {
                          //     // Get.to(
                          //     //   () => AboutView(),
                          //     //   transition: Transition.cupertino,
                          //     // );
                          //     // Navigator.push(
                          //     //   context,
                          //     //   MaterialPageRoute(builder: (_) => AboutView()),
                          //     // );

                          //     const nomor =
                          //         '6285124034523'; // format tanpa 0, pakai kode negara
                          //     final pesan = Uri.encodeComponent(
                          //       'Halo, ini pesan dari Flutter',
                          //     );

                          //     final url = Uri.parse(
                          //       'https://api.whatsapp.com/send?phone=$nomor&text=$pesan',
                          //     );

                          //     // if (await canLaunchUrl(url)) {
                          //     await launchUrl(url);
                          //     // } else {
                          //     // throw 'Tidak bisa buka WhatsApp';
                          //     // }
                          //   },
                          //   leading: Container(
                          //     height: 40,
                          //     width: 40,
                          //     decoration: BoxDecoration(
                          //       color:
                          //           isDark
                          //               ? Colors.blue.withOpacity(0.15)
                          //               : bgContainer,
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: Icon(
                          //       Iconsax.info_circle_bold,
                          //       color:
                          //           isDark
                          //               ? Colors.blue
                          //               : AppColors.itemsBackground,
                          //     ),
                          //   ),
                          //   title: const Text(
                          //     'Kirim WA',
                          //     style: TextStyle(
                          //       // color: titleColor,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     'Send chat',
                          //     style: TextStyle(
                          //       color: subTitleColor,
                          //       fontSize: 13,
                          //     ),
                          //   ),
                          //   trailing: Icon(
                          //     Icons.keyboard_arrow_right_rounded,
                          //     color: subTitleColor,
                          //   ),
                          // ),
                          // ListTile(
                          //   onTap: () {
                          //     promptDialog(
                          //       context: context,
                          //       title: 'LOG OUT',
                          //       desc: 'Anda yakin ingin keluar?',
                          //       btnOkOnPress: () => auth.logout(),
                          //     );
                          //   },
                          //   leading: Container(
                          //     height: 40,
                          //     width: 40,
                          //     decoration: BoxDecoration(
                          //       color: bgContainer,
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: Icon(
                          //       Icons.power_settings_new_sharp,
                          //       color: Colors.redAccent[700],
                          //     ),
                          //   ),
                          //   title: Text(
                          //     'Logout',
                          //     style: TextStyle(
                          //       color: Colors.redAccent[700],
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     'exit app',
                          //     style: TextStyle(
                          //       color: subTitleColor,
                          //       fontSize: 13,
                          //     ),
                          //   ),
                          //   trailing: Icon(
                          //     Icons.keyboard_arrow_right_rounded,
                          //     color: subTitleColor,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1.0),
                      child: Icon(
                        CupertinoIcons.gear_alt_fill,
                        size: 25,
                        color: AppColors.contentColorWhite,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Setting',
                      style: titleTextStyle.copyWith(
                        fontSize: 18,
                        color: AppColors.contentColorWhite,
                      ),
                    ),
                  ],
                ),
                const ThemeSwitcher(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
