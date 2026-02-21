import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/input_decoration.dart';

class VerifikasiUpdatePassword extends GetView {
  VerifikasiUpdatePassword({super.key});
  final pegawaiC = Get.put(AddPegawaiController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'USER VERIFICATION',
          style: titleTextStyle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        // centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Icon(
                  CupertinoIcons.lock_rotation,
                  color: AppColors.contentColorWhite,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter the registered telephone number for user validation.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.contentColorWhite,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pegawaiC.telp,
                  decoration: inputDecoration(
                    label: 'No Telp',
                    prefixIcon: Icons.phone_android,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        pegawaiC.cekUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: Size(Get.size.width / 2, 50),
                      ),
                      child: const Text(
                        'VALIDATION',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.contentColorWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
