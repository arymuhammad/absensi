import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/profil/views/update_profil.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../../Repo/service_api.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key, this.listDataUser});
  final auth = Get.put(LoginController());

  final List? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PROFILE'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: FullScreenWidget(
                    child: Hero(
                      tag: 'customTag',
                      child: ClipRect(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: listDataUser![5] != ""
                              ? PhotoView(
                                  backgroundDecoration:
                                      BoxDecoration(color: Colors.grey[200]),
                                  imageProvider: NetworkImage(
                                      "${ServiceApi().baseUrl}${listDataUser![5]}"),
                                )
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
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
            ),
            Text(
              '${listDataUser![4]}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subTitleColor),
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
                      color: mainColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${listDataUser![10]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: subTitleColor),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 1,
                  color: mainColor,
                ),
                const SizedBox(width: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      TernavIcons.bold.call,
                      color: mainColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${listDataUser![3]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: subTitleColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
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
        ));
  }
}
