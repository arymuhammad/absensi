import 'package:absensi/app/helper/loading_dialog.dart';
import 'package:absensi/app/modules/home/views/card_info_menu.dart';
import 'package:absensi/app/modules/home/views/summary_absen.dart';
import 'package:absensi/app/modules/profil/views/profil_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../services/service_api.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key, this.listDataUser});
  final List? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, elevation: 0, toolbarHeight: 0),
      body: Stack(
        children: [
          ClipPath(
            clipper: ClipPathClass(),
            child: Container(
              height: 250,
              width: Get.size.width,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/image/bgapp.jpg'),
                      fit: BoxFit.fill)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // loginC.selectedMenu(2);
                            Get.to(
                                () => ProfilView(listDataUser: listDataUser!));
                          },
                          child: ClipOval(
                            child: Hero(
                              tag: 'pro',
                              transitionOnUserGestures: true,
                              child: Container(
                                height: 75,
                                width: 75,
                                color: Colors.grey[200],
                                child: listDataUser![5] != ""
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            "${ServiceApi().baseUrl}${listDataUser![5]}",
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                CircularProgressIndicator(
                                          value: progress.progress,
                                          strokeWidth: 15,
                                        ),
                                        cacheKey:
                                            "${ServiceApi().baseUrl}${listDataUser![5]} + ${DateTime.now().day.toString()}",
                                      )
                                    : Image.network(
                                        "https://ui-avatars.com/api/?name=${listDataUser![1]}",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              listDataUser![1].toString().capitalize!,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                            // Obx(() => Text(
                            //       absenC.devInfoAnd.value.isNotEmpty
                            //           ? absenC.devInfoAnd.value
                            //           : 'Belum ada info andr',
                            //       style: const TextStyle(color: Colors.white),
                            //     ))
                          ],
                        )
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          promptDialog(context, 'Anda yakin ingin keluar?');
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 35,
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        CardInfoMenu(userData: listDataUser!),
                        const SizedBox(height: 10),
                        SummaryAbsen(userData: listDataUser!)
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
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
