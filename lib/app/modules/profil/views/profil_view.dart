import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:absensi/app/modules/shared/rounded_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../../../services/service_api.dart';
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
        const CsBgImgHeader(height: 380),
        Padding(
          padding: const EdgeInsets.only(top: 190, left: 15.0, right: 15.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
              height: 389,
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
                      style:
                          TextStyle(fontSize: 15, color: subTitleColor),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(FontAwesome.id_badge, color: mainColor),
                                const SizedBox(width: 5),
                                const Text('ID'),
                              ],
                            ),
                            Text(
                              '${listDataUser!.id}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: subTitleColor),
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
                                Icon(TernavIcons.bold.profile,
                                    color: mainColor),
                                const SizedBox(width: 5),
                                const Text('Username'),
                              ],
                            ),
                            Text(
                              '${listDataUser!.username}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: subTitleColor),
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
                                Icon(TernavIcons.bold.call, color: mainColor),
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
                                Icon(FontAwesome.store_solid, color: mainColor),
                                const SizedBox(width: 5),
                                const Text('Store'),
                              ],
                            ),
                            Text(
                              '${listDataUser!.namaCabang}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: subTitleColor),
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 110, horizontal: MediaQuery.of(context).size.width / 3.8),
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
              child: FullScreenWidget(
                child: Hero(
                    tag: 'customTag',
                    child: RoundedImage(
                        height: 180,
                        width: 180,
                        foto: user.fotoProfil.value != ""
                            ? user.fotoProfil.value
                            : listDataUser!.foto!,
                        name: listDataUser!.nama!)
                    // ClipRect(
                    //   child: listDataUser!.foto != ""
                    //       ? Obx(
                    //           () => CachedNetworkImage(
                    //             imageUrl:
                    //                 "${ServiceApi().baseUrl}${user.fotoProfil.value != "" ? user.fotoProfil.value : listDataUser!.foto}",
                    //             fit: BoxFit.cover,
                    //             progressIndicatorBuilder:
                    //                 (context, url, progress) =>
                    //                     CircularProgressIndicator(
                    //               value: progress.progress,
                    //               strokeWidth: 15,
                    //             ),
                    //             errorWidget: (context, url, error) {
                    //               return Image.network(
                    //                   "${ServiceApi().baseUrl}${user.fotoProfil.value}");
                    //             },
                    //           ),
                    //         )
                    //       // PhotoView(
                    //       //       backgroundDecoration: BoxDecoration(
                    //       //           color: Colors.grey[200]),
                    //       //       imageProvider: NetworkImage(
                    //       //           "${ServiceApi().baseUrl}${userFoto.fotoProfil.value !="" ? userFoto.fotoProfil.value : listDataUser![5]}"),

                    //       //     ),
                    //       // )
                    //       : Image.network(
                    //           "https://ui-avatars.com/api/?name=${listDataUser!.nama}",
                    //           fit: BoxFit.cover,
                    //         ),
                    // ),
                    ),
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
                    CupertinoIcons.person_alt_circle,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Profile',
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
