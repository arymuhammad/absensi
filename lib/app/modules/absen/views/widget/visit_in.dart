import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/helper/time_service.dart';
import '../../../../data/model/login_model.dart';
import '../../../../data/model/visit_model.dart';
import '../../../../services/service_api.dart';
import '../../controllers/absen_controller.dart';

final absC = Get.find<AbsenController>();
visitIn({
  required Data dataUser,
  required double latitude,
  required double longitude,
}) async {
  // =======================
  // ⏱️ TIME VALIDATION
  // =======================
  // await TimeService.tryResyncIfOld(maxAgeMinutes: 5);
  // // await TimeService.syncServerTime();
  // if (TimeService.isTimeManipulated()) {
  //   Get.back();
  //   showToast("Device time manipulation detected");
  //   return;
  // }

  // pastikan server time valid
  // if (TimeService.isUntrustedTime(maxFallbackMinutes: 1)) {
  //   await TimeService.syncServerTime();

  //   if (TimeService.isUntrustedTime(maxFallbackMinutes: 1)) {
  //     Get.back();
  //     showToast("Cannot verify real time. Check internet.");
  //     return;
  //   }
  // }

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
  //   // return;
  // }

  // =======================
  // ⏱️ TIME SOURCE (NEW)
  // =======================

  final DateTime? now = await getServerTimeLocal();
  final String dateNow = DateFormat('yyyy-MM-dd').format(now!);
  final String timeNow = DateFormat('HH:mm').format(now);
  // paksa resync jika fallback
  // await TimeService.tryResyncIfFallback();

  // if (TimeService.isUntrustedTime(maxFallbackMinutes: 1)) {
  //   Get.back();
  //   showToast('Unable to verify server time');
  //   return;
  // }
  // if (!await AbsensiGuard.validateTime()) return;

  // final lastVisit = await SQLHelper.instance.getLastVisit(dataUser.id!);

  // if (lastVisit != null) {
  //   final lastTime = DateTime.parse(lastVisit.jamIn!);

  //   if (now.isBefore(lastTime)) {
  //     Get.back();
  //     showToast("Time manipulation detected");
  //     return;
  //   }
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
    var tempDataVisit = await SQLHelper.instance.getVisitToday(
      dataUser.id!,
      dateNow,
      absC.optVisitSelected.value == "Store Visit"
          ? absC.selectedCabangVisit.isNotEmpty
              ? absC.selectedCabangVisit.value
              : dataUser.kodeCabang!
          : absC.rndLoc.text,
      1,
    );

    if (tempDataVisit.isEmpty) {
      // =======================
      // 📷 FOTO
      // =======================
      await absC.uploadFotoAbsen();
      Get.back();

      if (absC.image != null) {
        loadingDialog("Sending data...", "");

        var data = {
          "status": "add",
          "id": dataUser.id,
          "nama": dataUser.nama,
          "tgl_visit": dateNow,
          "visit_in":
              absC.optVisitSelected.value == "Store Visit"
                  ? absC.selectedCabangVisit.isNotEmpty
                      ? absC.selectedCabangVisit.value
                      : dataUser.kodeCabang
                  : absC.rndLoc.text,
          "jam_in": timeNow,
          "foto_in": File(absC.image!.path),
          "foto_out": "",
          "lat_in": latitude.toString(),
          "long_in": longitude.toString(),
          "device_info": absC.devInfo.value,
          "is_rnd":
              absC.optVisitSelected.value == "Research and Development"
                  ? "1"
                  : "0",
        };

        // =======================
        // 💾 SQLITE
        // =======================
        SQLHelper.instance.insertDataVisit(
          Visit(
            id: dataUser.id,
            nama: dataUser.nama,
            tglVisit: dateNow,
            visitIn:
                absC.optVisitSelected.value == "Store Visit"
                    ? absC.selectedCabangVisit.isNotEmpty
                        ? absC.selectedCabangVisit.value
                        : dataUser.kodeCabang
                    : absC.rndLoc.text,
            jamIn: timeNow,
            visitOut: '',
            jamOut: '',
            fotoIn: absC.image!.path,
            latIn: latitude.toString(),
            longIn: longitude.toString(),
            fotoOut: '',
            latOut: '',
            longOut: '',
            deviceInfo: absC.devInfo.value,
            deviceInfo2: '',
            isRnd:
                absC.optVisitSelected.value == "Research and Development"
                    ? "1"
                    : "0",
          ),
        );

        // =======================
        // 🚀 SERVER
        // =======================
        await ServiceApi().submitVisit(data, false);

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
        _resetVisitState();
      } else {
        Get.back();
        failedDialog(Get.context, "Warning", "Check in was cancelled");
      }
    } else {
      // =======================
      // 🚀 LANGSUNG KE SERVER
      // =======================
      await absC.uploadFotoAbsen();
      Get.back();

      if (absC.image != null) {
        loadingDialog("Sending data...", "");

        var data = {
          "status": "add",
          "id": dataUser.id,
          "nama": dataUser.nama,
          "tgl_visit": dateNow,
          "visit_in":
              absC.optVisitSelected.value == "Store Visit"
                  ? absC.selectedCabangVisit.isNotEmpty
                      ? absC.selectedCabangVisit.value
                      : dataUser.kodeCabang
                  : absC.rndLoc.text,
          "jam_in": timeNow,
          "foto_in": File(absC.image!.path),
          "foto_out": "",
          "lat_in": latitude.toString(),
          "long_in": longitude.toString(),
          "device_info": absC.devInfo.value,
          "is_rnd":
              absC.optVisitSelected.value == "Research and Development"
                  ? "1"
                  : "0",
        };

        await ServiceApi().submitVisit(data, false);

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
        _resetVisitState();
      } else {
        Get.back();
        failedDialog(Get.context, "Warning", "Check in was cancelled");
      }
    }
  } else {
    _resetVisitState();
    Get.back();
    succesDialog(
      context: Get.context!,
      pageAbsen: "N",
      desc: "You have checked in today",
      type: DialogType.info,
      title: 'INFO',
      btnOkOnPress: () => Get.back(),
    );
  }
}

// =======================
// 🧹 RESET VISIT STATE
// =======================
void _resetVisitState() {
  absC.stsAbsenSelected.value = "";
  absC.optVisitSelected.value = "";
  absC.selectedCabangVisit.value = "";
  absC.rndLoc.clear();
  absC.lat.value = "";
  absC.long.value = "";
}
