// import 'dart:io';
import 'package:absensi/app/data/helper/time_service.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/model/absen_model.dart';
import '../../../../data/model/login_model.dart';
// import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final homeC = Get.find<HomeController>();

checkIn(Data dataUser, double latitude, double longitude) async {
  /// 🔒 LOCK biar ga double klik
  if (absC.isLoading.value) return;
  absC.isLoading.value = true;
  try {
    final selectedShift = absC.selectedShift.value;

    // ✅ VALIDASI 1: kosong / 0
    if (selectedShift.isEmpty || selectedShift == "0") {
      failedDialog(Get.context, "Error", "Shift tidak valid");
      return;
    }

    // ✅ VALIDASI 2: harus ada di list shift
    final isValidShift = absC.shiftKerja.any((s) => s.id == selectedShift);

    if (!isValidShift) {
      failedDialog(Get.context, "Error", "Shift tidak ditemukan");
      return;
    }

    final selectedCabang =
        absC.selectedCabang.isNotEmpty
            ? absC.selectedCabang.value
            : dataUser.kodeCabang;

    final deviceInfo = absC.devInfo.value;
    // ===============================
    // 2️⃣ SNAPSHOT WAKTU SERVER
    // ===============================
    final DateTime nowLocal = await getSecureTime();
    final todayDate = DateFormat('yyyy-MM-dd').format(nowLocal);
    final timeNow = DateFormat('HH:mm').format(nowLocal);

    // ===============================
    // 3️⃣ CEK ABSEN HARI INI (SERVER)
    // ===============================
    final isOnline = await absC.isReallyOnline();
    bool sudahAbsen = false;

    // ✅ ONLINE → CEK SERVER
    // ===============================
    if (isOnline) {
      await absC.cekDataAbsen("masuk", dataUser.id!, todayDate);

      if (absC.cekAbsen.value.total != "0") {
        sudahAbsen = true;
      }
    } // ===============================
    // ⚠️ OFFLINE → CEK LOCAL
    // ===============================
    else {
      final localDataAbs = await SQLHelper.instance.getAbsenToday(
        dataUser.id!,
        todayDate,
      );

      if (localDataAbs.isNotEmpty) {
        sudahAbsen = true;
      }
    }
    // ===============================
    // 🚫 BLOCK JIKA SUDAH ABSEN
    // ===============================
    if (sudahAbsen) {
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
    // if (absC.cekAbsen.value.total != "0") {
    //   // _resetForm();
    //   // Get.back();
    //   succesDialog(
    //     context: Get.context!,
    //     pageAbsen: "N",
    //     desc: "You have checked in today",
    //     type: DialogType.info,
    //     title: 'INFO',
    //     btnOkOnPress: () => Get.back(),
    //   );
    //   return;
    // }

    // ===============================
    // 4️⃣ FOTO WAJIB
    // ===============================
    await absC.uploadFotoAbsen(isVisit: false);
    Get.back();

    if (absC.image == null) {
      // _resetForm();
      failedDialog(Get.context, "Warning", "Check in was cancelled");
      return;
    }
    final imagePath = absC.image!.path;

    // ===============================
    // 5️⃣ CEK ABSEN LOCAL (OFFLINE)
    // ===============================
    // final localDataAbs = await SQLHelper.instance.getAbsenToday(
    //   dataUser.id!,
    //   todayDate,
    // );

    // if (localDataAbs.isNotEmpty) {
    //   // _resetForm();
    //   succesDialog(
    //     context: Get.context!,
    //     pageAbsen: "N",
    //     desc: "You have checked in today",
    //     type: DialogType.info,
    //     title: 'INFO',
    //     btnOkOnPress: () => Get.back(),
    //   );
    //   return;
    // }

    // ===============================
    // 6️⃣ SET JAM MASUK / PULANG
    // ===============================

    // absC.jamMasuk.value = timeNow;
    String jamMasuk = absC.jamMasuk.value;
    String jamPulang = absC.jamPulang.value;
    if (selectedShift == "5") {
      // absC.jamPulang.value = DateFormat(
      //   "HH:mm",
      // ).format(nowLocal.add(const Duration(hours: 8)));
      final nowPlus8 = nowLocal.add(const Duration(hours: 8));
      jamMasuk = DateFormat("HH:mm").format(nowLocal);
      jamPulang = DateFormat("HH:mm").format(nowPlus8);

      // absC.jamMasuk.value = jamMasuk;
      // absC.jamPulang.value = jamPulang;
    }
    loadingDialog("Sending data...", ""); // loading

    // ===============================
    // 7️⃣ DATA ABSEN
    // ===============================
    // final data = {
    //   "status": "add",
    //   "id": dataUser.id,
    //   "tanggal_masuk": todayDate,
    //   "kode_cabang": selectedCabang,
    //   "nama": dataUser.nama,
    //   "id_shift": selectedShift,
    //   "jam_masuk": jamMasuk,
    //   "jam_pulang": jamPulang,
    //   "jam_absen_masuk": timeNow,
    //   "foto_masuk": File(imagePath),
    //   "lat_masuk": latitude.toString(),
    //   "long_masuk": longitude.toString(),
    //   "device_info": deviceInfo,
    // };

    // ===============================
    // 8️⃣ SIMPAN LOCAL
    // ===============================
    final res = await SQLHelper.instance.insertDataAbsen(
      Absen(
        idUser: dataUser.id,
        tanggalMasuk: todayDate,
        kodeCabang: selectedCabang,
        nama: dataUser.nama,
        idShift: selectedShift,
        jamMasuk: jamMasuk,
        jamPulang: jamPulang,
        jamAbsenMasuk: timeNow,
        jamAbsenPulang: '',
        fotoMasuk: imagePath,
        latMasuk: latitude.toString(),
        longMasuk: longitude.toString(),
        fotoPulang: '',
        latPulang: '',
        longPulang: '',
        devInfo: deviceInfo,
        devInfo2: '',
        statusSync: "PENDING",
      ),
    );
    Get.back(); // tutup loading
    if (res.success) {
      // ===============================
      // 9️⃣ KIRIM KE SERVER
      // ===============================
      /// 🔥 LANGSUNG SYNC
      absC.triggerSync(isVisit: false);
      // await ServiceApi().submitAbsen(data, false);

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
    } else {
      showToast(res.message);
    }
    // ===============================
    // 🔥 10. KIRIM KE XMOR
    // ===============================
    absC.sendDataToXmor(
      dataUser.id!,
      "clock_in",
      DateFormat('yyyy-MM-dd HH:mm:ss').format(nowLocal),
      selectedShift,
      latitude.toString(),
      longitude.toString(),
      absC.lokasi.value,
      dataUser.namaCabang!,
      dataUser.kodeCabang!,
      deviceInfo,
    );

    // ===============================
    // 🔁 REFRESH UI
    // ===============================
    absC.getAbsenToday({
      "mode": "single",
      "id_user": dataUser.id,
      "tanggal_masuk": todayDate,
    });

    absC.getLimitAbsen({
      "mode": "limit",
      "id_user": dataUser.id,
      "tanggal1": absC.initDate1,
      "tanggal2": absC.initDate2,
    });

    homeC.getSummAttPerMonth(dataUser.id!);
    // absC.startTimer(10);
    // absC.resend();
  } catch (e) {
    failedDialog(Get.context, "Error", e.toString());
  } finally {
    _resetForm();
    absC.isLoading.value = false;
  }
}

void _resetForm() {
  absC.stsAbsenSelected.value = "";
  absC.selectedShift.value = "";
  absC.selectedCabang.value = "";
  absC.lat.value = "";
  absC.long.value = "";
}
