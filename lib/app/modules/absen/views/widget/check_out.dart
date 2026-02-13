import 'dart:io';
import 'package:absensi/app/data/helper/time_service.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final homeC = Get.find<HomeController>();

Future<void> checkOut(Data dataUser, double latitude, double longitude) async {
  bool checkoutSucceeded = false;

  try {
    // =======================
    // 🔐 VALIDASI WAKTU
    // =======================

    // ⛔ BLOCK jika jam device tidak trusted
    // if (TimeService.isUntrustedTime(maxFallbackMinutes: 10)) {
    //   Get.back();
    //   showToast('Unable to verify server time');
    //   return;
    // }

    // // ⛔ manipulasi waktu / timezone
    // if (!await AbsensiGuard.validateTime()) return;

//     if (TimeService.isClockMovedBack()) {
//       Get.back();
//       showToast("Device time manipulation detected");
//       return;
//     }

//     if (TimeService.isTimezoneSpoofed()) {
//       Get.back();
//       showToast("Timezone manipulation detected");
//       return;
//     }

//    if (await TimeService.isDeviceRebooted()) {
//   Get.back();
//   showToast("Device restarted, syncing time...");
//   await TimeService.syncServerTime();
//   return;
// }


    // =======================
    // ⏱️ WAKTU SERVER
    // =======================
    final DateTime? now = await getServerTimeLocal();
    final String today = DateFormat('yyyy-MM-dd').format(now!);
    final String nowTime = DateFormat('HH:mm').format(now);
    final String nowFull = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final String previous = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 1)));

    // =======================
    // 🔁 CEK DATA ABSEN
    // =======================
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

    // =======================
    // 📷 AMBIL FOTO
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
      today,
    );

    loadingDialog("Sending data...", "");

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
      await SQLHelper.instance.updateDataAbsen(
        {
          "tanggal_pulang": today,
          "jam_absen_pulang": nowTime,
          "foto_pulang": absC.image!.path,
          "lat_pulang": latitude.toString(),
          "long_pulang": longitude.toString(),
          "device_info2": absC.devInfo.value,
        },
        dataUser.id!,
        absC.isBeforeCheckoutLimitNow ? previous : today,
      );
    }

    // =======================
    // ✅ CHECKOUT LOGIS BERHASIL
    // =======================
    checkoutSucceeded = true;

    // =======================
    // 🚀 SERVER
    // =======================
    await ServiceApi().submitAbsen(data, false);

    absC.sendDataToXmor(
      dataUser.id!,
      "clock_out",
      nowFull,
      absC.cekAbsen.value.idShift!,
      latitude.toString(),
      longitude.toString(),
      absC.lokasi.value,
      dataUser.namaCabang!,
      dataUser.kodeCabang!,
      absC.devInfo.value,
    );

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
    // =======================
    // 🔒 UI STATE (DIJAMIN)
    // =======================
    if (checkoutSucceeded) {
      await absC.resetAbsenToday(dataUser);
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
