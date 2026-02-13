import 'dart:io';

import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/helper/time_service.dart';
import '../../../../services/service_api.dart';
import '../../controllers/absen_controller.dart';

final absC = Get.find<AbsenController>();
visitOut({
  required Data dataUser,
  required double latitude,
  required double longitude,
}) async {
  // if (!await AbsensiGuard.validateTime()) return;

  // if (TimeService.isClockMovedBack()) {
  //   Get.back();
  //   showToast("Device time manipulation detected");
  //   return;
  // }

  // if (TimeService.isTimezoneSpoofed()) {
  //   Get.back();
  //   showToast("Timezone manipulation detected");
  //   return;
  // }

  // if (await TimeService.isDeviceRebooted()) {
  //   Get.back();
  //   showToast("Device restarted, syncing time...");
  //   await TimeService.syncServerTime();
  //   return;
  // }

  // =======================
  // ⏱️ TIME SOURCE (NEW)
  // =======================
  final DateTime? now = await getServerTimeLocal();
  final String dateNow = DateFormat('yyyy-MM-dd').format(now!);
  final String timeNow = DateFormat('HH:mm').format(now);

  // final synced = await TimeService.syncServerTime();
  // if (!synced && TimeService.isUntrustedTime(maxFallbackMinutes: 10)) {
  //   Get.back();
  //   showToast('Unable to sync server time');
  //   return;
  // }

  await absC.cekDataVisit(
    "masuk",
    dataUser.id!,
    dateNow,
    absC.optVisitSelected.value == "Store Visit"
        ? absC.selectedCabangVisit.isNotEmpty
            ? absC.selectedCabangVisit.value
            : dataUser.kodeCabang!
        : absC.rndLoc.text,
  );

  if (absC.cekVisit.value.total == "0") {
    Get.back();
    failedDialog(
      Get.context,
      "Warning",
      "Check In data not found\n\nMake sure the Checkout name/location\nis the same as the Check In name/location",
    );
    return;
  }

  // =======================
  // 📷 FOTO
  // =======================
  await absC.uploadFotoAbsen();
  Get.back();

  if (absC.image == null) {
    Get.back();
    failedDialog(Get.context, "Warning", "Check out was cancelled");
    return;
  }

  loadingDialog("Sending data...", "");

  var data = {
    "status": "update",
    "id": dataUser.id,
    "nama": dataUser.nama,
    "tgl_visit": dateNow,
    "visit_out":
        absC.optVisitSelected.value == "Store Visit"
            ? absC.selectedCabangVisit.isNotEmpty
                ? absC.selectedCabangVisit.value
                : dataUser.kodeCabang
            : absC.rndLoc.text,
    "visit_in": absC.cekVisit.value.kodeStore,
    "jam_out": timeNow,
    "foto_out": File(absC.image!.path),
    "lat_out": latitude.toString(),
    "long_out": longitude.toString(),
    "device_info2": absC.devInfo.value,
  };

  // =======================
  // 💾 SQLITE UPDATE
  // =======================
  SQLHelper.instance.updateDataVisit(
    {
      "visit_out":
          absC.optVisitSelected.value == "Store Visit"
              ? absC.selectedCabangVisit.isNotEmpty
                  ? absC.selectedCabangVisit.value
                  : dataUser.kodeCabang
              : absC.rndLoc.text,
      "jam_out": timeNow,
      "foto_out": absC.image!.path,
      "lat_out": latitude.toString(),
      "long_out": longitude.toString(),
      "device_info2": absC.devInfo.value,
    },
    dataUser.id!,
    dateNow,
    absC.optVisitSelected.value == "Store Visit"
        ? absC.selectedCabangVisit.isNotEmpty
            ? absC.selectedCabangVisit.value
            : dataUser.kodeCabang!
        : absC.rndLoc.text,
  );

  // =======================
  // 🚀 SERVER
  // =======================
  await ServiceApi().submitVisit(data, false);

  // =======================
  // 🔄 REFRESH
  // =======================
  absC.getVisitToday({
    "mode": "single",
    "id_user": dataUser.id,
    "tgl_visit": dateNow,
  });

  absC.getLimitVisit({
    "mode": "limit",
    "id_user": dataUser.id,
    "tanggal1": absC.initDate1,
    "tanggal2": absC.initDate2,
  });

  absC.startTimer(10);
  absC.resend();

  // =======================
  // 🧹 RESET STATE
  // =======================
  absC.selectedCabangVisit.value = "";
  absC.lat.value = "";
  absC.long.value = "";
  absC.optVisitSelected.value = "";
  absC.stsAbsenSelected.value = "";
  absC.rndLoc.clear();
}
