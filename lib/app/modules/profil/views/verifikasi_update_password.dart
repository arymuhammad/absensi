import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class VerifikasiUpdatePassword extends GetView {
  VerifikasiUpdatePassword({super.key});
  final pegawaiC = Get.put(AddPegawaiController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VERIFIKASI USER'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Masukkan No Telp yang terdaftar untuk validasi user',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
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
                  pegawaiC.cekUser();
                },
               style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minimumSize: Size(Get.size.width / 2, 50)),
                child: const Text(
                  'VALIDASI',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
