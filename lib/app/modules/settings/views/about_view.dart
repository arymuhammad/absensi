import 'dart:io';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/helper/const.dart';

class AboutView extends GetView {
  AboutView({super.key});
  final absC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Tentang',
            style: titleTextStyle.copyWith(
              fontSize: 20,
            )),
        backgroundColor: Colors.transparent.withOpacity(0.4),
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const CsBgImg(),
          ListView(children: [
            ListTile(
              leading: const Icon(Icons.cloud_download_rounded),
              title: const Text('Cek pembaruan aplikasi'),
              onTap: () {
                if (Platform.isAndroid) {
                  absC.checkForUpdates("about");
                  // launchUrl(
                  //     Uri.parse('http://103.156.15.61/update apk/absensiApp.apk'));
                } else {
                  launchUrl(Uri.parse(
                      'https://apps.apple.com/us/app/urbanco-spot/id6476486235'));
                  // showToast("Fitur ini hanya untuk Android");
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Versi aplikasi'),
              subtitle: Text(
                'v${absC.currVer}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
          ]),
        ],
      ),
    );
  }
}
