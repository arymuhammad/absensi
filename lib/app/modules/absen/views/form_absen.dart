import 'dart:convert';
import 'dart:io';

import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/helper/db_helper.dart';
import '../../../data/helper/loading_dialog.dart';
import '../../../data/model/absen_model.dart';
import '../../../services/service_api.dart';
import '../../shared/dropdown_cabang.dart';
import '../../shared/dropdown_shift_kerja.dart';

final absC = Get.find<AbsenController>();
formAbsen(Data dataUser, double latitude, double longitude) async {
  // JIKA POSISI DALAM JANGKAUAN/AREA ABSEN, PROSES ABSEN BERLANJUT

  SharedPreferences pref = await SharedPreferences.getInstance();
  AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.info,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'INFO',
          body: Column(
            children: [
              // Text(absC.msg.value),
              const SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Pilih Absen Masuk / Pulang')),
                  value: absC.stsAbsenSelected.isEmpty
                      ? null
                      : absC.stsAbsenSelected.value,
                  items: absC.stsAbsen
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (val) {
                    absC.stsAbsenSelected.value = val!;
                  }),
              const SizedBox(height: 5),
              CsDropdownCabang(
                hintText: dataUser.namaCabang,
                value: absC.selectedCabang.value == ""
                    ? null
                    : absC.selectedCabang.value,
              ),
              const SizedBox(height: 5),
              Obx(
                () => Visibility(
                  visible:
                      absC.stsAbsenSelected.value != "Pulang" ? true : false,
                  child: CsDropdownShiftKerja(
                      value: absC.selectedShift.value == ""
                          ? null
                          : absC.selectedShift.value),
                ),
              )
            ],
          ),
          btnCancelOnPress: () {
            absC.stsAbsenSelected.value = "";
            absC.selectedShift.value = "";
            absC.selectedCabang.value = "";
            absC.lat.value = "";
            absC.long.value = "";
            auth.selectedMenu(0);
          },
          btnOkOnPress: () async {
            // log(absC.stsAbsenSelected.value, name: 'SHIFT');
            if (absC.stsAbsenSelected.isEmpty) {
              showToast("Harap pilih Absen Masuk / Pulang");
            } else if (absC.stsAbsenSelected.value == "Masuk" &&
                    absC.selectedShift.isEmpty ||
                absC.stsAbsenSelected.isEmpty && absC.selectedShift.isEmpty) {
              absC.stsAbsenSelected.value == "";
              showToast("Harap pilih Shift Absen");
            } else {
              double distance = Geolocator.distanceBetween(
                  double.parse(
                      absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!),
                  double.parse(
                      absC.long.isNotEmpty ? absC.long.value : dataUser.long!),
                  latitude,
                  longitude);
              await pref.setStringList('userLoc', <String>[
                absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!,
                absC.long.isNotEmpty ? absC.long.value : dataUser.long!
              ]);

              absC.distanceStore.value = distance;
              // CEK POSISI USER SAAT HENDAK ABSEN
              if (absC.distanceStore.value > num.parse(dataUser.areaCover!)) {
                //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                Get.back();
                dialogMsgCncl('Terjadi Kesalahan',
                    'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');
                absC.selectedShift.value = "";
                absC.selectedCabang.value = "";
                absC.stsAbsenSelected.value = "";
                absC.lat.value = "";
                absC.long.value = "";
              } else {
                if (absC.stsAbsenSelected.value == "Masuk") {
                  await absC.cekDataAbsen(
                      "masuk",
                      dataUser.id!,
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(
                          absC.dateNowServer.isNotEmpty
                              ? absC.dateNowServer
                              : absC.dateNow)));

                  if (absC.cekAbsen.value.total == "0") {
                    await absC.uploadFotoAbsen();
                    Get.back();
                   
                    if (absC.image != null) {
                      // CEK ABSEN MASUK HARI INI, JIKA HASIL = 0, ABSEN MASUK

                      var localDataAbs = await SQLHelper.instance
                          .getAbsenToday(dataUser.id!, absC.dateNow);
                      if (localDataAbs.isEmpty) {
                        loadingDialog("Sedang mengirim data...", "");
                        var data = {
                          "status": "add",
                          "id": dataUser.id,
                          "tanggal_masuk": DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(absC.dateNowServer)),
                          "kode_cabang": absC.selectedCabang.isNotEmpty
                              ? absC.selectedCabang.value
                              : dataUser.kodeCabang,
                          "nama": dataUser.nama,
                          "id_shift": absC.selectedShift.value,
                          "jam_masuk": absC.jamMasuk.value,
                          "jam_pulang": absC.jamPulang.value,
                          "jam_absen_masuk": absC.timeNow.toString(),
                          "foto_masuk": base64
                              .encode(File(absC.image!.path).readAsBytesSync()),
                          "foto_pulang": "",
                          "lat_masuk": latitude.toString(),
                          "long_masuk": longitude.toString(),
                          "device_info": absC.devInfo.value
                        };

                        
                        //submit data absensi ke local storage
                        SQLHelper.instance.insertDataAbsen(Absen(
                            idUser: dataUser.id,
                            tanggalMasuk: DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            kodeCabang: absC.selectedCabang.isNotEmpty
                                ? absC.selectedCabang.value
                                : dataUser.kodeCabang,
                            nama: dataUser.nama,
                            idShift: absC.selectedShift.value,
                            jamMasuk: absC.jamMasuk.value,
                            jamPulang: absC.jamPulang.value,
                            jamAbsenMasuk: absC.timeNow.toString(),
                            jamAbsenPulang: '',
                            fotoMasuk: base64.encode(
                                File(absC.image!.path).readAsBytesSync()),
                            latMasuk: latitude.toString(),
                            longMasuk: longitude.toString(),
                            fotoPulang: '',
                            latPulang: '',
                            longPulang: '',
                            devInfo: absC.devInfo.value,
                            devInfo2: ''));
                        // offline first
                        // submit data absensi ke server
                        await ServiceApi().submitAbsen(data, false);

                        absC.sendDataToXmor(
                            dataUser.id!,
                            "clock_in",
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.parse(absC.dateNowServer)),
                            absC.selectedShift.value,
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
                        absC.startTimer(10);
                        absC.resend();
                        absC.stsAbsenSelected.value = "";
                        absC.selectedShift.value = "";
                        absC.selectedCabang.value = "";
                        absC.lat.value = "";
                        absC.long.value = "";
                      }
                    } else {
                 
                      absC.stsAbsenSelected.value = "";
                      absC.selectedShift.value = "";
                      absC.selectedCabang.value = "";
                      absC.lat.value = "";
                      absC.long.value = "";
                      Get.back();
                      failedDialog(
                          Get.context, "Peringatan", "Absen Masuk dibatalkan");
                    }
                  } else {
                   
                    absC.stsAbsenSelected.value = "";
                    absC.selectedShift.value = "";
                    absC.selectedCabang.value = "";
                    absC.lat.value = "";
                    absC.long.value = "";
                    succesDialog(
                        Get.context, "Y", "Anda sudah Absen Masuk hari ini.");
                  }
                } else {
                  //absen pulang

                  double distance = Geolocator.distanceBetween(
                      double.parse(
                          absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!),
                      double.parse(absC.long.isNotEmpty
                          ? absC.long.value
                          : dataUser.long!),
                      latitude,
                      longitude);
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
                    await absC.cekDataAbsen(
                        "masuk",
                        dataUser.id!,
                        DateFormat('yyyy-MM-dd').format(DateTime.parse(
                            absC.dateNowServer.isNotEmpty
                                ? absC.dateNowServer
                                : absC.dateNow)));
                    // log(absC.cekAbsen.value.total.toString(), name: 'MASUK');
                    if (absC.cekAbsen.value.total == "0") {
                      absC.stsAbsenSelected.value = "";
                      absC.selectedShift.value = "";
                      absC.selectedCabang.value = "";
                      absC.lat.value = "";
                      absC.long.value = "";
                      Get.back();
                      failedDialog(Get.context, "Peringatan",
                          "Data absen masuk tidak ditemukan\nHarap absen masuk terlebih dahulu");
                    } else {
                      await absC.cekDataAbsen(
                          "pulang",
                          dataUser.id!,
                          DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(absC.dateNowServer)));
// log(absC.cekAbsen.value.total.toString(), name: 'PULANG');
                      if (absC.cekAbsen.value.total == "1") {
                        await absC.uploadFotoAbsen();
                        Get.back();
                        if (absC.image != null) {
                          var localDataAbs = await SQLHelper.instance
                              .getAbsenToday(dataUser.id!, absC.dateNow);
                          // log(localDataAbs[0].tanggalMasuk!, name: 'MASUK');
                          if (localDataAbs.isEmpty) {
                            loadingDialog("Mengirim data...", "");
                            var data = {
                              "status": "update",
                              "id": dataUser.id,
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              "nama": dataUser.nama,
                              "jam_absen_pulang": absC.timeNow.toString(),
                              "foto_pulang": base64.encode(
                                  File(absC.image!.path).readAsBytesSync()),
                              "lat_pulang": latitude.toString(),
                              "long_pulang": longitude.toString(),
                              "device_info2": absC.devInfo.value
                            };
                            await ServiceApi().submitAbsen(data, false);
                            // send data to xmor
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
                            // absC.startTimer(30);
                            // absC.resend();
                            absC.stsAbsenSelected.value = "";
                            absC.selectedShift.value = "";
                            absC.selectedCabang.value = "";
                            absC.lat.value = "";
                            absC.long.value = "";
                          } else if (localDataAbs.isNotEmpty &&
                              localDataAbs[0].tanggalPulang == null) {
                            loadingDialog("Mengirim data...", "");
                            var data = {
                              "status": "update",
                              "id": dataUser.id,
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              "nama": dataUser.nama,
                              "jam_absen_pulang": absC.timeNow.toString(),
                              "foto_pulang": base64.encode(
                                  File(absC.image!.path).readAsBytesSync()),
                              "lat_pulang": latitude.toString(),
                              "long_pulang": longitude.toString(),
                              "device_info2": absC.devInfo.value
                            };
                            
                            // update data absensi ke local storage
                            SQLHelper.instance.updateDataAbsen(
                                {
                                  "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                      .format(
                                          DateTime.parse(absC.dateNowServer)),
                                  "nama": dataUser.nama,
                                  "jam_absen_pulang": absC.timeNow.toString(),
                                  "foto_pulang": base64.encode(
                                      File(absC.image!.path).readAsBytesSync()),
                                  "lat_pulang": latitude.toString(),
                                  "long_pulang": longitude.toString(),
                                  "device_info2": absC.devInfo.value
                                },
                                dataUser.id!,
                                DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(absC.dateNowServer)));

                            // update data absensi ke server
                            await ServiceApi().submitAbsen(data, false);
                          

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
                            succesDialog(Get.context, "Y",
                                "Anda sudah Absen Pulang hari ini.");
                          }
                        } else {
                          absC.stsAbsenSelected.value = "";
                          absC.selectedShift.value = "";
                          absC.selectedCabang.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Pulang dibatalkan");
                        }
                      } else {
                        absC.stsAbsenSelected.value = "";
                        absC.selectedShift.value = "";
                        absC.selectedCabang.value = "";
                        absC.lat.value = "";
                        absC.long.value = "";
                        succesDialog(Get.context, "Y",
                            "Anda sudah Absen Pulang hari ini.");
                      }
                    }
                  }
                }
              }
            }
          },
          btnCancelText: 'Batal',
          btnCancelColor: Colors.redAccent[700],
          btnCancelIcon: Icons.cancel,
          btnOkText: 'Foto',
          btnOkColor: Colors.blueAccent[700],
          btnOkIcon: Icons.camera_front_outlined)
      .show();
}
