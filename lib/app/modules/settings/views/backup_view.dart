import 'dart:io';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
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
  BackupView({super.key});
  final ctrl = Get.put(AddPegawaiController());
  final auth = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final userData = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'BACKUP & RESTORE DB',
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
          // const CsBgImg(),
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient(
                context: context,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Obx(
                    () =>
                        !ctrl.backup.value && !ctrl.restore.value
                            ? const Icon(
                              Icons.cloud_sync_outlined,
                              size: 125,
                              color: AppColors.contentColorWhite,
                            )
                            : ctrl.backup.value && !ctrl.restore.value
                            ? SizedBox(
                              height: 125,
                              width: 125,
                              child: Lottie.asset(
                                'assets/animation/backup.json',
                              ),
                            )
                            : SizedBox(
                              height: 125,
                              width: 125,
                              child: Lottie.asset(
                                'assets/animation/backup.json',
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_download_rounded),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.itemsBackground,
                            ),
                            onPressed: () async {
                              ctrl.backup.value = true;
                              final dbFolder = await getDatabasesPath();

                              var status =
                                  await Permission.manageExternalStorage.status;
                              if (!status.isGranted) {
                                await Permission.manageExternalStorage
                                    .request();
                              }

                              var status1 = await Permission.storage.status;
                              if (!status1.isGranted) {
                                await Permission.storage.request();
                              }

                              try {
                                File source1 = File('$dbFolder/absensi.db');

                                Directory copyTo = Directory(
                                  '/storage/emulated/0/URBANCO SPOT',
                                );
                                await copyTo.create();
                                await source1.copy(
                                  '/storage/emulated/0/URBANCO SPOT/absensi.db',
                                );
                              } catch (e) {
                                // print(
                                //     "================== error =====${e.toString()}");
                              }
                              await Future.delayed(
                                const Duration(seconds: 3),
                                () {
                                  ctrl.backup.value = false;
                                },
                              );

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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.itemsBackground,
                            ),

                            onPressed: () async {
                              ctrl.restore.value = true;
                              var databasesPath = await getDatabasesPath();
                              // var dbPath = join(databasesPath, 'penjualan.db');

                              var status =
                                  await Permission.manageExternalStorage.status;
                              if (!status.isGranted) {
                                await Permission.manageExternalStorage
                                    .request();
                              }

                              var status1 = await Permission.storage.status;
                              if (!status1.isGranted) {
                                await Permission.storage.request();
                              }

                              try {
                                File savedDb = File(
                                  "/storage/emulated/0/URBANCO SPOT/absensi.db",
                                );

                                await savedDb.copy('$databasesPath/absensi.db');
                              } catch (e) {
                                // print(
                                //     "================== error =====${e.toString()}");
                              }
                              await Future.delayed(
                                const Duration(seconds: 3),
                                () {
                                  ctrl.restore.value = false;
                                },
                              );
                              showToast('Successfully Restored Database');
                            },
                            label: const Text('Restore'),
                          ),
                          const Text('Pulihkan data'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        OutlinedButton.icon(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.camera_front, color: mainColor),
                          onPressed: () async {
                            if (userData.visit == '0') {
                              var tempDataAbs = await SQLHelper.instance
                                  .getAllDataAbsen(
                                    userData.id!,
                                    ctrl.initDate1,
                                    ctrl.initDate2,
                                  );
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
                                  "device_info2": i.devInfo2,
                                };
                                await ServiceApi().reSubmitAbsen(data);
                              }
                            } else {
                              var tempDataVisit = await SQLHelper.instance
                                  .getAllDataVisit(
                                    userData.id!,
                                    ctrl.initDate1,
                                    ctrl.initDate2,
                                  );

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
                                  "is_rnd": i.isRnd!,
                                };
                                await ServiceApi().reSubmitVisit(data);
                              }
                            }
                            showToast(
                              userData.visit == '0'
                                  ? 'Data absen berhasil dikirim ulang'
                                  : 'Data visit berhasil dikirim ulang',
                            );
                          },
                          label: Text(
                            userData.visit == '0'
                                ? 'Kirim ulang data absensi'
                                : 'Kirim ulang data visit',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        OutlinedButton.icon(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.people, color: red),
                          onPressed: () async {
                            if (userData.visit == '0') {
                              // cek data absen
                              loadingDialog("menghapus data...", "");
                              var tempDataAbs = await SQLHelper.instance
                                  .getAbsenToday(
                                    userData.id!,
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(DateTime.now()),
                                  );
                              final today = DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now());
                              final hasCheckInOnly =
                                  tempDataAbs.isNotEmpty &&
                                  tempDataAbs.first.tanggalMasuk != null &&
                                  tempDataAbs.first.tanggalPulang == null;

                              if (hasCheckInOnly) {
                                // ===============================
                                // 🧹 DELETE CHECK IN (MASUK)
                                // ===============================
                                final firstData = tempDataAbs.first;

                                await SQLHelper.instance.deleteDataAbsenMasuk(
                                  firstData.idUser!,
                                  firstData.tanggalMasuk!,
                                );

                                final dataLive = {
                                  "type": "absen",
                                  "status": "masuk",
                                  "id": userData.id!,
                                  "tanggal_masuk": today,
                                };

                                await ServiceApi().deleteAbsVst(dataLive);
                              } else {
                                // ===============================
                                // 🧹 DELETE CHECK OUT (PULANG)
                                // ===============================
                                final dataLocal = {
                                  "tanggal_pulang": null,
                                  "jam_absen_pulang": "",
                                  "foto_pulang": "",
                                  "lat_pulang": "",
                                  "long_pulang": "",
                                  "device_info2": "",
                                };

                                await SQLHelper.instance.deleteDataAbsenPulang(
                                  dataLocal,
                                  userData.id!,
                                  today,
                                );

                                final dataLive = {
                                  "type": "absen",
                                  "status": "pulang",
                                  "id": userData.id!,
                                  "tanggal_masuk": today,
                                };

                                await ServiceApi().deleteAbsVst(dataLive);
                              }
                            } else {
                              final today = DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now());
                              //cek data visit
                              var tempDataVisit = await SQLHelper.instance
                                  .getVisitToday(
                                    userData.id!,
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(DateTime.now()),
                                    "",
                                    0,
                                  );
                              final hasData = tempDataVisit.isNotEmpty;
                              final firstVisit =
                                  hasData ? tempDataVisit.first : null;

                              final isCheckInOnly =
                                  hasData &&
                                  firstVisit!.tglVisit != null &&
                                  firstVisit.visitIn != "" &&
                                  firstVisit.jamIn != "" &&
                                  firstVisit.visitOut == "" &&
                                  firstVisit.jamOut == "";

                              if (isCheckInOnly) {
                                // ===============================
                                // 🧹 DELETE MASUK
                                // ===============================
                                loadingDialog("menghapus data masuk...", "");

                                await SQLHelper.instance.deleteDataVisitMasuk(
                                  firstVisit.id!,
                                  firstVisit.tglVisit!,
                                  firstVisit.visitIn!,
                                );

                                final dataLive = {
                                  "type": "visit",
                                  "status": "masuk",
                                  "id": userData.id!,
                                  "tgl_visit": today,
                                  "visit_in": firstVisit.visitIn!,
                                };

                                await ServiceApi().deleteAbsVst(dataLive);
                                Get.back();
                              } else {
                                // ===============================
                                // 🧹 DELETE PULANG
                                // ===============================
                                final data = {
                                  "visit_out": "",
                                  "jam_out": "",
                                  "foto_out": "",
                                  "lat_out": "",
                                  "long_out": "",
                                  "device_info2": "",
                                };

                                loadingDialog("menghapus data pulang...", "");

                                await SQLHelper.instance.deleteDataVisitPulang(
                                  data,
                                  userData.id!,
                                  today,
                                );

                                final dataLive = {
                                  "type": "visit",
                                  "status": "pulang",
                                  "id": userData.id!,
                                  "tgl_visit": today,
                                  // 🔥 SAFE
                                  "visit_in": firstVisit?.visitIn ?? "",
                                };

                                await ServiceApi().deleteAbsVst(dataLive);
                                Get.back();
                              }
                            }
                          },
                          label: Text(
                            'Hapus data ${userData.visit == '0' ? 'absen' : 'visit'} masuk / pulang',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        OutlinedButton.icon(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.delete_sweep_rounded, color: red),
                          onPressed: () async {
                            await SQLHelper.instance.truncateShift();
                            showToast('Data Shift berhasil dihapus');
                          },
                          label: Text(
                            'Hapus data shift',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        OutlinedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.delete_sweep_rounded, color: red),
                          onPressed: () async {
                            await SQLHelper.instance.truncateCabang();
                            showToast('Data Cabang berhasil dihapus');
                          },
                          label: Text(
                            'Hapus data cabang',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        OutlinedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.delete_sweep_rounded, color: red),
                          onPressed: () async {
                            await SQLHelper.instance.truncateCabang();
                            await SQLHelper.instance.truncateShift();
                            await SQLHelper.instance.truncateUser();
                            await SQLHelper.instance.truncateAbsen();
                            await SQLHelper.instance.truncateVisit();
                            await SQLHelper.instance.truncateLevel();
                            await SQLHelper.instance.truncateServer();
                            await dialogMsg(
                              'Hapus Data',
                              'Semua data berhasil dihapus\nSilahkan Login ulang',
                            );
                            Future.delayed(const Duration(seconds: 1), () {
                              auth.logout();
                              Get.back(closeOverlays: true);
                            });
                            showToast('Data berhasil dihapus');
                          },
                          label: Text(
                            'Hapus Semua Data',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
