import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class UpdatePassword extends GetView {
  UpdatePassword({super.key});
  final pegawaiC = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Masukkan Password yang mudah Anda ingat',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              controller: pegawaiC.pass,
              decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pegawaiC.updatePassword(Get.arguments["id_user"], Get.arguments["username"]);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(Get.mediaQuery.size.width, 50)),
              child: const Text(
                'SIMPAN',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
