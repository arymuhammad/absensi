import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifikasiUpdatePassword extends GetView {
  VerifikasiUpdatePassword({super.key});
  final pegawaiC = Get.put(AddPegawaiController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('VERIFIKASI USER',
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Icon(
                  CupertinoIcons.lock_rotation,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Masukkan No Telp yang terdaftar untuk validasi user',
                  style: TextStyle(fontSize: 15, color: subTitleColor),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pegawaiC.telp,
                  decoration: InputDecoration(
                      labelText: 'No Telp',
                      prefixIcon: const Icon(Icons.phone_android),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton(
                    onPressed: () {
                      pegawaiC.cekUser(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.contentDefBtn,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        minimumSize: Size(Get.size.width / 2, 50)),
                    child: const Text(
                      'VALIDASI',
                      style:
                          TextStyle(fontSize: 18, color: AppColors.mainTextColor1),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
