import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/home/views/summary_absen.dart';
import 'package:absensi/app/modules/home/views/summary_absen_area.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:absensi/app/modules/shared/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key, this.listDataUser});
  final Data? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
         const CsBgImg(),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 60.0, right: 15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listDataUser!.nama!.substring(
                                  0,
                                  listDataUser!.nama!.length > 18
                                      ? 18
                                      : listDataUser!.nama!.length) +
                              (listDataUser!.nama!.length > 18 ? '...' : '')
                                  .toString()
                                  .capitalize!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                          style: titleTextStyle.copyWith(fontSize: 22),
                        ),
                        Text(
                          listDataUser!.levelUser!,
                          style: subtitleTextStyle.copyWith(fontSize: 15)
                        ),
                        Text(
                          listDataUser!.namaCabang!,  overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                          style: subtitleTextStyle.copyWith(fontSize: 12)
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => ProfilView(listDataUser: listDataUser!));
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: const BorderSide(
                                width: 3, color: Colors.white)),
                        child: RoundedImage(
                          height: 80,
                          width: 80,
                          foto: listDataUser!.foto!,
                          name: listDataUser!.nama!,
                          headerProfile: true,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    // IconButton(
                    //     onPressed: () {
                    //       promptDialog(context, 'Anda yakin ingin keluar?');
                    //     },
                    //     icon: const Icon(
                    //       Icons.logout_rounded,
                    //       color: Colors.white,
                    //       size: 35,
                    //     ))
                  ],
                ),
                const SizedBox(height: 20),
                listDataUser!.visit == "1"
                    ? SummaryAbsenArea(userData: listDataUser!)
                    : SummaryAbsen(userData: listDataUser!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
