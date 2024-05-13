import 'dart:io';

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class BackupView extends GetView {
  BackupView({super.key});

  final ctrl = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BACKUP & RESTORE DB'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/image/bgapp.jpg'),
                // Gantilah dengan path gambar Anda
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Obx(() =>
                !ctrl.backup.value && !ctrl.restore.value ?
                   Icon(
                    Icons.cloud_sync_outlined, size: 125, color: mainColor,)
                  : ctrl.backup.value && !ctrl.restore.value
                    ? Lottie.asset('assets/animation/backup.json')
                    : Lottie.asset('assets/animation/restore.json')

              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_download_rounded),
                        onPressed: () async {
                          ctrl.backup.value = true;
                          final dbFolder = await getDatabasesPath();

                          var status =
                          await Permission.manageExternalStorage.status;
                          if (!status.isGranted) {
                            await Permission.manageExternalStorage.request();
                          }

                          var status1 = await Permission.storage.status;
                          if (!status1.isGranted) {
                            await Permission.storage.request();
                          }

                          try {
                            File source1 = File('$dbFolder/absensi.db');

                            Directory copyTo =
                            Directory('/storage/emulated/0/URBANCO SPOT');
                            await copyTo.create();
                            await source1.copy(
                                '/storage/emulated/0/URBANCO SPOT/absensi.db');
                          } catch (e) {
                            // print(
                            //     "================== error =====${e.toString()}");
                          }
                          await Future.delayed(const Duration(seconds: 3),(){
                            ctrl.backup.value = false;
                          });

                          showToast('Successfully Backup DataBase');
                        },
                        label: const Text('Backup'),
                      ),
                      const Text('Cadangkan data'),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.backup),
                        onPressed: () async {
                          ctrl.restore.value = true;
                          var databasesPath = await getDatabasesPath();
                          // var dbPath = join(databasesPath, 'penjualan.db');

                          var status =
                          await Permission.manageExternalStorage.status;
                          if (!status.isGranted) {
                            await Permission.manageExternalStorage.request();
                          }

                          var status1 = await Permission.storage.status;
                          if (!status1.isGranted) {
                            await Permission.storage.request();
                          }

                          try {
                            File savedDb = File(
                                "/storage/emulated/0/URBANCO SPOT/absensi.db");

                            await savedDb.copy('$databasesPath/absensi.db');
                          } catch (e) {
                            // print(
                            //     "================== error =====${e.toString()}");
                          }
                          await Future.delayed(const Duration(seconds: 3),(){
                            ctrl.restore.value = false;
                          });
                          showToast('Successfully Restored Database');
                        },
                        label: const Text('Restore'),
                      ),
                      const Text('Pulihkan data'),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tools', style: TextStyle(fontWeight: FontWeight.bold),),
                    const Divider(),
                    OutlinedButton.icon(style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(Icons.delete_sweep_rounded, color: red,),
                      onPressed: () async {
                        await SQLHelper.instance.truncateShift();
                        showToast('Data Shift berhasil dihapus');
                      },
                      label: const Text('Hapus data shift',
                        style: TextStyle(color: Colors.black),),
                    ),
                    const SizedBox(height: 5,),
                    OutlinedButton.icon(style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(Icons.delete_sweep_rounded, color: red,),
                      onPressed: () async {
                        await SQLHelper.instance.truncateCabang();
                        showToast('Data Cabang berhasil dihapus');
                      },
                      label: const Text('Hapus data cabang',
                        style: TextStyle(color: Colors.black),),
                    ),
                  ],),
              )
            ],
          ),
        ));
  }
}
