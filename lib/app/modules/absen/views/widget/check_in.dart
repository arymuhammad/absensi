import 'dart:io';

import 'package:absensi/app/data/add_controller.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/model/absen_model.dart';
import '../../../../data/model/login_model.dart';
import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final adC = Get.put(AdController());
checkIn(Data dataUser, double latitude, double longitude) async {
  await absC.cekDataAbsen(
    "masuk",
    dataUser.id!,
    DateFormat('yyyy-MM-dd').format(
      DateTime.parse(
        absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
      ),
    ),
  );

  if (absC.cekAbsen.value.total == "0") {
    // await Get.to(() => const FaceDetection());
    await absC.uploadFotoAbsen();
    Get.back();

    if (absC.image != null) {
     
      // CEK ABSEN MASUK HARI INI, JIKA HASIL = 0, ABSEN MASUK

      var localDataAbs = await SQLHelper.instance.getAbsenToday(
        dataUser.id!,
        absC.dateNow,
      );
      if (localDataAbs.isEmpty) {
        loadingDialog("Sending data...", "");
        await absC.timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
        var data = {
          "status": "add",
          "id": dataUser.id,
          "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "kode_cabang":
              absC.selectedCabang.isNotEmpty
                  ? absC.selectedCabang.value
                  : dataUser.kodeCabang,
          "nama": dataUser.nama,
          "id_shift": absC.selectedShift.value,
          "jam_masuk": absC.jamMasuk.value,
          "jam_pulang": absC.jamPulang.value,
          "jam_absen_masuk":
              absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              // absC.timeNowOpt,
          "foto_masuk": File(absC.image!.path),
          "lat_masuk": latitude.toString(),
          "long_masuk": longitude.toString(),
          "device_info": absC.devInfo.value,
        };

        //submit data absensi ke local storage
        SQLHelper.instance.insertDataAbsen(
          Absen(
            idUser: dataUser.id,
            tanggalMasuk: DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            kodeCabang:
                absC.selectedCabang.isNotEmpty
                    ? absC.selectedCabang.value
                    : dataUser.kodeCabang,
            nama: dataUser.nama,
            idShift: absC.selectedShift.value,
            jamMasuk: absC.jamMasuk.value,
            jamPulang: absC.jamPulang.value,
            jamAbsenMasuk:
                absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
                // absC.timeNowOpt,
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
        // offline first
        // submit data absensi ke server
        await ServiceApi().submitAbsen(data, false);

        // adC.loadInterstitialAd();
        adC.showInterstitialAd(() {});

        absC.sendDataToXmor(
          dataUser.id!,
          "clock_in",
          DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.parse(absC.dateNowServer)),
          absC.selectedShift.value,
          latitude.toString(),
          longitude.toString(),
          absC.lokasi.value,
          dataUser.namaCabang!,
          dataUser.kodeCabang!,
          absC.devInfo.value,
        );

        var paramAbsenToday = {
          "mode": "single",
          "id_user": dataUser.id,
          "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
        };

        var paramLimitAbsen = {
          "mode": "limit",
          "id_user": dataUser.id,
          "tanggal1": absC.initDate1,
          "tanggal2": absC.initDate2,
        };
        absC.getAbsenToday(paramAbsenToday);
        absC.getLimitAbsen(paramLimitAbsen);
        absC.startTimer(10);
        absC.resend();
        absC.stsAbsenSelected.value = "";
        absC.selectedShift.value = "";
        absC.selectedCabang.value = "";
        absC.lat.value = "";
        absC.long.value = "";
      } else {
        absC.stsAbsenSelected.value = "";
        absC.selectedShift.value = "";
        absC.selectedCabang.value = "";
        absC.lat.value = "";
        absC.long.value = "";
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
      // }
    } else {
      absC.stsAbsenSelected.value = "";
      absC.selectedShift.value = "";
      absC.selectedCabang.value = "";
      absC.lat.value = "";
      absC.long.value = "";
      Get.back();
      failedDialog(Get.context, "Warning", "Check in was cancelled");
    }
  } else {
    absC.stsAbsenSelected.value = "";
    absC.selectedShift.value = "";
    absC.selectedCabang.value = "";
    absC.lat.value = "";
    absC.long.value = "";
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
