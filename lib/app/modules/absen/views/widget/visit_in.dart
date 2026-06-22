import 'dart:io';
import 'package:absensi/app/data/helper/db_result.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/helper/resolve_location_helper.dart';
import '../../../../data/helper/time_service.dart';
import '../../../../data/model/login_model.dart';
import '../../../../data/model/visit_model.dart';
import '../../../../services/service_api.dart';
import '../../controllers/absen_controller.dart';

// final absC = Get.find<AbsenController>();
Future<DbResult> visitIn({
  required Data dataUser,
  required AbsenController controller,
  required double latitude,
  required double longitude,
}) async {
  bool insertSuccess = false;

  try {
    final DateTime now = await getSecureTime();
    final String dateNow = DateFormat('yyyy-MM-dd').format(now);
    final String timeNow = DateFormat('HH:mm').format(now);

    final online = await controller.isOnline();
    bool sudahVisit = false;

    final visitLocation = resolveVisitLocation(dataUser, controller);

    
    if (visitLocation.trim().isEmpty) {
      failedDialog(Get.context, "Error", "Visit location tidak boleh kosong");
      return DbResult(success: false, message: "Empty visit location");
    }

    // ===============================
    // ✅ ONLINE → CEK SERVER
    // ===============================
    if (online) {
      await controller.cekDataVisit(
        "masuk",
        dataUser.id!,
        dateNow,
        visitLocation,
      );

      if (controller.cekVisit.value.total != "0") {
        sudahVisit = true;
      }
    } else {
      // ===============================
      // ⚠️ OFFLINE → CEK LOCAL
      // ===============================
      final localData = await SQLHelper.instance.getVisitToday(
        dataUser.id!,
        dateNow,
        visitLocation,
        1,
      );

      if (localData.isNotEmpty) {
        sudahVisit = true;
      }
    }

    // ===============================
    // 🚫 BLOCK JIKA SUDAH VISIT
    // ===============================
    if (sudahVisit) {
      _resetVisitState(controller);
      succesDialog(
        context: Get.context!,
        pageAbsen: "N",
        desc: "You have checked in today",
        type: DialogType.info,
        title: 'INFO',
        btnOkOnPress: () => Get.back(),
      );
      return DbResult(success: false, message: "You have checked in today");
    }

    // =======================
    // 📷 FOTO
    // =======================
    await controller.uploadFotoAbsen(isVisit: true);
    // Get.back();

    if (controller.image == null) {
      failedDialog(Get.context, "Warning", "Check in was cancelled");
      return DbResult(success: false, message: "Check in cancelled");
    }

    loadingDialog("Sending data...", "");

    var data = {
      "status": "add",
      "id": dataUser.id,
      "nama": dataUser.nama,
      "tgl_visit": dateNow,
      "visit_in": visitLocation,
      "jam_in": timeNow,
      "foto_in": File(controller.image!.path),
      "foto_out": "",
      "lat_in": latitude.toString(),
      "long_in": longitude.toString(),
      "device_info": controller.devInfo.value,
      "is_rnd":
          controller.optVisitSelected.value == "Research and Development"
              ? "1"
              : "0",
    };

    // =======================
    // 💾 SQLITE (WAJIB)
    // =======================
    final res = await SQLHelper.instance.insertDataVisit(
      Visit(
        id: dataUser.id,
        nama: dataUser.nama,
        tglVisit: dateNow,
        visitIn: visitLocation,
        jamIn: timeNow,
        visitOut: '',
        jamOut: '',
        fotoIn: controller.image!.path,
        latIn: latitude.toString(),
        longIn: longitude.toString(),
        fotoOut: '',
        latOut: '',
        longOut: '',
        deviceInfo: controller.devInfo.value,
        deviceInfo2: '',
        isRnd:
            controller.optVisitSelected.value == "Research and Development"
                ? "1"
                : "0",
        statusSync: "PENDING",
      ),
    );

    controller.updateSyncVisitStatusRealtime(
      id: dataUser.id!,
      tglVisit: dateNow,
      visitIn: visitLocation,
      status: "PENDING",
    );
    if (!res.success) {
      Get.back(); // ❗ tutup loading
      showToast(res.message);
      return DbResult(success: false, message: res.message);
    }

    insertSuccess = true;

    // =======================
    // 🚀 SERVER (HANYA ONLINE)
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

        controller.updateSyncVisitStatusRealtime(
          id: dataUser.id!,
          tglVisit: dateNow,
          visitIn: visitLocation,
          status: "SUCCESS",
        );
      } catch (_) {
        controller.triggerSync(isVisit: true);
      }
    } else {
      controller.triggerSync(isVisit: true);
    }

    // =======================
    // 🔄 REFRESH UI
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

    Get.back(); // tutup loading

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

    return DbResult(success: true, message: "Check in success");
  } catch (e) {
    Get.back(); // ❗ pastikan loading ketutup
    // showToast("Error: ${e.toString()}");
    // rethrow;
    return DbResult(success: false, message: e.toString());
  } finally {
    if (insertSuccess) {
      _resetVisitState(controller);
    }
  }
}

// =======================
// 🧹 RESET VISIT STATE
// =======================
void _resetVisitState(AbsenController controller) {
  controller.stsAbsenSelected.value = "";
  controller.optVisitSelected.value = "";
  controller.selectedCabangVisit.value = "";
  controller.rndLoc.clear();
  controller.lat.value = "";
  controller.long.value = "";
  controller.isQrValidated.value = false;
}
