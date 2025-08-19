import 'dart:io';

import 'package:absensi/app/data/model/login_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../services/service_api.dart';
import '../../controllers/absen_controller.dart';

final absC = Get.find<AbsenController>();
visitOut({
  required Data dataUser,
  required double latitude,
  required double longitude,
}) async {
  await absC.cekDataVisit(
    "masuk",
    dataUser.id!,
    absC.dateNow,
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
      "Peringatan",
      "Data Check In tidak ditemukan\nHarap Check In terlebih dahulu",
    );
  } else {
    await absC.uploadFotoAbsen();
    Get.back();
    if (absC.image != null) {
      loadingDialog("Sedang mengirim data...", "");
      var data = {
        "status": "update",
        "id": dataUser.id,
        "nama": dataUser.nama,
        "tgl_visit": DateFormat('yyyy-MM-dd').format(
          DateTime.parse(
            absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
          ),
        ),
        "visit_out":
            absC.optVisitSelected.value == "Store Visit"
                ? absC.selectedCabangVisit.isNotEmpty
                    ? absC.selectedCabangVisit.value
                    : dataUser.kodeCabang
                : absC.rndLoc.text,
        "visit_in": absC.cekVisit.value.kodeStore,
        "jam_out": absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
        "foto_out": File(absC.image!.path),
        "lat_out": latitude.toString(),
        "long_out": longitude.toString(),
        "device_info2": absC.devInfo.value,
      };

      // update data visit ke local storage
      SQLHelper.instance.updateDataVisit(
        {
          "visit_out":
              absC.optVisitSelected.value == "Store Visit"
                  ? absC.selectedCabangVisit.isNotEmpty
                      ? absC.selectedCabangVisit.value
                      : dataUser.kodeCabang
                  : absC.rndLoc.text,
          "jam_out": absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
          "foto_out": absC.image!.path,
          "lat_out": latitude.toString(),
          "long_out": longitude.toString(),
          "device_info2": absC.devInfo.value,
        },
        dataUser.id!,
        DateFormat('yyyy-MM-dd').format(
          DateTime.parse(
            absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
          ),
        ),
        absC.optVisitSelected.value == "Store Visit"
            ? absC.selectedCabangVisit.isNotEmpty
                ? absC.selectedCabangVisit.value
                : dataUser.kodeCabang!
            : absC.rndLoc.text,
      );
      // update data visit ke server
      // offline first
      await ServiceApi().submitVisit(data, false);
      // Get.back();
      // succesDialog(Get.context, "Y",
      //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
      var paramVisitToday = {
        "mode": "single",
        "id_user": dataUser.id,
        "tgl_visit": DateFormat('yyyy-MM-dd').format(
          DateTime.parse(
            absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
          ),
        ),
      };

      var paramLimitVisit = {
        "mode": "limit",
        "id_user": dataUser.id,
        "tanggal1": absC.initDate1,
        "tanggal2": absC.initDate2,
      };
      absC.getVisitToday(paramVisitToday);
      absC.getLimitVisit(paramLimitVisit);
      absC.startTimer(10);
      absC.resend();
      absC.selectedCabangVisit.value = "";
      absC.lat.value = "";
      absC.long.value = "";
      absC.optVisitSelected.value = "";
      absC.rndLoc.clear();
    } else {
      Get.back();
      failedDialog(Get.context, "Peringatan", "Check Out dibatalkan");
    }
  }
}
