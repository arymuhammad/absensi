import 'dart:developer';
import 'dart:io';

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/modules/absen/views/visit.dart';
import 'package:absensi/app/modules/shared/dropdown_cabang.dart';
import 'package:absensi/app/modules/shared/dropdown_shift_kerja.dart';
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
    TimeOfDay targetTime = const TimeOfDay(hour: 07, minute: 01);

    // Convert TimeOfDay to DateTime for proper comparison
    DateTime currentDateTime = DateTime(
        now.year, now.month, now.day, currentTime.hour, currentTime.minute);
    DateTime targetDateTime = DateTime(
        now.year, now.month, now.day, targetTime.hour, targetTime.minute);

    // Compare the current time with the target time
    bool isBefore7AM = currentDateTime.isBefore(targetDateTime);
    // print(isBefore7AM);

    if (isBefore7AM) {
      await absC.cekDataAbsen("pulang", dataUser.id!, previous);
      if (absC.cekAbsen.value.total == "0") {
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
                        "foto_pulang": File(absC.image!.path.toString()),
                        "lat_pulang": latitude.toString(),
                        "long_pulang": longitude.toString(),
                        "device_info2": absC.devInfo.value
                      };

                      loadingDialog("Sedang mengirim data...", "");
                      SQLHelper.instance.updateDataAbsen({
                        "tanggal_pulang": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer)),
                        "nama": dataUser.nama,
                        "jam_absen_pulang": absC.timeNow.toString(),
                        "foto_pulang": absC.image!.path.toString(),
                        "lat_pulang": latitude.toString(),
                        "long_pulang": longitude.toString(),
                        "device_info2": absC.devInfo.value
                      }, dataUser.id!, previous);
                      ServiceApi().submitAbsen(data, false);

                      // send data absen to xmor
                      absC.sendDataToXmor(
                          dataUser.id!,
                          "clock_out",
                          DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(DateTime.parse(absC.dateNowServer)),
                          pref.getString("stateShiftAbsen") ?? '',
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
        succesDialog(Get.context, "Y", "Anda sudah absen pulang sebelum nya.");
      }
      // JIKA TIDAK ADA ABSEN PULANG MENGGANTUNG, LANJUT KE TAHAP SELANJUTNYA
    } else {
      // JIKA POSISI DALAM JANGKAUAN/AREA ABSEN, PROSES ABSEN BERLANJUT

      SharedPreferences pref = await SharedPreferences.getInstance();
      var statAbs = pref.getString("stateStatusAbsen") ?? '';
      var statShiftAbs = pref.getString("stateShiftAbsen") ?? '';

      log(statAbs, name: 'STATUS ABSEN');
      // await absC.cekDataAbsen(
      //     "masuk",
      //     dataUser.id!,
      //     DateFormat('yyyy-MM-dd').format(DateTime.parse(
      //         absC.dateNowServer.isNotEmpty
      //             ? absC.dateNowServer
      //             : absC.dateNow)));

      // // CEK ABSEN MASUK TODAY, JIKA HASIL = 0, ABSEN MASUK
      // if (absC.cekAbsen.value.total == "0") {
      //   var localDataAbs =
      //       await SQLHelper.instance.getAbsenToday(dataUser.id!, absC.dateNow);
      //   if (localDataAbs.isEmpty) {
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
                  Text(absC.msg.value),
                  const SizedBox(
                    height: 5,
                  ),
                  DropdownButtonFormField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Pilih salah satu')),
                      value: statAbs != ""
                          ? absC.stsAbsenSelected.value = statAbs
                          : statAbs == "" && absC.stsAbsenSelected.isEmpty
                              ? null
                              : null,
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
                  Visibility(
                    visible: statAbs == "" ? true : false,
                    child: CsDropdownShiftKerja(
                        value: absC.selectedShift.value == ""
                            ? null
                            : absC.selectedShift.value),
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
                if (statAbs != "") {
                  absC.selectedShift.value = statShiftAbs;
                }
                if (absC.stsAbsenSelected.isEmpty) {
                  showToast("Harap pilih Absen Masuk / Pulang");
                } else if (absC.selectedShift.isEmpty) {
                  showToast("Harap pilih Shift Absen");
                } else {
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
                    absC.selectedShift.value = "";
                    absC.selectedCabang.value = "";
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
                        await pref.setString("stateStatusAbsen",
                            "Pulang"); //menyimpan status pilihan absen(masuk / pulang) kedalam sharedpreference
                        await pref.setString(
                            "stateShiftAbsen",
                            absC.selectedShift
                                .value); //menyimpan status pilihan absen(masuk / pulang) kedalam sharedpreference
                        if (absC.image != null) {
                          // CEK ABSEN MASUK HARI INI, JIKA HASIL = 0, ABSEN MASUK

                          var localDataAbs = await SQLHelper.instance
                              .getAbsenToday(dataUser.id!, absC.dateNow);
                          if (localDataAbs.isEmpty) {
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
                              "foto_masuk": File(absC.image!.path.toString()),
                              "lat_masuk": latitude.toString(),
                              "long_masuk": longitude.toString(),
                              "device_info": absC.devInfo.value
                            };

                            loadingDialog("Sedang mengirim data...", "");
                            //submit data absensi ke local storage
                            await SQLHelper.instance.insertDataAbsen(Absen(
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
                                fotoMasuk: absC.image!.path.toString(),
                                latMasuk: latitude.toString(),
                                longMasuk: longitude.toString(),
                                fotoPulang: '',
                                latPulang: '',
                                longPulang: '',
                                devInfo: absC.devInfo.value,
                                devInfo2: ''));
                            // submit data absensi ke server
                            ServiceApi().submitAbsen(data, false);

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
                            absC.startTimer(60);
                            absC.resend();

                            absC.selectedShift.value = "";
                            absC.selectedCabang.value = "";
                            absC.lat.value = "";
                            absC.long.value = "";
                          }
                        } else {
                          await pref.setString(
                              "stateShiftAbsen", absC.selectedShift.value);
                          await pref.setString("stateStatusAbsen", "");
                          absC.selectedShift.value = "";
                          absC.selectedCabang.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Masuk dibatalkan");
                        }
                      } else {
                        // await pref.setString(
                        //     "stateShiftAbsen", absC.selectedShift.value);
                        // await pref.setString("stateStatusAbsen", "Pulang");
                        absC.selectedShift.value = "";
                        absC.selectedCabang.value = "";
                        absC.lat.value = "";
                        absC.long.value = "";
                        succesDialog(Get.context, "Y",
                            "Anda sudah Absen Masuk hari ini.");
                      }
                    } else {
                      //absen pulang

                      double distance = Geolocator.distanceBetween(
                          double.parse(absC.lat.isNotEmpty
                              ? absC.lat.value
                              : dataUser.lat!),
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
                        await absC.cekDataAbsen(
                            "masuk",
                            dataUser.id!,
                            DateFormat('yyyy-MM-dd').format(DateTime.parse(
                                absC.dateNowServer.isNotEmpty
                                    ? absC.dateNowServer
                                    : absC.dateNow)));
                        if (absC.cekAbsen.value.total == "0") {
                          absC.stsAbsenSelected.value = "";
                          absC.selectedShift.value = "";
                          absC.selectedCabang.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Anda belum melakukan absen masuk");
                        } else {
                          await absC.cekDataAbsen(
                              "pulang",
                              dataUser.id!,
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)));
                          if (absC.cekAbsen.value.total == "0") {
                            await absC.uploadFotoAbsen();
                            Get.back();
                            if (absC.image != null) {
                              var localDataAbs = await SQLHelper.instance
                                  .getAbsenToday(dataUser.id!, absC.dateNow);
                              if (localDataAbs.isNotEmpty &&
                                      localDataAbs[0].tanggalPulang == null ||
                                  localDataAbs.isEmpty) {
                                var data = {
                                  "status": "update",
                                  "id": dataUser.id,
                                  "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                      .format(
                                          DateTime.parse(absC.dateNowServer)),
                                  "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                      .format(
                                          DateTime.parse(absC.dateNowServer)),
                                  "nama": dataUser.nama,
                                  "jam_absen_pulang": absC.timeNow.toString(),
                                  "foto_pulang":
                                      File(absC.image!.path.toString()),
                                  "lat_pulang": latitude.toString(),
                                  "long_pulang": longitude.toString(),
                                  "device_info2": absC.devInfo.value
                                };

                                loadingDialog("Sedang mengirim data...", "");
                                // update data absensi ke local storage
                                SQLHelper.instance.updateDataAbsen(
                                    {
                                      "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              absC.dateNowServer)),
                                      "nama": dataUser.nama,
                                      "jam_absen_pulang":
                                          absC.timeNow.toString(),
                                      "foto_pulang":
                                          absC.image!.path.toString(),
                                      "lat_pulang": latitude.toString(),
                                      "long_pulang": longitude.toString(),
                                      "device_info2": absC.devInfo.value
                                    },
                                    dataUser.id!,
                                    DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(absC.dateNowServer)));

                                // update data absensi ke server
                                ServiceApi().submitAbsen(data, false);

                                absC.sendDataToXmor(
                                    dataUser.id!,
                                    "clock_out",
                                    DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                        DateTime.parse(absC.dateNowServer)),
                                    pref.getString("stateShiftAbsen") ?? '',
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
                                      .format(
                                          DateTime.parse(absC.dateNowServer))
                                };

                                var paramLimitAbsen = {
                                  "mode": "limit",
                                  "id_user": dataUser.id,
                                  "tanggal1": absC.initDate1,
                                  "tanggal2": absC.initDate2
                                };
                                absC.getAbsenToday(paramAbsenToday);
                                absC.getLimitAbsen(paramLimitAbsen);
                                absC.startTimer(60);
                                absC.resend();
                                absC.stsAbsenSelected.value = "";
                                absC.selectedShift.value = "";
                                absC.selectedCabang.value = "";
                                absC.lat.value = "";
                                absC.long.value = "";

                                await pref.setString("stateStatusAbsen", "");
                                await pref.setString("stateShiftAbsen", "");
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
      // } else {
      //   //  succesDialog(Get.context, "Y", "Anda sudah Absen Masuk hari ini.");
      //   // PROSES ABSEN PULANG
      //   // await absC.cekDataAbsen(
      //   //     "pulang",
      //   //     dataUser.id!,
      //   //     DateFormat('yyyy-MM-dd')
      //   //         .format(DateTime.parse(absC.dateNowServer)));
      //   // if (absC.cekAbsen.value.total == "0") {
      //   //   absC.msg.value =
      //   //       "Pilih lokasi absen pulang\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi";

      //   //   AwesomeDialog(
      //   //           context: Get.context!,
      //   //           dialogType: DialogType.info,
      //   //           dismissOnTouchOutside: false,
      //   //           dismissOnBackKeyPress: false,
      //   //           headerAnimationLoop: false,
      //   //           animType: AnimType.bottomSlide,
      //   //           title: 'INFO',
      //   //           desc: absC.msg.value,
      //   //           body: Column(children: [
      //   //             Center(child: Text(absC.msg.value)),

      //   //             CsDropdownCabang(
      //   //               hintText: dataUser.namaCabang,
      //   //               value: absC.selectedCabang.value == ""
      //   //                   ? null
      //   //                   : absC.selectedCabang.value,
      //   //             )

      //   //           ]),
      //   //           btnCancelOnPress: () {
      //   //             absC.selectedCabang.value = "";
      //   //             absC.lat.value = "";
      //   //             absC.long.value = "";
      //   //             auth.selectedMenu(0);
      //   //           },
      //   //           btnOkOnPress: () async {
      //   //             SharedPreferences pref =
      //   //                 await SharedPreferences.getInstance();
      //   //             double distance = Geolocator.distanceBetween(
      //   //                 double.parse(absC.lat.isNotEmpty
      //   //                     ? absC.lat.value
      //   //                     : dataUser.lat!),
      //   //                 double.parse(absC.long.isNotEmpty
      //   //                     ? absC.long.value
      //   //                     : dataUser.long!),
      //   //                 latitude.toDouble(),
      //   //                 longitude.toDouble());
      //   //             await pref.setStringList('userLoc', <String>[
      //   //               absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!,
      //   //               absC.long.isNotEmpty ? absC.long.value : dataUser.long!
      //   //             ]);

      //   //             absC.distanceStore.value = distance;
      //   //             // CEK POSISI USER SAAT HENDAK ABSEN
      //   //             if (absC.distanceStore.value >
      //   //                 num.parse(dataUser.areaCover!)) {
      //   //               //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
      //   //               Get.back();
      //   //               dialogMsgCncl('Terjadi Kesalahan',
      //   //                   'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

      //   //               absC.selectedCabang.value = "";
      //   //               absC.lat.value = "";
      //   //               absC.long.value = "";
      //   //             } else {
      //   //               await absC.uploadFotoAbsen();

      //   //               Get.back();

      //   //               if (absC.image != null) {
      //   //                 var data = {
      //   //                   "status": "update",
      //   //                   "id": dataUser.id,
      //   //                   "tanggal_masuk": DateFormat('yyyy-MM-dd')
      //   //                       .format(DateTime.parse(absC.dateNowServer)),
      //   //                   "tanggal_pulang": DateFormat('yyyy-MM-dd')
      //   //                       .format(DateTime.parse(absC.dateNowServer)),
      //   //                   "nama": dataUser.nama,
      //   //                   "jam_absen_pulang": absC.timeNow.toString(),
      //   //                   "foto_pulang": File(absC.image!.path.toString()),
      //   //                   "lat_pulang": latitude.toString(),
      //   //                   "long_pulang": longitude.toString(),
      //   //                   "device_info2": absC.devInfo.value
      //   //                 };

      //   //                 loadingDialog("Sedang mengirim data...", "");
      //   //                 //update data absensi ke local storage
      //   //                 SQLHelper.instance.updateDataAbsen(
      //   //                     {
      //   //                       "tanggal_pulang": DateFormat('yyyy-MM-dd')
      //   //                           .format(DateTime.parse(absC.dateNowServer)),
      //   //                       "nama": dataUser.nama,
      //   //                       "jam_absen_pulang": absC.timeNow.toString(),
      //   //                       "foto_pulang": absC.image!.path.toString(),
      //   //                       "lat_pulang": latitude.toString(),
      //   //                       "long_pulang": longitude.toString(),
      //   //                       "device_info2": absC.devInfo.value
      //   //                     },
      //   //                     dataUser.id!,
      //   //                     DateFormat('yyyy-MM-dd')
      //   //                         .format(DateTime.parse(absC.dateNowServer)));
      //   //                 // update data absensi ke server
      //   //                 ServiceApi().submitAbsen(data, false);

      //   //                 var paramAbsenToday = {
      //   //                   "mode": "single",
      //   //                   "id_user": dataUser.id,
      //   //                   "tanggal_masuk": DateFormat('yyyy-MM-dd')
      //   //                       .format(DateTime.parse(absC.dateNowServer))
      //   //                 };

      //   //                 var paramLimitAbsen = {
      //   //                   "mode": "limit",
      //   //                   "id_user": dataUser.id,
      //   //                   "tanggal1": absC.initDate1,
      //   //                   "tanggal2": absC.initDate2
      //   //                 };
      //   //                 absC.getAbsenToday(paramAbsenToday);
      //   //                 absC.getLimitAbsen(paramLimitAbsen);

      //   //                 absC.selectedCabang.value = "";
      //   //                 absC.lat.value = "";
      //   //                 absC.long.value = "";
      //   //               } else {
      //   //                 Get.back();
      //   //                 failedDialog(Get.context, "Peringatan",
      //   //                     "Absen Pulang dibatalkan");
      //   //               }
      //   //             }
      //   //           },
      //   //           btnCancelText: 'Batalkan',
      //   //           btnCancelColor: Colors.redAccent[700],
      //   //           btnCancelIcon: Icons.cancel,
      //   //           btnOkText: 'Foto',
      //   //           btnOkColor: Colors.blueAccent[700],
      //   //           btnOkIcon: Icons.camera_front)
      //   //       .show();
      //   // } else {
      //   // succesDialog(Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
      //   // }
      // }
      // } else {
      //   // PROSES ABSEN PULANG
      //   await absC.cekDataAbsen(
      //       "pulang",
      //       dataUser.id!,
      //       DateFormat('yyyy-MM-dd')
      //           .format(DateTime.parse(absC.dateNowServer)));
      //   if (absC.cekAbsen.value.total == "0") {
      //     var localDataAbs = await SQLHelper.instance
      //         .getAbsenToday(dataUser.id!, absC.dateNow);
      //     if (localDataAbs.isNotEmpty &&
      //             localDataAbs[0].tanggalPulang == null ||
      //         localDataAbs.isEmpty) {
      //       absC.msg.value =
      //           "Pilih lokasi absen pulang\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi";

      //       AwesomeDialog(
      //               context: Get.context!,
      //               dialogType: DialogType.info,
      //               dismissOnTouchOutside: false,
      //               dismissOnBackKeyPress: false,
      //               headerAnimationLoop: false,
      //               animType: AnimType.bottomSlide,
      //               title: 'INFO',
      //               desc: absC.msg.value,
      //               body: Column(children: [
      //                 Center(child: Text(absC.msg.value)),
      //                 CsDropdownCabang(
      //                   hintText: dataUser.namaCabang,
      //                   value: absC.selectedCabang.value == ""
      //                       ? null
      //                       : absC.selectedCabang.value,
      //                 )
      //               ]),
      //               btnCancelOnPress: () {
      //                 absC.selectedCabang.value = "";
      //                 absC.lat.value = "";
      //                 absC.long.value = "";
      //                 auth.selectedMenu(0);
      //               },
      //               btnOkOnPress: () async {
      //                 SharedPreferences pref =
      //                     await SharedPreferences.getInstance();
      //                 double distance = Geolocator.distanceBetween(
      //                     double.parse(absC.lat.isNotEmpty
      //                         ? absC.lat.value
      //                         : dataUser.lat!),
      //                     double.parse(absC.long.isNotEmpty
      //                         ? absC.long.value
      //                         : dataUser.long!),
      //                     latitude.toDouble(),
      //                     longitude.toDouble());
      //                 await pref.setStringList('userLoc', <String>[
      //                   absC.lat.isNotEmpty ? absC.lat.value : dataUser.lat!,
      //                   absC.long.isNotEmpty ? absC.long.value : dataUser.long!
      //                 ]);

      //                 absC.distanceStore.value = distance;
      //                 // CEK POSISI USER SAAT HENDAK ABSEN
      //                 if (absC.distanceStore.value >
      //                     num.parse(dataUser.areaCover!)) {
      //                   //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
      //                   Get.back();
      //                   dialogMsgCncl('Terjadi Kesalahan',
      //                       'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

      //                   absC.selectedCabang.value = "";
      //                   absC.lat.value = "";
      //                   absC.long.value = "";
      //                 } else {
      //                   await absC.uploadFotoAbsen();

      //                   Get.back();

      //                   if (absC.image != null) {
      //                     var data = {
      //                       "status": "update",
      //                       "id": dataUser.id,
      //                       "tanggal_masuk": DateFormat('yyyy-MM-dd')
      //                           .format(DateTime.parse(absC.dateNowServer)),
      //                       "tanggal_pulang": DateFormat('yyyy-MM-dd')
      //                           .format(DateTime.parse(absC.dateNowServer)),
      //                       "nama": dataUser.nama,
      //                       "jam_absen_pulang": absC.timeNow.toString(),
      //                       "foto_pulang": File(absC.image!.path.toString()),
      //                       "lat_pulang": latitude.toString(),
      //                       "long_pulang": longitude.toString(),
      //                       "device_info2": absC.devInfo.value
      //                     };

      //                     loadingDialog("Sedang mengirim data...", "");
      //                     // update data absensi ke local storage
      //                     SQLHelper.instance.updateDataAbsen(
      //                         {
      //                           "tanggal_pulang": DateFormat('yyyy-MM-dd')
      //                               .format(DateTime.parse(absC.dateNowServer)),
      //                           "nama": dataUser.nama,
      //                           "jam_absen_pulang": absC.timeNow.toString(),
      //                           "foto_pulang": absC.image!.path.toString(),
      //                           "lat_pulang": latitude.toString(),
      //                           "long_pulang": longitude.toString(),
      //                           "device_info2": absC.devInfo.value
      //                         },
      //                         dataUser.id!,
      //                         DateFormat('yyyy-MM-dd')
      //                             .format(DateTime.parse(absC.dateNowServer)));

      //                     // update data absensi ke server
      //                     ServiceApi().submitAbsen(data, false);

      //                     var paramAbsenToday = {
      //                       "mode": "single",
      //                       "id_user": dataUser.id,
      //                       "tanggal_masuk": DateFormat('yyyy-MM-dd')
      //                           .format(DateTime.parse(absC.dateNowServer))
      //                     };

      //                     var paramLimitAbsen = {
      //                       "mode": "limit",
      //                       "id_user": dataUser.id,
      //                       "tanggal1": absC.initDate1,
      //                       "tanggal2": absC.initDate2
      //                     };
      //                     absC.getAbsenToday(paramAbsenToday);
      //                     absC.getLimitAbsen(paramLimitAbsen);
      //                     absC.startTimer(60);
      //                     absC.resend();
      //                     absC.selectedCabang.value = "";
      //                     absC.lat.value = "";
      //                     absC.long.value = "";
      //                     // await Future.delayed(
      //                     //     const Duration(milliseconds: 400));
      //                     // Get.back();
      //                     // succesDialog(
      //                     //     Get.context, "Y", "Anda berhasil Absen");
      //                   } else {
      //                     Get.back();
      //                     failedDialog(Get.context, "Peringatan",
      //                         "Absen Pulang dibatalkan");
      //                   }
      //                 }
      //               },
      //               btnCancelText: 'Batalkan',
      //               btnCancelColor: Colors.redAccent[700],
      //               btnCancelIcon: Icons.cancel,
      //               btnOkText: 'Foto',
      //               btnOkColor: Colors.blueAccent[700],
      //               btnOkIcon: Icons.camera_front)
      //           .show();
      //     } else {
      //       succesDialog(Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
      //     }
      //   } else {
      //     succesDialog(Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
      //   }
      // }
    }
  }
}
