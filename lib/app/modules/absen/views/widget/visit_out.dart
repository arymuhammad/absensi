import 'dart:io';

import 'package:absensi/app/data/model/login_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
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
  bool updateSuccess = false;

  try {
    final DateTime now = await getSecureTime();
    final String dateNow = DateFormat('yyyy-MM-dd').format(now);
    final String timeNow = DateFormat('HH:mm').format(now);

    final online = await absC.isOnline();

    final visitLocation =
        absC.optVisitSelected.value == "Store Visit"
            ? absC.selectedCabangVisit.isNotEmpty
                ? absC.selectedCabangVisit.value
                : dataUser.kodeCabang!
            : absC.rndLoc.text;

    bool adaVisit = false;

    // ===============================
    // ✅ ONLINE → CEK SERVER
    // ===============================
    if (online) {
      await absC.cekDataVisit("masuk", dataUser.id!, dateNow, visitLocation);

      if (absC.cekVisit.value.total != "0") {
        adaVisit = true;
      }
    }
    // ===============================
    // ⚠️ OFFLINE → CEK LOCAL
    // ===============================
    else {
      final localData = await SQLHelper.instance.getVisitToday(
        dataUser.id!,
        dateNow,
        visitLocation,
        1,
      );

      if (localData.isNotEmpty) {
        adaVisit = true;
      }
    }

    // ===============================
    // 🚫 BLOCK JIKA TIDAK ADA CHECKIN
    // ===============================
    if (!adaVisit) {
      Get.back();
      failedDialog(
        Get.context,
        "Warning",
        "Check In data not found\n\nMake sure the Checkout name/location\nis the same as the Check In name/location",
      );
      return;
    }

    // =======================
    // 📷 FOTO (FIX: TANPA GET.BACK)
    // =======================
    await absC.uploadFotoAbsen(isVisit: true);

    if (absC.image == null) {
      failedDialog(Get.context, "Warning", "Check out was cancelled");
      return;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    loadingDialog("Sending data...", "");

    var data = {
      "status": "update",
      "id": dataUser.id,
      "nama": dataUser.nama,
      "tgl_visit": dateNow,
      "visit_out": visitLocation,
      "visit_in":
          online
              ? absC.cekVisit.value.kodeStore
              : visitLocation, // fallback offline
      "jam_out": timeNow,
      "foto_out": File(absC.image!.path),
      "lat_out": latitude.toString(),
      "long_out": longitude.toString(),
      "device_info2": absC.devInfo.value,
    };

    // =======================
    // 💾 SQLITE UPDATE (WAJIB)
    // =======================
    final res = await SQLHelper.instance.updateDataVisit(
      {
        "visit_out": visitLocation,
        "jam_out": timeNow,
        "foto_out": absC.image!.path,
        "lat_out": latitude.toString(),
        "long_out": longitude.toString(),
        "device_info2": absC.devInfo.value,
        "status_sync": "PENDING", // 🔥 WAJIB
      },
      dataUser.id!,
      dateNow,
      visitLocation,
    );

    if (!res.success) {
      Get.back(); // ❗ tutup loading
      showToast(res.message);
      return;
    }

    updateSuccess = true;

    // =======================
    // 🚀 SERVER / SYNC
    // =======================
    if (online) {
      try {
        await ServiceApi().submitVisit(data, false);
        await SQLHelper.instance.updateStatusVisit(
          dataUser.id!,
          dateNow,
          visitLocation,
          "SUCCESS",
        );
      } catch (_) {
        absC.triggerSync(isVisit: true);
      }
    } else {
      absC.triggerSync(isVisit: true);
    }

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

    // absC.startTimer(10);
    // absC.resend();

    Get.back(); // ✅ tutup loading
    // =======================
    // ✅ UI SUCCESS (TIDAK BLOCK LOGIC)
    // =======================
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
  } catch (e) {
    Get.back(); // ❗ jaga-jaga kalau error di tengah
    showToast("Error: ${e.toString()}");
  } finally {
    if (updateSuccess) {
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
  }
}
