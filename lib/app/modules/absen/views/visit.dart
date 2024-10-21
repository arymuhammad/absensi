import 'dart:convert';
import 'dart:io';

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/helper/db_helper.dart';
import '../../../data/helper/loading_dialog.dart';
import '../../../data/model/login_model.dart';
import '../../../data/model/visit_model.dart';

final absC = Get.put(AbsenController());
visit(Data dataUser, latitude, longitude) async {
  var paramVisitToday = {
    "mode": "single",
    "id_user": dataUser.id,
    "tgl_visit":
        DateFormat('yyyy-MM-dd').format(DateTime.parse(absC.dateNowServer))
  };

  absC.getVisitToday(paramVisitToday);

  var tempDataVisit = await SQLHelper.instance
      .getVisitToday(absC.idUser.value, absC.dateNow, '', 0);

  if (tempDataVisit.isNotEmpty &&
          tempDataVisit.first.visitIn! != "" &&
          tempDataVisit.first.visitOut! != "" ||
      tempDataVisit.isEmpty) {
    absC.optVisitVisible.value = true;
  } else if (tempDataVisit.isNotEmpty && tempDataVisit.first.visitIn! != "") {
    absC.optVisitVisible.value = false;
  }

  if (tempDataVisit.isNotEmpty &&
      tempDataVisit.first.isRnd == "1" &&
      tempDataVisit.first.visitIn != "" &&
      tempDataVisit.first.visitOut == "") {
    absC.optVisitSelected.value = "Research and Development";
    absC.rndLoc..text = tempDataVisit.first.visitIn!;
  } else if (tempDataVisit.isNotEmpty &&
      tempDataVisit.first.isRnd == "1" &&
      tempDataVisit.first.visitIn != "" &&
      tempDataVisit.first.visitOut != "") {
    absC.optVisitSelected.value = "";
    absC.rndLoc.text = "";
  } else if (tempDataVisit.isNotEmpty &&
      tempDataVisit.first.isRnd == "0" &&
      tempDataVisit.first.visitIn != "" &&
      tempDataVisit.first.visitOut == "") {
    absC.optVisitSelected.value = "Store Visit";
  } else {
    absC.optVisitSelected.value = "";
  }

  absC.msg.value = "Hari ini saya akan";
  AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.info,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'INFO',
          desc: absC.msg.value,
          body: Column(
            children: [
              Text(absC.msg.value),
              const SizedBox(
                height: 15,
              ),
              Obx(() => Visibility(
                  visible: absC.optVisitVisible.value ? true : false,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Silahkan pilih salah satu'),
                      items: absC.optVisit
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        absC.optVisitSelected.value = val!;
                      }))),
              const SizedBox(height: 5),
              Obx(() {
                return Visibility(
                  visible:
                      absC.optVisitSelected.value == "Research and Development"
                          ? true
                          : false,
                  child: TextField(
                    controller: absC.rndLoc,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nama Mall/Kota',
                        hintText: 'Cth : AEON MALL - SENTUL'),
                  ),
                );
              }),
              Obx(() {
                return Visibility(
                  visible: absC.optVisitSelected.value == "Store Visit"
                      ? true
                      : false,
                  child: FutureBuilder(
                    future: absC.getCabang(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var dataCabang = snapshot.data!;
                        return DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: dataUser.namaCabang),
                          value: absC.selectedCabangVisit.value == ""
                              ? null
                              : absC.selectedCabangVisit.value,
                          onChanged: (data) {
                            absC.selectedCabangVisit.value = data!;

                            for (int i = 0; i < dataCabang.length; i++) {
                              if (dataCabang[i].kodeCabang == data) {
                                absC.lat.value = dataCabang[i].lat!;
                                absC.long.value = dataCabang[i].long!;
                              }
                            }
                          },
                          items: dataCabang
                              .map((e) => DropdownMenuItem(
                                  value: e.kodeCabang,
                                  child: Text(e.namaCabang.toString())))
                              .toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const CupertinoActivityIndicator();
                    },
                  ),
                );
              }),
            ],
          ),
          btnCancelOnPress: () {
            absC.selectedCabangVisit.value = "";
            absC.optVisitSelected.value = "";
            auth.selectedMenu(0);
          },
          btnOkOnPress: () async {
            if (absC.optVisitSelected.value == "" ||
                absC.optVisitSelected.value == "Research and Development" &&
                    absC.rndLoc.text == "") {
              dialogMsg(
                  'Info', 'Harap pilih & isi lokasi\nVisit/ RnD terlebih dulu');
              absC.optVisitSelected.value = "";
            } else {
              // var paramVisitToday = {
              //   "mode": "single",
              //   "id_user": dataUser.id,
              //   "tgl_visit": DateFormat('yyyy-MM-dd')
              //       .format(DateTime.parse(absC.dateNowServer))
              // };
              // absC.getVisitToday(paramVisitToday);
              if (tempDataVisit.isNotEmpty &&
                  tempDataVisit.first.isRnd == "1" &&
                  tempDataVisit.first.visitOut == "" &&
                  tempDataVisit.first.visitIn! != absC.rndLoc.text) {
                dialogMsg('Info',
                    'Nama Mall yang di input berbeda dengan nama Mall saat absen masuk.\nPerhatikan huruf besar kecil nya');
              } else {
                await absC.cekDataVisit(
                    "masuk",
                    dataUser.id!,
                    absC.dateNow,
                    absC.optVisitSelected.value == "Store Visit"
                        ? absC.selectedCabangVisit.isNotEmpty
                            ? absC.selectedCabangVisit.value
                            : dataUser.kodeCabang!
                        : absC.rndLoc.text);
                if (absC.cekVisit.value.total == "0") {
                  var tempDataVisit = await SQLHelper.instance.getVisitToday(
                      dataUser.id!,
                      absC.dateNow,
                      absC.optVisitSelected.value == "Store Visit"
                          ? absC.selectedCabangVisit.isNotEmpty
                              ? absC.selectedCabangVisit.value
                              : dataUser.kodeCabang!
                          : absC.rndLoc.text,
                      1);

                  if (tempDataVisit.isEmpty) {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
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
                    if (absC.optVisitSelected.value == "Store Visit" &&
                        absC.distanceStore.value >
                            num.parse(dataUser.areaCover!)) {
                      //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                      Get.back();
                      dialogMsgCncl('Terjadi Kesalahan',
                          'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                      absC.selectedCabangVisit.value = "";
                      absC.lat.value = "";
                      absC.long.value = "";
                      absC.optVisitSelected.value = "";
                    } else {
                      await absC.uploadFotoAbsen();
                      Get.back();
                      if (absC.image != null) {
                        loadingDialog("Sedang mengirim data...", "");
                        var data = {
                          "status": "add",
                          "id": dataUser.id,
                          "nama": dataUser.nama,
                          "tgl_visit": DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(absC.dateNowServer)),
                          "visit_in":
                              absC.optVisitSelected.value == "Store Visit"
                                  ? absC.selectedCabangVisit.isNotEmpty
                                      ? absC.selectedCabangVisit.value
                                      : dataUser.kodeCabang
                                  : absC.rndLoc.text,
                          "jam_in": absC.timeNow.toString(),
                          "foto_in": base64
                              .encode(File(absC.image!.path).readAsBytesSync()),
                          "foto_out": "",
                          "lat_in": latitude.toString(),
                          "long_in": longitude.toString(),
                          "device_info": absC.devInfo.value,
                          "is_rnd": absC.optVisitSelected.value ==
                                  "Research and Development"
                              ? "1"
                              : "0"
                        };

                        // submit data visit ke local storage
                        SQLHelper.instance.insertDataVisit(Visit(
                            id: dataUser.id,
                            nama: dataUser.nama,
                            tglVisit: DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            visitIn:
                                absC.optVisitSelected.value == "Store Visit"
                                    ? absC.selectedCabangVisit.isNotEmpty
                                        ? absC.selectedCabangVisit.value
                                        : dataUser.kodeCabang
                                    : absC.rndLoc.text,
                            jamIn: absC.timeNow.toString(),
                            visitOut: '',
                            jamOut: '',
                            fotoIn: base64.encode(
                                File(absC.image!.path).readAsBytesSync()),
                            latIn: latitude.toString(),
                            longIn: longitude.toString(),
                            fotoOut: '',
                            latOut: '',
                            longOut: '',
                            deviceInfo: absC.devInfo.value,
                            deviceInfo2: '',
                            isRnd: absC.optVisitSelected.value ==
                                    "Research and Development"
                                ? "1"
                                : "0"));
                        // submit data visit ke server
                        // offline first
                        await ServiceApi().submitVisit(data, false);
                        // Get.back();
                        // succesDialog(Get.context, "Y",
                        //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
                        var paramVisitToday = {
                          "mode": "single",
                          "id_user": dataUser.id,
                          "tgl_visit": DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(absC.dateNowServer))
                        };

                        var paramLimitVisit = {
                          "mode": "limit",
                          "id_user": dataUser.id,
                          "tanggal1": absC.initDate1,
                          "tanggal2": absC.initDate2
                        };
                        absC.getVisitToday(paramVisitToday);
                        absC.getLimitVisit(paramLimitVisit);
                        absC.startTimer(10);
                        absC.resend();
                        absC.selectedCabangVisit.value = "";
                        absC.optVisitSelected.value = "";
                        absC.rndLoc.clear();
                        absC.lat.value = "";
                        absC.long.value = "";
                      } else {
                        Get.back();
                        failedDialog(Get.context, "Peringatan",
                            "Absen Masuk dibatalkan");
                      }
                    }
                  } else {
                    if (tempDataVisit.isNotEmpty &&
                        tempDataVisit.first.isRnd == "1" &&
                        tempDataVisit.first.visitOut == "" &&
                        tempDataVisit.first.visitIn != absC.rndLoc.text) {
                      dialogMsg('Info',
                          'Nama Mall yang di input berbeda dengan nama Mall saat absen masuk.\nPerhatikan huruf besar kecil nya');
                    } else {
                      if (tempDataVisit.isNotEmpty &&
                          tempDataVisit.first.jamOut == "") {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
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
                          absC.long.isNotEmpty
                              ? absC.long.value
                              : dataUser.long!
                        ]);

                        absC.distanceStore.value = distance;
                        // CEK POSISI USER SAAT HENDAK ABSEN
                        if (absC.optVisitSelected.value == "Store Visit" &&
                            absC.distanceStore.value >
                                num.parse(dataUser.areaCover!)) {
                          //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                          Get.back();
                          dialogMsgCncl('Terjadi Kesalahan',
                              'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                          absC.selectedCabangVisit.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                        } else {
                          await absC.uploadFotoAbsen();
                          Get.back();
                          if (absC.image != null) {
                            loadingDialog("Sedang mengirim data...", "");
                            var data = {
                              "status": "update",
                              "id": dataUser.id,
                              "nama": dataUser.nama,
                              "tgl_visit": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              "visit_out":
                                  absC.optVisitSelected.value == "Store Visit"
                                      ? absC.selectedCabangVisit.isNotEmpty
                                          ? absC.selectedCabangVisit.value
                                          : dataUser.kodeCabang
                                      : absC.rndLoc.text,
                              "visit_in": absC.cekVisit.value.kodeStore,
                              "jam_out": absC.timeNow.toString(),
                              "foto_out": base64.encode(
                                  File(absC.image!.path).readAsBytesSync()),
                              "lat_out": latitude.toString(),
                              "long_out": longitude.toString(),
                              "device_info2": absC.devInfo.value
                            };

                            // update data visit ke local storage
                            SQLHelper.instance.updateDataVisit(
                                {
                                  "visit_out": absC.optVisitSelected.value ==
                                          "Store Visit"
                                      ? absC.selectedCabangVisit.isNotEmpty
                                          ? absC.selectedCabangVisit.value
                                          : dataUser.kodeCabang
                                      : absC.rndLoc.text,
                                  "jam_out": absC.timeNow.toString(),
                                  "foto_out": base64.encode(
                                      File(absC.image!.path).readAsBytesSync()),
                                  "lat_out": latitude.toString(),
                                  "long_out": longitude.toString(),
                                  "device_info2": absC.devInfo.value
                                },
                                dataUser.id!,
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(absC.dateNowServer)),
                                absC.optVisitSelected.value == "Store Visit"
                                    ? absC.selectedCabangVisit.isNotEmpty
                                        ? absC.selectedCabangVisit.value
                                        : dataUser.kodeCabang!
                                    : absC.rndLoc.text);
                            // update data visit ke server
                            // offline first
                            await ServiceApi().submitVisit(data, false);
                            // Get.back();
                            // succesDialog(Get.context, "Y",
                            //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
                            var paramVisitToday = {
                              "mode": "single",
                              "id_user": dataUser.id,
                              "tgl_visit": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer))
                            };

                            var paramLimitVisit = {
                              "mode": "limit",
                              "id_user": dataUser.id,
                              "tanggal1": absC.initDate1,
                              "tanggal2": absC.initDate2
                            };
                            absC.getVisitToday(paramVisitToday);
                            absC.getLimitVisit(paramLimitVisit);
                            absC.startTimer(10);
                            absC.resend();
                            absC.selectedCabangVisit.value = "";
                            absC.lat.value = "";
                            absC.long.value = "";
                            absC.optVisitSelected.value = "";
                            absC.rndLoc.clear();
                          } else {
                            Get.back();
                            failedDialog(Get.context, "Peringatan",
                                "Absen Pulang dibatalkan");
                          }
                        }
                      } else {
                        showToast(
                            "sudah keluar dari kunjungan ke ${tempDataVisit.first.visitIn}");
                      }
                    }
                  }
                } else {
                  if (tempDataVisit.isNotEmpty &&
                      tempDataVisit.first.isRnd == "1" &&
                      tempDataVisit.first.visitOut == "" &&
                      tempDataVisit.first.visitIn! != absC.rndLoc.text) {
                    dialogMsg('Info',
                        'Nama Mall yang di input berbeda dengan nama Mall saat absen masuk.\nPerhatikan huruf besar kecil nya');
                  } else {
                    await absC.cekDataVisit(
                        "pulang",
                        dataUser.id!,
                        absC.dateNow,
                        absC.optVisitSelected.value == "Store Visit"
                            ? absC.selectedCabangVisit.isNotEmpty
                                ? absC.selectedCabangVisit.value
                                : dataUser.kodeCabang!
                            : absC.rndLoc.text);

                    if (absC.cekVisit.value.total == "1") {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
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
                      if (absC.optVisitSelected.value == "Store Visit" &&
                          absC.distanceStore.value >
                              num.parse(dataUser.areaCover!)) {
                        //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                        Get.back();
                        dialogMsgCncl('Terjadi Kesalahan',
                            'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                        absC.selectedCabangVisit.value = "";
                        absC.lat.value = "";
                        absC.long.value = "";
                      } else {
                        await absC.uploadFotoAbsen();
                        Get.back();
                        if (absC.image != null) {
                          loadingDialog("Sedang mengirim data...", "");
                          var data = {
                            "status": "update",
                            "id": dataUser.id,
                            "nama": dataUser.nama,
                            "tgl_visit": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "visit_out":
                                absC.optVisitSelected.value == "Store Visit"
                                    ? absC.selectedCabangVisit.isNotEmpty
                                        ? absC.selectedCabangVisit.value
                                        : dataUser.kodeCabang
                                    : absC.rndLoc.text,
                            "visit_in": absC.cekVisit.value.kodeStore,
                            "jam_out": absC.timeNow.toString(),
                            "foto_out": base64.encode(
                                    File(absC.image!.path).readAsBytesSync()),
                            "lat_out": latitude.toString(),
                            "long_out": longitude.toString(),
                            "device_info2": absC.devInfo.value
                          };

                          
                          // update data visit ke local storage
                           SQLHelper.instance.updateDataVisit(
                              {
                                "visit_out":
                                    absC.optVisitSelected.value == "Store Visit"
                                        ? absC.selectedCabangVisit.isNotEmpty
                                            ? absC.selectedCabangVisit.value
                                            : dataUser.kodeCabang
                                        : absC.rndLoc.text,
                                "jam_out": absC.timeNow.toString(),
                                "foto_out": base64.encode(
                                    File(absC.image!.path).readAsBytesSync()),
                                "lat_out": latitude.toString(),
                                "long_out": longitude.toString(),
                                "device_info2": absC.devInfo.value
                              },
                              dataUser.id!,
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              absC.optVisitSelected.value == "Store Visit"
                                  ? absC.selectedCabangVisit.isNotEmpty
                                      ? absC.selectedCabangVisit.value
                                      : dataUser.kodeCabang!
                                  : absC.rndLoc.text);
                          // update data visit ke server
                          // offline first
                          await ServiceApi().submitVisit(data, false);
                          // Get.back();
                          // succesDialog(Get.context, "Y",
                          //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
                          var paramVisitToday = {
                            "mode": "single",
                            "id_user": dataUser.id,
                            "tgl_visit": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer))
                          };

                          var paramLimitVisit = {
                            "mode": "limit",
                            "id_user": dataUser.id,
                            "tanggal1": absC.initDate1,
                            "tanggal2": absC.initDate2
                          };
                          absC.getVisitToday(paramVisitToday);
                          absC.getLimitVisit(paramLimitVisit);
                          absC.startTimer(10);
                          absC.resend();
                          absC.selectedCabangVisit.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                          absC.optVisitSelected.value = "";
                          absC.rndLoc.clear();
                        } else {
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Pulang dibatalkan");
                        }
                      }
                    } else {
                      showToast(
                          "sudah keluar dari kunjungan ke ${absC.selectedCabangVisit.isNotEmpty ? absC.selectedCabangVisit.value : dataUser.kodeCabang}");
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
