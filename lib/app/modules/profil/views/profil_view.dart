import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/profil/views/about_view.dart';
import 'package:absensi/app/modules/profil/views/update_profil.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../../Repo/service_api.dart';
import '../../add_pegawai/controllers/add_pegawai_controller.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key, this.listDataUser});
  final auth = Get.put(LoginController());
  final user = Get.put(AddPegawaiController());
  final List? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('PROFILE'),
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 0),
        body: Stack(
          children: [
            ClipPath(
              clipper: ClipPathClass(),
              child: Container(
                height: 320,
                width: Get.width,
                color: mainColor,
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: FullScreenWidget(
                        child: Hero(
                          tag: 'customTag',
                          child: ClipRect(
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: listDataUser![5] != ""
                                  ? Obx(
                                      () => CachedNetworkImage(
                                        imageUrl:
                                            "${ServiceApi().baseUrl}${user.fotoProfil.value != "" ? user.fotoProfil.value : listDataUser![5]}",
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                CircularProgressIndicator(
                                          value: progress.progress,
                                          strokeWidth: 15,
                                        ),
                                        errorWidget: (context, url, error) {
                                          return Image.network(
                                              "${ServiceApi().baseUrl}${user.fotoProfil.value}");
                                        },
                                      ),
                                    )
                                  // PhotoView(
                                  //       backgroundDecoration: BoxDecoration(
                                  //           color: Colors.grey[200]),
                                  //       imageProvider: NetworkImage(
                                  //           "${ServiceApi().baseUrl}${userFoto.fotoProfil.value !="" ? userFoto.fotoProfil.value : listDataUser![5]}"),

                                  //     ),
                                  // )
                                  : Image.network(
                                      "https://ui-avatars.com/api/?name=${listDataUser![1]}",
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  listDataUser![1].toString().capitalize!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  '${listDataUser![4]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          TernavIcons.bold.profile,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${listDataUser![10]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 20,
                      width: 1,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          TernavIcons.bold.call,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Obx(
                          () => Text(
                            '${user.newPhone.isNotEmpty ? user.newPhone.value : listDataUser![3]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ListTile(
                  onTap: () {
                    Get.to(
                        () => UpdateProfil(
                              userData: listDataUser!,
                            ),
                        transition: Transition.cupertino);
                  },
                  leading: Icon(
                    TernavIcons.bold.profile,
                    color: mainColor,
                  ),
                  title: const Text('Update Profile'),
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => VerifikasiUpdatePassword(),
                        transition: Transition.cupertino);
                  },
                  leading: Icon(
                    TernavIcons.bold.key,
                    color: mainColor,
                  ),
                  title: const Text('Update Password'),
                ),
                Visibility(
                  visible: listDataUser![9] == "1" ? true : false,
                  child: ListTile(
                    onTap: () {
                      Get.toNamed(Routes.ADD_PEGAWAI);
                    },
                    leading: Icon(
                      TernavIcons.bold.add_user,
                      color: mainColor,
                    ),
                    title: const Text('Add Pegawai'),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => AboutView());
                  },
                  leading: Icon(
                    TernavIcons.lightOutline.info,
                    color: mainColor,
                  ),
                  title: const Text('Tentang'),
                ),
                ListTile(
                  onTap: () {
                    Get.defaultDialog(
                      barrierDismissible: false,
                      radius: 5,
                      title: 'Peringatan',
                      middleText: 'Anda yakin ingin keluar?',
                      onConfirm: () {
                        auth.logout();
                        Get.back();
                      },
                      textConfirm: 'Keluar',
                      confirmTextColor: Colors.white,
                      onCancel: () {
                        Get.back();
                      },
                      textCancel: 'Batal',
                    );
                  },
                  leading: Icon(
                    TernavIcons.lightOutline.logout,
                    color: mainColor,
                  ),
                  title: const Text('Logout'),
                ),
              ],
            ),
          ],
        ));
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 60);

    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 60);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
