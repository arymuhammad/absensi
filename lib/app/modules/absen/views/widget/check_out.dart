import 'dart:io';

import 'package:absensi/app/data/add_controller.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final adC = Get.put(AdController());
checkOut(Data dataUser, double latitude, double longitude) async {
  //absen pulang

  // double distance = Geolocator.distanceBetween(
  //   double.parse(absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!),
  //   double.parse(absC.long.isNotEmpty ? absC.long.value : dataUser.long!),
  //   latitude,
  //   longitude,
  // );
  // await pref.setStringList('userLoc', <String>[
  //   absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!,
  //   absC.long.isNotEmpty ? absC.long.value : dataUser.long!,
  // ]);

  // absC.distanceStore.value = distance;
  // CEK POSISI USER SAAT HENDAK ABSEN
  // if (absC.distanceStore.value > num.parse(dataUser.areaCover!)) {
  //   //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
  //   Get.back();
  //   dialogMsgCncl(
  //     'Terjadi Kesalahan',
  //     'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi',
  //   );

  //   absC.selectedCabang.value = "";
  //   absC.lat.value = "";
  //   absC.long.value = "";
  // } else {
  await absC.cekDataAbsen(
    "masuk",
    dataUser.id!,
    DateFormat('yyyy-MM-dd').format(
      DateTime.parse(
        absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
      ),
    ),
  );
  // log(absC.cekAbsen.value.total.toString(), name: 'MASUK');
  if (absC.cekAbsen.value.total == "0") {
    absC.stsAbsenSelected.value = "";
    absC.selectedShift.value = "";
    absC.selectedCabang.value = "";
    absC.lat.value = "";
    absC.long.value = "";
    Get.back();
    failedDialog(
      Get.context,
      "Peringatan",
      "Data absen masuk tidak ditemukan\nHarap absen masuk terlebih dahulu",
    );
  } else {
    // await absC.cekDataAbsen(
    //     "pulang",
    //     dataUser.id!,
    //     DateFormat('yyyy-MM-dd')
    //         .format(DateTime.parse(absC.dateNowServer)));

    // OLD STATEMENT (CHECKING DATA CHECKOUT, IF CHECKOUT == 1, THEN CONTINUE CAPTURE IMG)
    // if (absC.cekAbsen.value.total == "1") {
    // face detectionhr
    //  await Get.to(() => const FaceDetection());

    await absC.uploadFotoAbsen();
    Get.back();

    if (absC.image != null) {
      // loadingDialog("Memproses data wajah", "");
      // await absC.matchFaces(dataUser.id!);
      // Get.back();
      // if (absC.similarityStatus.value == "failed") {
      //   failedDialog(
      //       Get.context!, 'ERROR', 'Wajah tidak dikenali');
      // } else {
      var localDataAbs = await SQLHelper.instance.getAbsenToday(
        dataUser.id!,
        absC.dateNow,
      );

      if (localDataAbs.isEmpty) {
        loadingDialog("Sending data...", "");
        absC.timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
        var data = {
          "status": "update",
          "id": dataUser.id,
          "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "nama": dataUser.nama,
          "jam_absen_pulang":
              // absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              absC.timeNowOpt,
          "foto_pulang": File(absC.image!.path),
          "lat_pulang": latitude.toString(),
          "long_pulang": longitude.toString(),
          "device_info2": absC.devInfo.value,
        };

        await ServiceApi().submitAbsen(data, false);
        adC.loadInterstitialAd();
        adC.showInterstitialAd(() {});
        // send data to xmor
        absC.sendDataToXmor(
          dataUser.id!,
          "clock_out",
          DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.parse(absC.dateNowServer)),
          absC.cekAbsen.value.idShift!,
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
        // absC.startTimer(30);
        // absC.resend();
        absC.stsAbsenSelected.value = "";
        absC.selectedShift.value = "";
        absC.selectedCabang.value = "";
        absC.lat.value = "";
        absC.long.value = "";
      } else if (localDataAbs.isNotEmpty) {
        // OLD STATEMENT
        // && localDataAbs[0].tanggalPulang == null

        loadingDialog("Sending data...", "");
        absC.timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
        var data = {
          "status": "update",
          "id": dataUser.id,
          "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "nama": dataUser.nama,
          "jam_absen_pulang":
              // absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              absC.timeNowOpt,
          "foto_pulang": File(absC.image!.path),
          "lat_pulang": latitude.toString(),
          "long_pulang": longitude.toString(),
          "device_info2": absC.devInfo.value,
        };

        // update data absensi ke local storage
        SQLHelper.instance.updateDataAbsen(
          {
            "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "nama": dataUser.nama,
            "jam_absen_pulang":
                // absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
               absC.timeNowOpt,
            "foto_pulang": absC.image!.path,
            "lat_pulang": latitude.toString(),
            "long_pulang": longitude.toString(),
            "device_info2": absC.devInfo.value,
          },
          dataUser.id!,
          DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
        );

        // update data absensi ke server
        await ServiceApi().submitAbsen(data, false);
        // adC.loadInterstitialAd();
        adC.showInterstitialAd(() {});
        absC.sendDataToXmor(
          dataUser.id!,
          "clock_out",
          DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.parse(absC.dateNowServer)),
          absC.cekAbsen.value.idShift!,
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
      }
      // OLD ELSE STATEMENT
      //  else {
      //   absC.stsAbsenSelected.value = "";
      //   absC.selectedShift.value = "";
      //   absC.selectedCabang.value = "";
      //   absC.lat.value = "";
      //   absC.long.value = "";
      //   succesDialog(
      //       Get.context,
      //       "Y",
      //       "Anda sudah Absen Pulang hari ini.",
      //       DialogType.info,
      //       'INFO');
      // }
      // }
    } else {
      absC.stsAbsenSelected.value = "";
      absC.selectedShift.value = "";
      absC.selectedCabang.value = "";
      absC.lat.value = "";
      absC.long.value = "";
      Get.back();
      failedDialog(Get.context, "Peringatan", "Absen Pulang dibatalkan");
    }

    // OLD STATEMENT CHECKING DATA CHECKOUT IF CHECKOUT == 0 (TIDAK ADA DATA ABSEN PULANG KOSONG)
    // } else {
    //   absC.stsAbsenSelected.value = "";
    //   absC.selectedShift.value = "";
    //   absC.selectedCabang.value = "";
    //   absC.lat.value = "";
    //   absC.long.value = "";
    //   succesDialog(
    //       Get.context,
    //       "Y",
    //       "Anda sudah Absen Pulang hari ini.",
    //       DialogType.info,
    //       'INFO');
    // }
  }
  // }
}
