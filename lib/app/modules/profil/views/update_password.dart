import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePassword extends GetView {
  UpdatePassword({super.key, this.dataUser});
  final List? dataUser;
  final pegawaiC = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('UPDATE PASSWORD', style: TextStyle(color: AppColors.mainTextColor1),),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text(
              'Ditemukan user yang cocok dengan No Telp ${Get.arguments["no_telp"]}',
              style: const TextStyle(fontSize: 18),
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
                  labelText: 'Ketik password baru',
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
                      Get.arguments["id_user"], Get.arguments["username"], dataUser!);
                  //  Restart.restartApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contentDefBtn,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    minimumSize: Size(Get.size.width / 2, 50)),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(fontSize: 18, color: AppColors.mainTextColor1),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
