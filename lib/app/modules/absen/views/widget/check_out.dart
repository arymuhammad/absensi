import 'dart:io';
import 'package:absensi/app/data/helper/time_service.dart';
import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final homeC = Get.find<HomeController>();

Future<void> checkOut(Data dataUser, double latitude, double longitude) async {
  bool checkoutSucceeded = false;
  bool isLoadingShown = false;

  try {
    final DateTime now = await getSecureTime();
    final String today = DateFormat('yyyy-MM-dd').format(now);
    final String nowTime = DateFormat('HH:mm').format(now);
    final String nowFull = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final String previous = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 1)));

    final targetDate = absC.isBeforeCheckoutLimitNow ? previous : today;

    final online = await absC.isOnline();

    // =======================
    // 🔁 CEK DATA ABSEN
    // =======================
    if (online) {
      if (absC.isBeforeCheckoutLimitNow) {
        await absC.cekDataAbsen("pulang", dataUser.id!, previous);
      } else {
        await absC.cekDataAbsen("masuk", dataUser.id!, today);
      }

      if (absC.cekAbsen.value.total == "0") {
        _resetState();
        Get.back();
        failedDialog(
          Get.context,
          "Warning",
          "Check in data not found\nPlease check in first",
        );
        return;
      }
    } else {
      // =======================
      // ⚠️ OFFLINE → CEK LOCAL
      // =======================
      final localCheck = await SQLHelper.instance.getAbsenToday(
        dataUser.id!,
        targetDate,
      );

      if (localCheck.isEmpty || localCheck.first.jamAbsenMasuk == null) {
        _resetState();
        Get.back();
        failedDialog(
          Get.context,
          "Warning",
          "Check in data not found (offline)",
        );
        return;
      }
    }

    // =======================
    // 📷 FOTO
    // =======================
    await absC.uploadFotoAbsen();
    Get.back();

    if (absC.image == null) {
      _resetState();
      failedDialog(Get.context, "Warning", "Check out was cancelled");
      return;
    }

    // =======================
    // 📦 LOCAL DB
    // =======================
    final localDataAbs = await SQLHelper.instance.getAbsenToday(
      dataUser.id!,
      targetDate,
    );

    loadingDialog("Sending data...", "");
    isLoadingShown = true;

    final data = {
      "status": "update",
      "id": dataUser.id,
      "tanggal_masuk": absC.isBeforeCheckoutLimitNow ? previous : today,
      "tanggal_pulang": today,
      "nama": dataUser.nama,
      "jam_absen_pulang": nowTime,
      "foto_pulang": File(absC.image!.path),
      "lat_pulang": latitude.toString(),
      "long_pulang": longitude.toString(),
      "device_info2": absC.devInfo.value,
    };

    if (localDataAbs.isNotEmpty) {
      final res = await SQLHelper.instance.updateDataAbsen(
        {
          "tanggal_pulang": today,
          "jam_absen_pulang": nowTime,
          "foto_pulang": absC.image!.path,
          "lat_pulang": latitude.toString(),
          "long_pulang": longitude.toString(),
          "device_info2": absC.devInfo.value,
          "status_sync": "PENDING", // 🔥 WAJIB
        },
        dataUser.id!,
        targetDate,
      );

      // Get.back();
      if (res.success) {
        // =======================
        // ✅ CHECKOUT LOGIS BERHASIL
        // =======================
        checkoutSucceeded = true;
        // showToast("Update succeed");
        // =======================
        // 🚀 SERVER / SYNC
        // =======================
        // Sync akan handle online/offline sendiri
        absC.triggerSync(isVisit: false);

        // atau triggerSync()
      } else {
        showToast(res.message);
        return;
      }
    } else {
      if (!online) {
        failedDialog(Get.context, "Warning", "Data not available offline");
        return;
      }

      // ✅ gunakan hasil cek awal (jangan panggil lagi)
      if (absC.cekAbsen.value.total == "0") {
        failedDialog(Get.context, "Warning", "Check in not found");
        return;
      }

      // ✅ langsung submit ke server
      await ServiceApi().submitAbsen(data, false);

      // ✅ penting: recreate local data biar konsisten
      await SQLHelper.instance.insertDataAbsen(
        Absen(
          idUser: dataUser.id,
          tanggalMasuk: targetDate,
          tanggalPulang: today,
          nama: dataUser.nama,
          jamAbsenPulang: nowTime,
          fotoPulang: absC.image!.path,
          latPulang: latitude.toString(),
          longPulang: longitude.toString(),
          devInfo2: absC.devInfo.value,
          statusSync: "SUCCESS",
        ),
      );

      checkoutSucceeded = true;
    }

    // =======================
    // 🚀 SERVER / SYNC
    // =======================
    // if (online) {
    //   try {
    //     await ServiceApi().submitAbsen(data, false);
    //     await SQLHelper.instance.updateStatusAbsen(
    //       dataUser.id!,
    //       absC.isBeforeCheckoutLimitNow ? previous : today,
    //       "SUCCESS",
    //     );
    //   } catch (_) {
    //     absC.triggerSync(isVisit: false); // fallback kalau API gagal
    //   }
    // } else {
    //   absC.triggerSync(isVisit: false); // offline → pending sync
    // }

    // =======================
    // 🔥 XMOR (OPTIONAL ONLINE)
    // =======================
    if (online) {
      absC.sendDataToXmor(
        dataUser.id!,
        "clock_out",
        nowFull,
        absC.cekAbsen.value.idShift ?? "",
        latitude.toString(),
        longitude.toString(),
        absC.lokasi.value,
        dataUser.namaCabang!,
        dataUser.kodeCabang!,
        absC.devInfo.value,
      );
    }

    // =======================
    // 🔄 REFRESH
    // =======================
    absC.getAbsenToday({
      "mode": "single",
      "id_user": dataUser.id,
      "tanggal_masuk": today,
    });

    absC.getLimitAbsen({
      "mode": "limit",
      "id_user": dataUser.id,
      "tanggal1": absC.initDate1,
      "tanggal2": absC.initDate2,
    });

    homeC.reloadSummary(dataUser.id!);
    absC.startTimer(10);
    absC.resend();
  } finally {
    // 🔥 TUTUP LOADING DI SINI
    if (isLoadingShown && (Get.isDialogOpen ?? false)) {
      Get.back();
    }

    if (checkoutSucceeded) {
      await absC.resetAbsenToday(dataUser);
      succesDialog(
        context: Get.context!,
        pageAbsen: "Y",
        desc:
            "Please do not close the application during the attendance data synchronization process.",
        type: DialogType.warning,
        title: 'Warning',
        btnOkOnPress: () {
          auth.selectedMenu(0);
          Future.delayed(const Duration(milliseconds: 300));
          Get.back();
        },
      );
      absC.cekAbsen.value.total = "0";
    }
    _resetState();
  }
}

// =======================
// 🧹 RESET UI STATE
// =======================
void _resetState() {
  absC.stsAbsenSelected.value = "";
  absC.selectedShift.value = "";
  absC.selectedCabang.value = "";
  absC.lat.value = "";
  absC.long.value = "";
}
