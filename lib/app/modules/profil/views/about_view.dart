import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AboutView extends GetView {
  AboutView({Key? key}) : super(key: key);
  final ctr = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang'),
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
            ctr.checkForUpdate("");
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Versi aplikasi'),
          subtitle: Text(ctr.currVer),
        ),
        const Divider(),
      ]),
    );
  }
}
