import 'dart:io';
import 'package:absensi/app/data/helper/time_service.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/model/absen_model.dart';
import '../../../../data/model/login_model.dart';
import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final homeC = Get.find<HomeController>();

checkIn(Data dataUser, double latitude, double longitude) async {
   // ===============================
  // 2️⃣ SNAPSHOT WAKTU SERVER
  // ===============================
  final DateTime? nowLocal = await getServerTimeLocal();
  final todayDate = DateFormat('yyyy-MM-dd').format(nowLocal!);
  final timeNow = DateFormat('HH:mm').format(nowLocal);

  // ===============================
  // 3️⃣ CEK ABSEN HARI INI (SERVER)
  // ===============================
  await absC.cekDataAbsen("masuk", dataUser.id!, todayDate);

  if (absC.cekAbsen.value.total != "0") {
    _resetForm();
    Get.back();
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

  // ===============================
  // 4️⃣ FOTO WAJIB
  // ===============================
  await absC.uploadFotoAbsen();
  Get.back();

  if (absC.image == null) {
    _resetForm();
    failedDialog(Get.context, "Warning", "Check in was cancelled");
    return;
  }

  // ===============================
  // 5️⃣ CEK ABSEN LOCAL (OFFLINE)
  // ===============================
  final localDataAbs = await SQLHelper.instance.getAbsenToday(
    dataUser.id!,
    todayDate,
  );

  if (localDataAbs.isNotEmpty) {
    _resetForm();
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

  // ===============================
  // 6️⃣ SET JAM MASUK / PULANG
  // ===============================
  loadingDialog("Sending data...", "");

  // absC.jamMasuk.value = timeNow;

  if (absC.selectedShift.value == "5") {
    absC.jamPulang.value = DateFormat(
      "HH:mm",
    ).format(nowLocal.add(const Duration(hours: 8)));
  }

  // ===============================
  // 7️⃣ DATA ABSEN
  // ===============================
  final data = {
    "status": "add",
    "id": dataUser.id,
    "tanggal_masuk": todayDate,
    "kode_cabang":
        absC.selectedCabang.isNotEmpty
            ? absC.selectedCabang.value
            : dataUser.kodeCabang,
    "nama": dataUser.nama,
    "id_shift": absC.selectedShift.value,
    "jam_masuk": absC.jamMasuk.value,
    "jam_pulang": absC.jamPulang.value,
    "jam_absen_masuk": timeNow,
    "foto_masuk": File(absC.image!.path),
    "lat_masuk": latitude.toString(),
    "long_masuk": longitude.toString(),
    "device_info": absC.devInfo.value,
  };

  // ===============================
  // 8️⃣ SIMPAN LOCAL
  // ===============================
  await SQLHelper.instance.insertDataAbsen(
    Absen(
      idUser: dataUser.id,
      tanggalMasuk: todayDate,
      kodeCabang:
          absC.selectedCabang.isNotEmpty
              ? absC.selectedCabang.value
              : dataUser.kodeCabang,
      nama: dataUser.nama,
      idShift: absC.selectedShift.value,
      jamMasuk: absC.jamMasuk.value,
      jamPulang: absC.jamPulang.value,
      jamAbsenMasuk: timeNow,
      jamAbsenPulang: '',
      fotoMasuk: absC.image!.path,
      latMasuk: latitude.toString(),
      longMasuk: longitude.toString(),
      fotoPulang: '',
      latPulang: '',
      longPulang: '',
      devInfo: absC.devInfo.value,
      devInfo2: '',
    ),
  );

  // ===============================
  // 9️⃣ KIRIM KE SERVER
  // ===============================
  await ServiceApi().submitAbsen(data, false);

  absC.sendDataToXmor(
    dataUser.id!,
    "clock_in",
    DateFormat('yyyy-MM-dd HH:mm:ss').format(nowLocal),
    absC.selectedShift.value,
    latitude.toString(),
    longitude.toString(),
    absC.lokasi.value,
    dataUser.namaCabang!,
    dataUser.kodeCabang!,
    absC.devInfo.value,
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

  homeC.reloadSummary(dataUser.id!);
  absC.startTimer(10);
  absC.resend();

  _resetForm();
}

void _resetForm() {
  absC.stsAbsenSelected.value = "";
  absC.selectedShift.value = "";
  absC.selectedCabang.value = "";
  absC.lat.value = "";
  absC.long.value = "";
}
