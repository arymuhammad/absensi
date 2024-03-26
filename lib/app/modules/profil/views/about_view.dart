import 'dart:io';

import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AboutView extends GetView {
  AboutView({super.key});
  final absC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tentang',
          style: TextStyle(color: AppColors.mainTextColor1),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/image/bgapp.jpg'), // Gantilah dengan path gambar Anda
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: ListView(children: [
        ListTile(
          title: const Text('Check pembaruan aplikasi'),
          onTap: () {
            if (Platform.isAndroid) {
              absC.checkForUpdates("about");
            } else {
              showToast("Fitur ini hanya untuk Android");
            }
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Versi aplikasi'),
          subtitle: Text(absC.currVer),
        ),
        const Divider(),
      ]),
    );
  }
}
