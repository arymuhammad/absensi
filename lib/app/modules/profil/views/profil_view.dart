import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/controllers/page_index_controller.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/profil/views/update_profil.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              listDataUser![1].toString().toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              '${listDataUser![4]}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
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
              leading: const Icon(Icons.person),
              title: const Text('Update Profile'),
            ),
            ListTile(
              onTap: () {
                Get.to(() => VerifikasiUpdatePassword(), transition: Transition.cupertinoDialog);
              },
              leading: const Icon(Icons.vpn_key),
              title: const Text('Update Password'),
            ),
            ListTile(
              onTap: () {
                Get.toNamed(Routes.ADD_PEGAWAI);
              },
              leading: const Icon(Icons.person_add),
              title: const Text('Add Pegawai'),
            ),
            ListTile(
              onTap: () {
                Get.defaultDialog(
                  barrierDismissible: false,
                  radius: 5,
                  title: 'Peringatan',
                  content: Column(
                    children: [
                      const Text('Anda yakin ingin Logout?'),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                await auth.logout();
                                // loginC.isLoading.value = false;
                                // homeC.selected.value = 0;
                                // Fluttertoast.showToast(
                                //     msg: "Sukses, Anda berhasil Logout.",
                                //     toastLength: Toast.LENGTH_SHORT,
                                //     gravity: ToastGravity.BOTTOM,
                                //     timeInSecForIosWeb: 1,
                                //     backgroundColor: Colors.greenAccent[700],
                                //     textColor: Colors.white,
                                //     fontSize: 16.0);
                                Get.back();
                              },
                              child: const Text('Ya')),
                          ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text('Tidak')),
                        ],
                      ),
                    ],
                  ),
                );
              },
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
            ),
          ],
        ));
  }
}
