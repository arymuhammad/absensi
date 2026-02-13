import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/login_model.dart';
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
import '../controllers/profil_controller.dart';
import 'update_profil.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key, this.listDataUser});
  final auth = Get.find<LoginController>();
  final ctr = Get.find<AddPegawaiController>();
  final Data? listDataUser;

  @override
  Widget build(BuildContext context) {
    final imgUrl = '${ServiceApi().baseUrl}${listDataUser!.foto!}';
    return Scaffold(
      body: Stack(
        children: [
          /// HEADER GRADIENT + GLOW
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// GLOW EFFECT
          Positioned(
            top: 80,
            left: -40,
            right: -40,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(.35),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          /// BACKGROUND CARD BESAR
          Positioned(
            top: 180,
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),

          /// CONTENT AREA
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 32, right: 32),
            child: Column(
              children: [
                /// AVATAR FLOATING
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 6),
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
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.black,
                                insetPadding: const EdgeInsets.all(0),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: PhotoView(
                                    imageProvider: NetworkImage(
                                      '${ServiceApi().baseUrl}${listDataUser!.foto!}',
                                    ),
                                    backgroundDecoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.network(
                          listDataUser!.foto != ""
                              ? imgUrl
                              : "https://ui-avatars.com/api/?name=${listDataUser!.nama!}",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                /// NAME
                Text(
                  listDataUser!.nama!,
                  style: titleTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// USER INFO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listDataUser!.id!, style: subtitleTextStyle),
                    Text(' - ', style: subtitleTextStyle),
                    Text(listDataUser!.levelUser!, style: subtitleTextStyle),
                    Visibility(
                      visible: listDataUser!.idRegion! != "",
                      child: Row(
                        children: [
                          Text(' - ', style: subtitleTextStyle),
                          Text(
                            listDataUser!.idRegion!,
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
                      await ctr.getLastUserData(dataUser: listDataUser!);
                      showToast('Page Refreshed');
                    },
                    backgroundColor: Colors.white,
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
                            elevation: 8,
                            shadowColor: Colors.black12,
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
                                          color: Colors.blue[50],
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
                                      const SizedBox(width: 2),
                                      Text(
                                        'Employee ID',
                                        style: subtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    listDataUser!.nik!,
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
                                          color: Colors.blue[50],
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
                                      const SizedBox(width: 2),
                                      Text(
                                        'Phone No.',
                                        style: subtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    listDataUser!.noTelp!,
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
                                          color: Colors.blue[50],
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
                                      const SizedBox(width: 2),
                                      Text(
                                        'Registered In',
                                        style: subtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    listDataUser!.namaCabang!.capitalize!,
                                    style: titleTextStyle.copyWith(
                                      fontSize:
                                          listDataUser!.namaCabang!.length > 21
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
                                          color: Colors.blue[50],
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
                                      const SizedBox(width: 2),
                                      Text(
                                        'Registered At',
                                        style: subtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    listDataUser!.createdAt != ""
                                        ? FormatWaktu.formatShortEng(
                                          tanggal: DateTime.parse(
                                            listDataUser!.createdAt!,
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
                                const Divider(height: 0),
                                ListTile(
                                  title: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
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
                                      const SizedBox(width: 2),
                                      Text(
                                        'Username',
                                        style: subtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    listDataUser!.username!,
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
                              Get.to(
                                () => UpdateProfil(userData: listDataUser!),
                              );
                            },
                            title: const Text(
                              'Edit Profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                            title: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
          ),

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
