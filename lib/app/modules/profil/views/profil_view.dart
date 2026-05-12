import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../add_pegawai/controllers/add_pegawai_controller.dart';
import '../../shared/elevated_button.dart';
import '../controllers/profil_controller.dart';
import 'update_profil.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key});

  final auth = Get.find<LoginController>();
  final ctr = Get.find<AddPegawaiController>();
  final absC = Get.find<AbsenController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// HEADER GRADIENT + GLOW
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient(
                context: context,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// GLOW EFFECT
          // Positioned(
          //   top: 80,
          //   left: -40,
          //   right: -40,
          //   child: Container(
          //     height: 200,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(200),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.blueAccent.withOpacity(.35),
          //           blurRadius: 120,
          //           spreadRadius: 20,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          /// BACKGROUND CARD BESAR
          Positioned(
            top: 180,
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? const Color(0xFF121212) // dark surface
                        : const Color(0xFFF2F4F8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),

          /// CONTENT AREA
          Obx(() {
            final listDataUser = auth.logUser.value;
            final imgUrl = '${ServiceApi().baseUrl}${listDataUser.foto!}';
            return Padding(
              padding: const EdgeInsets.only(top: 100, left: 22, right: 22),
              child: Column(
                children: [
                  /// AVATAR FLOATING
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.25),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child:
                            absC.isOffline.value
                                ? Container(
                                  color: Colors.white,
                                  child: Image.asset('assets/image/selfie.png'),
                                )
                                : InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.black,
                                          insetPadding: const EdgeInsets.all(0),
                                          child: GestureDetector(
                                            onTap:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(
                                                '${ServiceApi().baseUrl}${listDataUser.foto!}',
                                              ),
                                              backgroundDecoration:
                                                  const BoxDecoration(
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    listDataUser.foto != ""
                                        ? imgUrl
                                        : "https://ui-avatars.com/api/?name=${listDataUser.nama!}",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// NAME
                  Text(
                    listDataUser.nama!,
                    style: titleTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // const SizedBox(height: 5),

                  /// USER INFO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(listDataUser.id!, style: subtitleTextStyle),
                      Text(' - ', style: subtitleTextStyle),
                      Text(listDataUser.levelUser!, style: subtitleTextStyle),
                      Visibility(
                        visible: listDataUser.idRegion! != "",
                        child: Row(
                          children: [
                            Text(' - ', style: subtitleTextStyle),
                            Text(
                              listDataUser.idRegion!,
                              style: subtitleTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// MAIN LIST
                  Expanded(
                    child: CustomMaterialIndicator(
                      onRefresh: () async {
                        final online = await absC.isOnline();
                        if (online) {
                          await ctr.getLastUserData(dataUser: listDataUser);
                          showToast('Page Refreshed');
                        } else {
                          showToast('No Internet Connection, try again later ');
                        }
                      },
                      backgroundColor: isDark ? Colors.black : Colors.white,
                      indicatorBuilder: (context, controller) {
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child:
                              Platform.isAndroid
                                  ? CircularProgressIndicator(
                                    color: AppColors.itemsBackground,
                                    value:
                                        controller.state.isLoading
                                            ? null
                                            : math.min(controller.value, 1.0),
                                  )
                                  : const CupertinoActivityIndicator(),
                        );
                      },
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          /// CARD DATA USER
                          SizedBox(
                            height: 250,
                            child: Card(
                              color:
                                  isDark
                                      ? Theme.of(context)
                                          .cardColor // dark surface
                                      : const Color(0xFFF2F4F8),
                              elevation: 8,
                              shadowColor:
                                  isDark ? Colors.black54 : Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.blue.withOpacity(
                                                      0.15,
                                                    )
                                                    : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.account_circle,
                                            size: 15,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Username',
                                          style: subtitleTextStyle,
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      listDataUser.username!,
                                      style: titleTextStyle,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    dense: true,
                                  ),
                                  const Divider(height: 0),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.blue.withOpacity(
                                                      0.15,
                                                    )
                                                    : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.work,
                                            size: 15,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Employee ID',
                                          style: subtitleTextStyle,
                                        ),
                                      ],
                                    ),
                                    trailing:
                                        listDataUser.nik!.isEmpty
                                            ? CsElevatedButton(
                                              color: AppColors.itemsBackground,
                                              fontsize: 12,
                                              label: 'Generate ID',
                                              onPressed:
                                                  listDataUser.createdAt! == ""
                                                      ? null
                                                      : () {
                                                        ctr.generateEmpId(
                                                          listDataUser,
                                                        );
                                                      },
                                            )
                                            : Text(
                                              listDataUser.nik!,
                                              style: titleTextStyle,
                                            ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    dense: true,
                                  ),
                                  const Divider(height: 0),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.blue.withOpacity(
                                                      0.15,
                                                    )
                                                    : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.phone,
                                            size: 15,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Phone No.',
                                          style: subtitleTextStyle,
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      listDataUser.noTelp!,
                                      style: titleTextStyle,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    dense: true,
                                  ),
                                  const Divider(height: 0),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.blue.withOpacity(
                                                      0.15,
                                                    )
                                                    : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.location_pin,
                                            size: 15,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Registered In',
                                          style: subtitleTextStyle,
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      listDataUser.namaCabang!.capitalize!,
                                      style: titleTextStyle.copyWith(
                                        fontSize:
                                            listDataUser.namaCabang!.length > 21
                                                ? 11
                                                : 15,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    dense: true,
                                  ),
                                  const Divider(height: 0),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.blue.withOpacity(
                                                      0.15,
                                                    )
                                                    : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_outlined,
                                            size: 15,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Registered At',
                                          style: subtitleTextStyle,
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      listDataUser.createdAt != ""
                                          ? FormatWaktu.formatShortEng(
                                            tanggal: DateTime.parse(
                                              listDataUser.createdAt!,
                                            ),
                                          )
                                          : '-',
                                      style: titleTextStyle,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    dense: true,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// EDIT PROFILE
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              onTap: () {
                                // Get.to(
                                //   () => UpdateProfil(userData: listDataUser!),
                                // );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => UpdateProfil(
                                          userData: listDataUser,
                                        ),
                                  ),
                                );
                              },
                              title: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.blue.withOpacity(0.15)
                                              : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 15,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),

                          const SizedBox(height: 3),

                          /// LOGOUT
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              onTap: () {
                                promptDialog(
                                  context: context,
                                  title: 'LOG OUT',
                                  desc: 'Anda yakin ingin keluar?',
                                  btnOkOnPress: () => auth.logout(),
                                );
                              },
                              title: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.blue.withOpacity(0.15)
                                              : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      size: 15,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          /// TITLE HEADER
          // Positioned(
          //   top: 60,
          //   left: 20,
          //   child: Row(
          //     children: [
          //       const Icon(
          //         CupertinoIcons.person_alt_circle,
          //         size: 25,
          //         color: Colors.white,
          //       ),
          //       const SizedBox(width: 6),
          //       Text(
          //         'Profile',
          //         style: titleTextStyle.copyWith(
          //           fontSize: 18,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
