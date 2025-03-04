import 'dart:io';

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';

import 'package:absensi/app/modules/absen/views/form_absen.dart';
import 'package:absensi/app/modules/absen/views/visit.dart';
import 'package:absensi/app/modules/shared/dropdown_cabang.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/login_model.dart';

final absC = Get.put(AbsenController());

dialogAbsenView(Data dataUser, latitude, longitude) async {
  if (dataUser.visit == "1") {
    //visit
    visit(dataUser, latitude, longitude);
  } else {
    //absen
    var previous = DateFormat('yyyy-MM-dd').format(DateTime.parse(
            absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow)
        .add(const Duration(days: -1)));
    // Get the current time
    DateTime now = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    // Set the target time to 7:00 AM
    TimeOfDay targetTime = const TimeOfDay(hour: 09, minute: 01);

    // Convert TimeOfDay to DateTime for proper comparison
    DateTime currentDateTime = DateTime(
        now.year, now.month, now.day, currentTime.hour, currentTime.minute);
    DateTime targetDateTime = DateTime(
        now.year, now.month, now.day, targetTime.hour, targetTime.minute);

    // Compare the current time with the target time
    bool isBefore9AM = currentDateTime.isBefore(targetDateTime);
    // print(isBefore9AM);

    // if (isBefore9AM) {
    if (isBefore9AM) {
      await absC.cekDataAbsen("pulang", dataUser.id!, previous);
      if (absC.cekAbsen.value.total == "1" && absC.cekAbsen.value.idShift != "0") {
        // CEK ABSEN PULANG DITANGGAL H+1
        AwesomeDialog(
                context: Get.context!,
                dialogType: DialogType.info,
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                headerAnimationLoop: false,
                animType: AnimType.bottomSlide,
                title: 'INFO',
                desc: "Absen pulang hari ini?",
                body: Column(children: [
                  Text(
                      'Absen pulang hari ini?\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi'),
                  CsDropdownCabang(
                    hintText: dataUser.namaCabang,
                    value: absC.selectedCabang.value == ""
                        ? null
                        : absC.selectedCabang.value,
                  ),
                ]),
                btnCancelOnPress: () {
                  absC.selectedCabang.value = "";
                  absC.lat.value = "";
                  absC.long.value = "";
                  auth.selectedMenu(0);
                  showToast("Absen pulang dibatalkan");
                },
                btnOkOnPress: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  double distance = Geolocator.distanceBetween(
                      double.parse(
                          absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!),
                      double.parse(absC.long.isNotEmpty
                          ? absC.long.value
                          : dataUser.long!),
                      latitude.toDouble(),
                      longitude.toDouble());
                  await pref.setStringList('userLoc', <String>[
                    absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!,
                    absC.long.isNotEmpty ? absC.long.value : dataUser.long!
                  ]);

                  absC.distanceStore.value = distance;
                  // CEK POSISI USER SAAT HENDAK ABSEN
                  if (absC.distanceStore.value >
                      num.parse(dataUser.areaCover!)) {
                    //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                    Get.back();
                    dialogMsgCncl('Terjadi Kesalahan',
                        'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                    absC.selectedCabang.value = "";
                    absC.lat.value = "";
                    absC.long.value = "";
                  } else {
                    // face detection
                    // await Get.to(() => const FaceDetection());
                    await absC.uploadFotoAbsen();
                    Get.back();

                    if (absC.image != null) {
                      var data = {
                        "status": "update",
                        "id": dataUser.id,
                        "tanggal_masuk": previous,
                        "tanggal_pulang": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer)),
                        "nama": dataUser.nama,
                        "jam_absen_pulang": absC.timeNow.toString(),
                        "foto_pulang":  File(absC.image!.path),
                        "lat_pulang": latitude.toString(),
                        "long_pulang": longitude.toString(),
                        "device_info2": absC.devInfo.value
                      };

                      SQLHelper.instance.updateDataAbsen({
                        "tanggal_pulang": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer)),
                        "nama": dataUser.nama,
                        "jam_absen_pulang": absC.timeNow.toString(),
                        "foto_pulang": absC.image!.path,
                        "lat_pulang": latitude.toString(),
                        "long_pulang": longitude.toString(),
                        "device_info2": absC.devInfo.value
                      }, dataUser.id!, previous);
                      await ServiceApi().submitAbsen(data, false);

                      // send data absen to xmor
                      absC.sendDataToXmor(
                          dataUser.id!,
                          "clock_out",
                          DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(DateTime.parse(absC.dateNowServer)),
                          absC.cekAbsen.value.idShift!,
                          latitude.toString(),
                          longitude.toString(),
                          absC.lokasi.value,
                          dataUser.namaCabang!,
                          dataUser.kodeCabang!,
                          absC.devInfo.value);

                      var paramAbsenToday = {
                        "mode": "single",
                        "id_user": dataUser.id,
                        "tanggal_masuk": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer))
                      };

                      var paramLimitAbsen = {
                        "mode": "limit",
                        "id_user": dataUser.id,
                        "tanggal1": absC.initDate1,
                        "tanggal2": absC.initDate2
                      };
                      absC.getAbsenToday(paramAbsenToday);
                      absC.getLimitAbsen(paramLimitAbsen);
                      absC.selectedCabang.value = "";
                      absC.lat.value = "";
                      absC.long.value = "";
                    } else {
                      Get.back();
                      failedDialog(
                          Get.context, "Peringatan", "Absen Pulang dibatalkan");
                    }
                  }
                },
                btnCancelText: 'Batalkan',
                btnCancelColor: Colors.redAccent[700],
                btnCancelIcon: Icons.cancel,
                btnOkText: 'Foto',
                btnOkColor: Colors.blueAccent[700],
                btnOkIcon: Icons.camera_front)
            .show();
      } else {
        // succesDialog(Get.context, "Y", "Anda sudah absen pulang sebelum nya.");
        formAbsen(dataUser, latitude, longitude);
      }
      // JIKA TIDAK ADA ABSEN PULANG MENGGANTUNG, LANJUT KE TAHAP SELANJUTNYA
    } else {
      // JIKA POSISI DALAM JANGKAUAN/AREA ABSEN, PROSES ABSEN BERLANJUT
      formAbsen(dataUser, latitude, longitude);
    }
  }
}
