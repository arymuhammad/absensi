import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../add_pegawai/controllers/add_pegawai_controller.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key, this.listDataUser});
  final auth = Get.put(LoginController());
  final user = Get.put(AddPegawaiController());
  final Data? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const CsBgImg(),
        Padding(
          padding: const EdgeInsets.only(top: 190, left: 15.0, right: 15.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
              height: 415,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  SizedBox(
                    width: 180,
                    child: Text(
                      listDataUser!.nama.toString().capitalize!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    // width: 150,
                    child: Text(
                      '${listDataUser!.levelUser}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: subTitleColor),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: SizedBox(
                      height: 140,
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesome.id_badge,
                                        color: mainColor),
                                    const SizedBox(width: 5),
                                    const Text('ID'),
                                  ],
                                ),
                                Text(
                                  '${listDataUser!.id}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15, color: subTitleColor),
                                ),
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            // const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Iconsax.profile_circle_bold,
                                        color: mainColor),
                                    const SizedBox(width: 5),
                                    const Text('Username'),
                                  ],
                                ),
                                Text(
                                  '${listDataUser!.username}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15, color: subTitleColor),
                                ),
                              ],
                            ),

                            const Divider(
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Iconsax.call_bold, color: mainColor),
                                    const SizedBox(width: 5),
                                    const Text('Telp'),
                                  ],
                                ),
                                Obx(
                                  () => Text(
                                    '${user.newPhone.isNotEmpty ? user.newPhone.value : listDataUser!.noTelp}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15, color: subTitleColor),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 10),
                            const Divider(
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesome.store_solid,
                                        color: mainColor),
                                    const SizedBox(width: 5),
                                    const Text('Store'),
                                  ],
                                ),
                                Text(
                                  '${listDataUser!.namaCabang}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15, color: subTitleColor),
                                ),
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 110,
              horizontal: MediaQuery.of(context).size.width / 3.8),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(100)),
            height: 180,
            width: 180,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(width: 2, color: subTitleColor!)),
              child: ClipOval(
                child: WidgetZoom(
                    heroAnimationTag: 'customTag',
                    zoomWidget: Image.network(
                        '${ServiceApi().baseUrl}${listDataUser!.foto!}',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Image.network(
                            "https://ui-avatars.com/api/?name=${listDataUser!.nama}",
                            fit: BoxFit.fill),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                              child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ));
                        })),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 25,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Profile',
                      style: titleTextStyle.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      promptDialog(context, 'Anda yakin ingin keluar?');
                    },
                    icon: const Icon(
                      Iconsax.logout_1_outline,
                      color: Colors.black,
                      size:30,
                    ))
              ],
            ))
      ],
    ));
  }
}
