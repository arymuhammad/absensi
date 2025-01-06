import 'dart:io';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../../../services/service_api.dart';

class BackupView extends GetView {
  BackupView({super.key, this.userData});
  final Data? userData;
  final ctrl = Get.put(AddPegawaiController());
  final auth = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BACKUP & RESTORE DB'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/new_bg_app.jpg'),
                // Gantilah dengan path gambar Anda
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Obx(() => !ctrl.backup.value && !ctrl.restore.value
                  ? Icon(
                      Icons.cloud_sync_outlined,
                      size: 125,
                      color: mainColor,
                    )
                  : ctrl.backup.value && !ctrl.restore.value
                      ? SizedBox(
                          height: 150,
                          width: 150,
                          child: Lottie.asset('assets/animation/backup.json'))
                      : SizedBox(
                          height: 150,
                          width: 150,
                          child:
                              Lottie.asset('assets/animation/restore.json'))),
              const SizedBox(
                height: 20,
              ),
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
                          await Future.delayed(const Duration(seconds: 3), () {
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
                          await Future.delayed(const Duration(seconds: 3), () {
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
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build_circle_rounded),
                        Text(
                          'Tools',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ],
                    ),
                    const Divider(),
                    OutlinedButton.icon(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(
                        Icons.camera_front,
                        color: mainColor,
                      ),
                      onPressed: () async {
                        if (userData!.visit == '0') {
                          var tempDataAbs =
                              await SQLHelper.instance.getAllDataAbsen();
                          for (var i in tempDataAbs) {
                            var data = {
                              "tanggal_masuk": i.tanggalMasuk,
                              "tanggal_pulang": i.tanggalPulang,
                              "id": i.idUser,
                              "kode_cabang": i.kodeCabang,
                              "nama": i.nama,
                              "id_shift": i.idShift,
                              "jam_masuk": i.jamMasuk,
                              "jam_pulang": i.jamPulang,
                              "jam_absen_masuk": i.jamAbsenMasuk,
                              "jam_absen_pulang": i.jamAbsenPulang,
                              "foto_masuk": File(i.fotoMasuk.toString()),
                              "foto_pulang": File(i.fotoPulang!),
                              "lat_masuk": i.latMasuk,
                              "long_masuk": i.longMasuk,
                              "lat_pulang": i.latPulang,
                              "long_pulang": i.longPulang,
                              "device_info": i.devInfo,
                              "device_info2": i.devInfo2
                            };
                            await ServiceApi().reSubmitAbsen(data);
                          }
                        } else {
                          var tempDataVisit =
                              await SQLHelper.instance.getAllDataVisit();

                          for (var i in tempDataVisit) {
                            var data = {
                              "id": i.id!,
                              "nama": i.nama!,
                              "tgl_visit": i.tglVisit!,
                              "visit_in": i.visitIn!,
                              "jam_in": i.jamIn!,
                              "visit_out": i.visitOut,
                              "jam_out": i.jamOut,
                              "foto_in": File(i.fotoIn!.toString()),
                              "lat_in": i.latIn!,
                              "long_in": i.longIn!,
                              "foto_out": File(i.fotoOut.toString()),
                              "lat_out": i.latOut,
                              "long_out": i.longOut,
                              "device_info": i.deviceInfo!,
                              "device_info2": i.deviceInfo2,
                              "is_rnd": i.isRnd!
                            };
                            await ServiceApi().reSubmitVisit(data);
                          }
                        }
                        showToast(userData!.visit == '0'
                            ? 'Data absen berhasil dikirim ulang'
                            : 'Data visit berhasil dikirim ulang');
                      },
                      label: Text(
                        userData!.visit == '0'
                            ? 'Kirim ulang data absensi'
                            : 'Kirim ulang data visit',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    OutlinedButton.icon(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(
                        Icons.people,
                        color: red,
                      ),
                      onPressed: () async {
                        if (userData!.visit == '0') {
                          // cek data absen
                          loadingDialog("menghapus data...", "");
                          var tempDataAbs = await SQLHelper.instance
                              .getAbsenToday(
                                  userData!.id!,
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()));
                          if (tempDataAbs.isNotEmpty &&
                              tempDataAbs.first.tanggalMasuk != null &&
                              tempDataAbs.first.tanggalPulang == null) {
                            SQLHelper.instance.deleteDataAbsenMasuk(
                                tempDataAbs.first.idUser!,
                                tempDataAbs.first.tanggalMasuk!);

                            var dataLive = {
                              "type": "absen",
                              "status": "masuk",
                              "id": userData!.id!,
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                            };

                            await ServiceApi().deleteAbsVst(dataLive);
                          } else {
                            var dataLocal = {
                              "tanggal_pulang": null,
                              "jam_absen_pulang": "",
                              "foto_pulang": "",
                              "lat_pulang": "",
                              "long_pulang": "",
                              "device_info2": ""
                            };
                            SQLHelper.instance.deleteDataAbsenPulang(
                                dataLocal,
                                userData!.id!,
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()));

                            var dataLive = {
                              "type": "absen",
                              "status": "pulang",
                              "id": userData!.id!,
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                            };
                            // log(dataLive.toString());
                            await ServiceApi().deleteAbsVst(dataLive);
                          }
                        } else {
                          // cek data visit
                          loadingDialog("menghapus data...", "");
                          var tempDataVisit = await SQLHelper.instance
                              .getVisitToday(
                                  userData!.id!,
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                  "",
                                  0);

                          if (tempDataVisit.isNotEmpty &&
                              tempDataVisit.first.tglVisit != null &&
                              tempDataVisit.first.visitIn != "" &&
                              tempDataVisit.first.jamIn != "" &&
                              tempDataVisit.first.visitOut == "" &&
                              tempDataVisit.first.jamOut == "") {
                            SQLHelper.instance.deleteDataVisitMasuk(
                                tempDataVisit.first.id!,
                                tempDataVisit.first.tglVisit!,
                                tempDataVisit.first.visitIn!);

                            var dataLive = {
                              "type": "visit",
                              "status": "masuk",
                              "id": userData!.id!,
                              "tgl_visit": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                              "visit_in": tempDataVisit.first.visitIn!
                            };
                            await ServiceApi().deleteAbsVst(dataLive);
                          } else {
                            var data = {
                              "visit_out": "",
                              "jam_out": "",
                              "foto_out": "",
                              "lat_out": "",
                              "long_out": "",
                              "device_info2": ""
                            };
                            SQLHelper.instance.deleteDataVisitPulang(
                                data,
                                userData!.id!,
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()));

                            var dataLive = {
                              "type": "visit",
                              "status": "pulang",
                              "id": userData!.id!,
                              "tgl_visit": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                              "visit_in": tempDataVisit.first.visitIn ?? ""
                            };
                            // log(dataLive.toString());
                            await ServiceApi().deleteAbsVst(dataLive);
                          }
                        }
                      },
                      label: Text(
                        'Hapus data ${userData!.visit == '0' ? 'absen' : 'visit'} masuk / pulang',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    OutlinedButton.icon(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: red,
                      ),
                      onPressed: () async {
                        await SQLHelper.instance.truncateShift();
                        showToast('Data Shift berhasil dihapus');
                      },
                      label: const Text(
                        'Hapus data shift',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    OutlinedButton.icon(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: red,
                      ),
                      onPressed: () async {
                        await SQLHelper.instance.truncateCabang();
                        showToast('Data Cabang berhasil dihapus');
                      },
                      label: const Text(
                        'Hapus data cabang',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    OutlinedButton.icon(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: red,
                      ),
                      onPressed: () async {
                        await SQLHelper.instance.truncateCabang();
                        await SQLHelper.instance.truncateShift();
                        await SQLHelper.instance.truncateUser();
                        await SQLHelper.instance.truncateAbsen();
                        await SQLHelper.instance.truncateVisit();
                        await SQLHelper.instance.truncateLevel();
                        await SQLHelper.instance.truncateServer();
                        await dialogMsg('Hapus Data',
                            'Semua data berhasil dihapus\nSilahkan Login ulang');
                        Future.delayed(const Duration(seconds: 1), () {
                          auth.logout();
                          Get.back(closeOverlays: true);
                        });
                        showToast('Data berhasil dihapus');
                      },
                      label: const Text(
                        'Hapus Semua Data',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
