import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../data/model/login_model.dart';
import '../../../services/service_api.dart';
import '../../home/controllers/home_controller.dart';

class BackupView extends GetView {
  BackupView({super.key});
  final ctrl = Get.find<AddPegawaiController>();
  final auth = Get.find<LoginController>();
  final absC = Get.find<AbsenController>();
  final homeC = Get.find<HomeController>();

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
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.mainGradient(
                                context: context,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),

                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_download_rounded),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),

                              onPressed: ctrl.backupDatabase,
                              label: const Text('Backup'),
                            ),
                          ),
                          const Text('Cadangkan data'),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.mainGradient(
                                context: context,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),

                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.backup),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: ctrl.restoreDatabase,

                              label: const Text('Restore'),
                            ),
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
                            absC.triggerSyncSafe(
                              isVisit: userData.visit == "1",
                            );

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
                            try {
                              loadingDialog("menghapus data...", "");

                              if (userData.visit == '0') {
                                // cek data absen
                                var tempDataAbs = await SQLHelper.instance
                                    .getAbsenToday(
                                      userData.id!,
                                      DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                    );

                                if (tempDataAbs.isEmpty) {
                                  showToast(
                                    "Data absen hari ini tidak ditemukan",
                                  );
                                  return;
                                }

                                final today = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now());

                                final hasCheckInOnly =
                                    tempDataAbs.first.tanggalMasuk != null &&
                                    tempDataAbs.first.tanggalPulang == null;

                                if (hasCheckInOnly) {
                                  // ===============================
                                  // 🧹 DELETE CHECK IN (MASUK)
                                  // ===============================

                                  final dataLive = {
                                    "type": "absen",
                                    "status": "masuk",
                                    "id": userData.id!,
                                    "tanggal_masuk": today,
                                  };

                                  final success = await ServiceApi()
                                      .deleteAbsVst(dataLive);
                                  if (!success) {
                                    return;
                                  }

                                  final firstData = tempDataAbs.first;
                                  await SQLHelper.instance.deleteDataAbsenMasuk(
                                    firstData.idUser!,
                                    firstData.tanggalMasuk!,
                                  );

                                  // REFRESH UI

                                  await refreshTodayData(userData, today);
                                } else {
                                  // ===============================
                                  // 🧹 DELETE CHECK OUT (PULANG)
                                  // ===============================

                                  final dataLive = {
                                    "type": "absen",
                                    "status": "pulang",
                                    "id": userData.id!,
                                    "tanggal_masuk": today,
                                  };

                                  final success = await ServiceApi()
                                      .deleteAbsVst(dataLive);
                                  if (!success) {
                                    return;
                                  }

                                  final dataLocal = {
                                    "tanggal_pulang": null,
                                    "jam_absen_pulang": "",
                                    "foto_pulang": "",
                                    "lat_pulang": "",
                                    "long_pulang": "",
                                    "device_info2": "",
                                  };

                                  await SQLHelper.instance
                                      .deleteDataAbsenPulang(
                                        dataLocal,
                                        userData.id!,
                                        today,
                                      );

                                  // REFRESH UI
                                  await refreshTodayData(userData, today);
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

                                if (tempDataVisit.isEmpty) {
                                  showToast(
                                    "Data visit hari ini tidak ditemukan",
                                  );
                                  return;
                                }

                                final firstVisit = tempDataVisit.first;

                                final isCheckInOnly =
                                    firstVisit.tglVisit != null &&
                                    firstVisit.visitIn != "" &&
                                    firstVisit.jamIn != "" &&
                                    firstVisit.visitOut == "" &&
                                    firstVisit.jamOut == "";

                                if (isCheckInOnly) {
                                  // ===============================
                                  // 🧹 DELETE MASUK
                                  // ===============================
                                  // loadingDialog("menghapus data masuk...", "");

                                  final dataLive = {
                                    "type": "visit",
                                    "status": "masuk",
                                    "id": userData.id!,
                                    "tgl_visit": today,
                                    "visit_in": firstVisit.visitIn!,
                                  };

                                  final success = await ServiceApi()
                                      .deleteAbsVst(dataLive);
                                  if (!success) {
                                    return;
                                  }

                                  await SQLHelper.instance.deleteDataVisitMasuk(
                                    firstVisit.id!,
                                    firstVisit.tglVisit!,
                                    firstVisit.visitIn!,
                                  );

                                  //REFRESH UI
                                  await refreshTodayData(userData, today);
                                  // Get.back();
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

                                  // loadingDialog("menghapus data pulang...", "");

                                  final dataLive = {
                                    "type": "visit",
                                    "status": "pulang",
                                    "id": userData.id!,
                                    "tgl_visit": today,
                                    // 🔥 SAFE
                                    "visit_in": firstVisit.visitIn ?? "",
                                  };

                                  final success = await ServiceApi()
                                      .deleteAbsVst(dataLive);
                                  if (!success) {
                                    return;
                                  }

                                  await SQLHelper.instance
                                      .deleteDataVisitPulang(
                                        data,
                                        userData.id!,
                                        today,
                                      );
                                  // Get.back();
                                  // REFRESH UI
                                  await refreshTodayData(userData, today);
                                }
                              }
                            } catch (e) {
                              showToast(e.toString());
                            } finally {
                              closeLoading();
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
                            showToast('Data Shift berhasil diperbarui');

                            // RELOAD SHIFT
                            await absC.getShift();
                          },
                          label: Text(
                            'Perbarui data shift',
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

  Future<void> refreshTodayData(Data userData, String today) async {
    if (userData.visit == '0') {
      await absC.getAbsenToday({
        "mode": "single",
        "id_user": userData.id,
        "tanggal_masuk": today,
      });

      await absC.getLimitAbsen({
        "mode": "limit",
        "id_user": userData.id,
        "tanggal1": absC.initDate1,
        "tanggal2": absC.initDate2,
      });

      await homeC.getSummAttPerMonth(userData.id!);
    } else {
      await absC.getVisitToday({
        "mode": "single",
        "id_user": userData.id,
        "tgl_visit": today,
      });

      await absC.getLimitVisit({
        "mode": "limit",
        "id_user": userData.id,
        "tanggal1": absC.initDate1,
        "tanggal2": absC.initDate2,
      });
    }
  }
}
