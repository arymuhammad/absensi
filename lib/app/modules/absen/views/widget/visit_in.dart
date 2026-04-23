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
  bool insertSuccess = false;

  try {
    final DateTime now = await getSecureTime();
    final String dateNow = DateFormat('yyyy-MM-dd').format(now);
    final String timeNow = DateFormat('HH:mm').format(now);

    final online = await absC.isOnline();
    bool sudahVisit = false;

    final visitLocation =
        absC.optVisitSelected.value == "Store Visit"
            ? absC.selectedCabangVisit.isNotEmpty
                ? absC.selectedCabangVisit.value
                : dataUser.kodeCabang!
            : absC.rndLoc.text;

    // ===============================
    // ✅ ONLINE → CEK SERVER
    // ===============================
    if (online) {
      await absC.cekDataVisit("masuk", dataUser.id!, dateNow, visitLocation);

      if (absC.cekVisit.value.total != "0") {
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
      _resetVisitState();
      succesDialog(
        context: Get.context!,
        pageAbsen: "N",
        desc: "You have checked in today",
        type: DialogType.info,
        title: 'INFO',
        btnOkOnPress: () => Get.back(),
      );
      return;
    }

    // =======================
    // 📷 FOTO
    // =======================
    await absC.uploadFotoAbsen();
    // Get.back();

    if (absC.image == null) {
      failedDialog(Get.context, "Warning", "Check in was cancelled");
      return;
    }

    loadingDialog("Sending data...", "");

    var data = {
      "status": "add",
      "id": dataUser.id,
      "nama": dataUser.nama,
      "tgl_visit": dateNow,
      "visit_in": visitLocation,
      "jam_in": timeNow,
      "foto_in": File(absC.image!.path),
      "foto_out": "",
      "lat_in": latitude.toString(),
      "long_in": longitude.toString(),
      "device_info": absC.devInfo.value,
      "is_rnd":
          absC.optVisitSelected.value == "Research and Development" ? "1" : "0",
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
        statusSync: "PENDING",
      ),
    );
    if (!res.success) {
      Get.back(); // ❗ tutup loading
      showToast(res.message);
      return;
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
      } catch (_) {
        absC.triggerSync(isVisit: true);
      }
    } else {
      absC.triggerSync(isVisit: true);
    }

    // =======================
    // 🔄 REFRESH UI
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
  } catch (e) {
    Get.back(); // ❗ pastikan loading ketutup
    showToast("Error: ${e.toString()}");
  } finally {
    if (insertSuccess) {
      _resetVisitState();
    }
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
