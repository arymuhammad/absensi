import 'dart:convert';

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

class FaceDataView extends GetView {
  FaceDataView({super.key, this.idUser});
  final String? idUser;
  final ctrl = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Face Data',
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
          Obx(() => ctrl.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                        child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[200],
                      child: ctrl.faceDatas.value.dataWajah != ""
                          ? Image.memory(
                              base64Decode(ctrl.faceDatas.value.dataWajah!))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/image/selfie.png',
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text('Belum ada data wajah')
                              ],
                            ),
                    )),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible:
                          ctrl.faceDatas.value.dataWajah != "" ? true : false,
                      child: Text(
                        ctrl.faceDatas.value.nama!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ctrl.addFaceData(idUser!);
          ctrl.getFaceData(idUser!);
        },
        label: const Row(
          children: [
            Icon(Icons.add_a_photo),
            SizedBox(
              width: 5,
            ),
            Text('Tambah data wajah')
          ],
        ),
      ),
    );
  }
}
