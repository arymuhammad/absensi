import 'dart:io';

import 'package:absensi/app/data/model/login_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/helper/db_result.dart';
import '../../../../data/helper/resolve_location_helper.dart';
import '../../../../data/helper/time_service.dart';
import '../../../../services/service_api.dart';
import '../../controllers/absen_controller.dart';

// final controller = Get.find<AbsenController>();
Future<DbResult> visitOut({
  required Data dataUser,
  required AbsenController controller,
  required double latitude,
  required double longitude,
}) async {
  bool updateSuccess = false;

  try {
    final DateTime now = await getSecureTime();
    final String dateNow = DateFormat('yyyy-MM-dd').format(now);
    final String timeNow = DateFormat('HH:mm').format(now);

    final online = await controller.isOnline();

    final visitLocation = resolveVisitLocation(dataUser, controller);

    
    if (visitLocation.trim().isEmpty) {
      failedDialog(Get.context, "Error", "Visit location tidak boleh kosong");
      return DbResult(success: false, message: "Empty visit location");
    }

    bool adaVisit = false;

    // ===============================
    // ✅ ONLINE → CEK SERVER
    // ===============================
    if (online) {
      loadingDialog("Checking data", "");
      await controller.cekDataVisit(
        "masuk",
        dataUser.id!,
        dateNow,
        visitLocation,
      );

      if (controller.cekVisit.value.total != "0") {
        adaVisit = true;
      }
    }
    // ===============================
    // ⚠️ OFFLINE → CEK LOCAL
    // ===============================
    else {
      loadingDialog("Checking data", "");
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
      closeLoading();
      failedDialog(
        Get.context,
        "Warning",
        "Check In data not found\n\nMake sure the Checkout name/location\nis the same as the Check In name/location",
      );
      return DbResult(success: false, message: "Check out failed");
    }

    // =======================
    // 📷 FOTO (FIX: TANPA GET.BACK)
    // =======================
    await controller.uploadFotoAbsen(isVisit: true);

    if (controller.image == null) {
      closeLoading();
      failedDialog(Get.context, "Warning", "Check out was cancelled");
      return DbResult(success: false, message: "Check in cancelled");
    }

    await Future.delayed(const Duration(milliseconds: 200));
    closeLoading();
    loadingDialog("Sending data...", "");

    var data = {
      "status": "update",
      "id": dataUser.id,
      "nama": dataUser.nama,
      "tgl_visit": dateNow,
      "visit_out": visitLocation,
      "visit_in":
          online
              ? controller.cekVisit.value.kodeStore
              : visitLocation, // fallback offline
      "jam_out": timeNow,
      "foto_out": File(controller.image!.path),
      "lat_out": latitude.toString(),
      "long_out": longitude.toString(),
      "device_info2": controller.devInfo.value,
    };

    // =======================
    // 💾 SQLITE UPDATE (WAJIB)
    // =======================

    final localVisit = await SQLHelper.instance.getVisitToday(
      dataUser.id!,
      dateNow,
      visitLocation,
      1,
    );

    if (localVisit.isNotEmpty) {
      final res = await SQLHelper.instance.updateDataVisit(
        {
          "visit_out": visitLocation,
          "jam_out": timeNow,
          "foto_out": controller.image!.path,
          "lat_out": latitude.toString(),
          "long_out": longitude.toString(),
          "device_info2": controller.devInfo.value,
          "status_sync": "PENDING", // 🔥 WAJIB
        },
        dataUser.id!,
        dateNow,
        visitLocation,
      );

      controller.updateSyncVisitStatusRealtime(
        id: dataUser.id!,
        tglVisit: dateNow,
        visitIn: visitLocation,
        status: "PENDING",
      );

      if (!res.success) {
        closeLoading(); // ❗ tutup loading
        showToast(res.message);
        return DbResult(success: false, message: res.message);
      }

      updateSuccess = true;

      // =======================
      // 🚀 SERVER / SYNC
      // =======================
      if (online) {
        try {
          final submitRes = await ServiceApi().submitVisit(data, false);

          if (submitRes == null || submitRes['success'] != true) {
            controller.triggerSync(isVisit: true);

            // return DbResult(
            //   success: false,
            //   message: submitRes?['message'] ?? "Visit out failed",
            // );
          } else {
            await SQLHelper.instance.updateStatusVisit(
              dataUser.id!,
              dateNow,
              visitLocation,
              "SUCCESS",
            );
            controller.updateSyncVisitStatusRealtime(
              id: dataUser.id!,
              tglVisit: dateNow,
              visitIn: visitLocation,
              status: "SUCCESS",
            );
          }
        } catch (_) {
          controller.triggerSync(isVisit: true);
        }
      } else {
        controller.triggerSync(isVisit: true);
      }
      ///////
    } else {
      // =======================
      // LOCAL HILANG, SERVER MASIH ADA
      // =======================

      if (!online) {
        closeLoading();

        return DbResult(
          success: false,
          message: "Visit data not available offline",
        );
      }

      final submitRes = await ServiceApi().submitVisit(data, false);

      if (submitRes == null || submitRes['success'] != true) {
        closeLoading();

        return DbResult(
          success: false,
          message: submitRes?['message'] ?? "Visit out failed",
        );
      }

      final response = await ServiceApi().getVisit({
        "mode": "single",
        "id_user": dataUser.id,
        "tgl_visit": dateNow,
      });

      if (response.isEmpty) {
        closeLoading();

        return DbResult(success: false, message: "Failed to reload visit data");
      }

      response.first.statusSync = "SUCCESS";

      final insertRes = await SQLHelper.instance.insertDataVisit(
        response.first,
      );

      if (!insertRes.success && insertRes.message != "Duplicate data") {
        closeLoading();

        return insertRes;
      }

      updateSuccess = true;
    }

    // =======================
    // 🔄 REFRESH
    // =======================
    controller.getVisitToday({
      "mode": "single",
      "id_user": dataUser.id,
      "tgl_visit": dateNow,
    });

    controller.getLimitVisit({
      "mode": "limit",
      "id_user": dataUser.id,
      "tanggal1": controller.initDate1,
      "tanggal2": controller.initDate2,
    });

    // controller.startTimer(10);
    // controller.resend();

    closeLoading(); // ✅ tutup loading
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

    return DbResult(success: true, message: "Check out success");
  } catch (e) {
    closeLoading(); // ❗ jaga-jaga kalau error di tengah
    // showToast("Error: ${e.toString()}");
    return DbResult(success: false, message: e.toString());
  } finally {
    if (updateSuccess) {
      // =======================
      // 🧹 RESET STATE
      // =======================
      controller.selectedCabangVisit.value = "";
      controller.lat.value = "";
      controller.long.value = "";
      controller.optVisitSelected.value = "";
      controller.stsAbsenSelected.value = "";
      controller.rndLoc.clear();
      controller.isQrValidated.value = false;
    }
  }
}
