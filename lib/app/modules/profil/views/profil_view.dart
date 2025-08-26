import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/shared/elevated_button.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../add_pegawai/controllers/add_pegawai_controller.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key, this.listDataUser});
  final auth = Get.find<LoginController>();
  final ctr = Get.find<AddPegawaiController>();
  final Data? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // const CsBgImg(),
          Container(
            height: 180,
            decoration: const BoxDecoration(color: AppColors.itemsBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 115, left: 8.0, right: 8.0),
            child: Column(
              children: [
                Container(
                  height:
                      130, // sedikit lebih besar dari ukuran ClipOval supaya border terlihat
                  width: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ), // border putih tebal 4
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      height: 120,
                      width: 120,
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
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 3,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.network(
                          '${ServiceApi().baseUrl}${listDataUser!.foto!}',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Image.network(
                                "https://ui-avatars.com/api/?name=${listDataUser!.nama}",
                                fit: BoxFit.cover,
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  listDataUser!.nama!,
                  style: titleTextStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listDataUser!.id!, style: subtitleTextStyle),
                    Text(' - ', style: subtitleTextStyle),
                    Text(listDataUser!.levelUser!, style: subtitleTextStyle),
                    Visibility(
                      visible: listDataUser!.idRegion! != "" ? true : false,
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
                const SizedBox(height: 10),
                Expanded(
                  child: CustomMaterialIndicator(
                    onRefresh: () async {
                      await ctr.getLastUserData(dataUser: listDataUser!);
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
                        SizedBox(
                          height: 250,
                          child: Card(
                            color: AppColors.contentColorWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                ListTile(
                                  title: Text(
                                    'Employee ID',
                                    style: subtitleTextStyle,
                                  ),
                                  trailing:
                                      listDataUser!.nik!.isEmpty
                                          ? CsElevatedButton(
                                            color: AppColors.itemsBackground,
                                            fontsize: 12,
                                            label: 'Generate ID',
                                            onPressed:
                                                listDataUser!.createdAt! == ""
                                                    ? null
                                                    : () {
                                                      ctr.generateEmpId(
                                                        listDataUser!,
                                                      );
                                                    },
                                          )
                                          : Text(
                                            listDataUser!.nik!,
                                            style: titleTextStyle,
                                          ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  dense: true,
                                ),
                                const Divider(
                                  indent: 15,
                                  endIndent: 15,
                                  height: 0,
                                ),
                                ListTile(
                                  title: Text(
                                    'Phone No.',
                                    style: subtitleTextStyle,
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
                                const Divider(
                                  indent: 15,
                                  endIndent: 15,
                                  height: 0,
                                ),
                                ListTile(
                                  title: Text(
                                    'Registered In',
                                    style: subtitleTextStyle,
                                  ),
                                  trailing: Text(
                                    listDataUser!.namaCabang!.capitalize!,
                                    style: titleTextStyle,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  dense: true,
                                ),
                                const Divider(
                                  indent: 15,
                                  endIndent: 15,
                                  height: 0,
                                ),
                                ListTile(
                                  title: Text(
                                    'Registered At',
                                    style: subtitleTextStyle,
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
                                const Divider(
                                  indent: 15,
                                  endIndent: 15,
                                  height: 0,
                                ),
                                ListTile(
                                  title: Text(
                                    'Username',
                                    style: subtitleTextStyle,
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
                                const Divider(
                                  indent: 15,
                                  endIndent: 15,
                                  height: 0,
                                ),
                                ListTile(
                                  title: Text(
                                    'Password',
                                    style: subtitleTextStyle,
                                  ),
                                  trailing: Text(
                                    '********',
                                    style: titleTextStyle,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  dense: true,
                                ),
                                const Divider(
                                  indent: 15,
                                  endIndent: 15,
                                  height: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
                            leading: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: bgContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.power_settings_new_sharp,
                                color: Colors.redAccent[700],
                              ),
                            ),
                            title: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.redAccent[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // subtitle: Text(
                            //   'exit app',
                            //   style: TextStyle(
                            //     color: subTitleColor,
                            //     fontSize: 13,
                            //   ),
                            // ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: subTitleColor,
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

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 25,
                      color: AppColors.contentColorWhite,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Profile',
                      style: titleTextStyle.copyWith(
                        fontSize: 18,
                        color: AppColors.contentColorWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
