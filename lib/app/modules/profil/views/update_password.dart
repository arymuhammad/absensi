import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helper/const.dart';

class UpdatePassword extends GetView {
  UpdatePassword({super.key});
  final pegawaiC = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Update Password',
            style: titleTextStyle.copyWith(
              fontSize: 18,
            )),
        backgroundColor: Colors.transparent.withOpacity(0.4),
        // elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        // centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // const CsBgImg(),
          Container(height: 250, decoration: const BoxDecoration(color: AppColors.itemsBackground)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Found a user that matches the phone number ${Get.arguments["no_telp"]}',
                  style: const TextStyle(fontSize: 18, color: AppColors.contentColorWhite),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(color: Colors.grey),
                        child: Get.arguments["foto"] == ""
                            ? Image.network(
                                "https://ui-avatars.com/api/?name=${Get.arguments["nama"]}",
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                "${ServiceApi().baseUrl}${Get.arguments["foto"]}"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Username : ${Get.arguments["username"]}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: pegawaiC.pass,
                  decoration: InputDecoration(
                      labelText: 'Type new password',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: ElevatedButton(
                    onPressed: () async {
                      await pegawaiC.updatePassword(context,
                          Get.arguments["id_user"], Get.arguments["username"]);
                      //  Restart.restartApp();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.itemsBackground,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        minimumSize: Size(Get.size.width / 2, 50)),
                    child: const Text(
                      'UPDATE',
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
