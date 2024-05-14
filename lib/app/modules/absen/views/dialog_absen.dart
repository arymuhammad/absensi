import 'dart:io';

import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/visit_model.dart';

final absC = Get.put(AbsenController());

dialogAbsenView(dataUser, latitude, longitude) async {

  if (dataUser![12] == "1") {
    var paramVisitToday = {
      "mode": "single",
      "id_user": dataUser[0],
      "tgl_visit":
          DateFormat('yyyy-MM-dd').format(DateTime.parse(absC.dateNowServer))
    };


    absC.getVisitToday(paramVisitToday);

    var tempDataVisit =
    await SQLHelper.instance.getVisitToday(absC.idUser.value, absC.dateNow,'', 0);


    if (tempDataVisit.isNotEmpty &&
        tempDataVisit.first.visitIn! != "" &&
        tempDataVisit.first.visitOut! != "") {
      absC.optVisitVisible.value = true;
    } else if (tempDataVisit.isNotEmpty &&
        tempDataVisit.first.visitIn! != "") {
      absC.optVisitVisible.value = false;
    }

    if (absC.dataVisit.isNotEmpty &&
        absC.dataVisit[0].isRnd == "1" &&
        absC.dataVisit[0].visitIn != "" &&
        absC.dataVisit[0].visitOut == "") {
      absC.optVisitSelected.value = "Research and Development";
      absC.rndLoc..text = absC.dataVisit[0].visitIn!;
    } else if (absC.dataVisit.isNotEmpty &&
        absC.dataVisit[0].isRnd == "1" &&
        absC.dataVisit[0].visitIn != "" &&
        absC.dataVisit[0].visitOut != "") {
      absC.optVisitSelected.value = "";
      absC.rndLoc.text = "";
    } else if (absC.dataVisit.isNotEmpty &&
        absC.dataVisit[0].isRnd == "0" &&
        absC.dataVisit[0].visitIn != "" &&
        absC.dataVisit[0].visitOut == "") {
      absC.optVisitSelected.value = "Store Visit";
    } else {
      absC.optVisitSelected.value = "";
    }

    absC.msg.value = "Kunjungan / RnD";
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
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          absC.optVisitSelected.value = val!;

                        }))),
                const SizedBox(height: 5),
                Obx(() {
                  return Visibility(
                    visible: absC.optVisitSelected.value ==
                            "Research and Development"
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
                                hintText: dataUser[2]),
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
                dialogMsg('Info',
                    'Harap pilih & isi lokasi\nVisit/ RnD terlebih dulu');
                absC.optVisitSelected.value = "";
              } else {
                // var paramVisitToday = {
                //   "mode": "single",
                //   "id_user": dataUser[0],
                //   "tgl_visit": DateFormat('yyyy-MM-dd')
                //       .format(DateTime.parse(absC.dateNowServer))
                // };
                // absC.getVisitToday(paramVisitToday);
                if (absC.dataVisit.isNotEmpty &&
                    absC.dataVisit[0].isRnd == "1" &&
                    absC.dataVisit[0].visitOut == "" &&
                    absC.dataVisit[0].visitIn! != absC.rndLoc.text) {
                  dialogMsg('Info',
                      'Nama Mall yang di input berbeda dengan nama Mall saat absen masuk.\nPerhatikan huruf besar kecil nya');
                } else {
                  await absC.cekDataVisit(
                      "masuk",
                      dataUser[0],
                      absC.dateNow,
                      absC.optVisitSelected.value == "Store Visit"
                          ? absC.selectedCabangVisit.isNotEmpty
                              ? absC.selectedCabangVisit.value
                              : dataUser[8]
                          : absC.rndLoc.text);
                  if (absC.cekVisit.value.total == "0") {
                    var tempDataVisit = await SQLHelper.instance
                        .getVisitToday(dataUser[0],absC.dateNow,
                        absC.optVisitSelected.value == "Store Visit"
                        ? absC.selectedCabangVisit.isNotEmpty
                        ? absC.selectedCabangVisit.value
                        : dataUser[8]
                        : absC.rndLoc.text,1);

                    if(tempDataVisit.isEmpty){
                      SharedPreferences pref =
                      await SharedPreferences.getInstance();
                      double distance = Geolocator.distanceBetween(
                          double.parse(
                              absC.lat.isNotEmpty ? absC.lat.value : dataUser[6]),
                          double.parse(absC.long.isNotEmpty
                              ? absC.long.value
                              : dataUser[7]),
                          latitude.toDouble(),
                          longitude.toDouble());
                      await pref.setStringList('userLoc', <String>[
                        absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                        absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                      ]);

                      absC.distanceStore.value = distance;
                      // CEK POSISI USER SAAT HENDAK ABSEN
                      if (absC.optVisitSelected.value == "Store Visit"
                          && absC.distanceStore.value > num.parse(dataUser[11])) {
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
                          var data = {
                            "status": "add",
                            "id": dataUser[0],
                            "nama": dataUser[1],
                            "tgl_visit": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "visit_in":
                            absC.optVisitSelected.value == "Store Visit"
                                ? absC.selectedCabangVisit.isNotEmpty
                                ? absC.selectedCabangVisit.value
                                : dataUser[8]
                                : absC.rndLoc.text,
                            "jam_in": absC.timeNow.toString(),
                            "foto_in": File(absC.image!.path.toString()),
                            "lat_in": latitude.toString(),
                            "long_in": longitude.toString(),
                            "device_info": absC.devInfo.value,
                            "is_rnd": absC.optVisitSelected.value ==
                                "Research and Development"
                                ? "1"
                                : "0"
                          };

                          loadingDialog("Sedang mengirim data...", "");

                          await SQLHelper.instance.insertDataVisit(Visit(
                              id: dataUser[0],
                              nama: dataUser[1],
                              tglVisit: DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              visitIn:
                              absC.optVisitSelected.value == "Store Visit"
                                  ? absC.selectedCabangVisit.isNotEmpty
                                  ? absC.selectedCabangVisit.value
                                  : dataUser[8]
                                  : absC.rndLoc.text,
                              jamIn: absC.timeNow.toString(),
                              visitOut: '',
                              jamOut: '',
                              fotoIn: absC.image!.path.toString(),
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
                          await ServiceApi().submitVisit(data);
                        }
                        var paramVisitToday = {
                          "mode": "single",
                          "id_user": dataUser[0],
                          "tgl_visit": DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(absC.dateNowServer))
                        };

                        var paramLimitVisit = {
                          "mode": "limit",
                          "id_user": dataUser[0],
                          "tanggal1": absC.initDate1,
                          "tanggal2": absC.initDate2
                        };
                        absC.getVisitToday(paramVisitToday);
                        absC.getLimitVisit(paramLimitVisit);
                        absC.selectedCabangVisit.value = "";
                        absC.optVisitSelected.value = "";
                        absC.rndLoc.clear();
                        absC.lat.value = "";
                        absC.long.value = "";
                      }
                    }else{

                      if (tempDataVisit.isNotEmpty &&
                          tempDataVisit.first.isRnd == "1" &&
                          tempDataVisit.first.visitOut == "" &&
                          tempDataVisit.first.visitIn != absC.rndLoc.text) {
                        dialogMsg('Info',
                            'Nama Mall yang di input berbeda dengan nama Mall saat absen masuk.\nPerhatikan huruf besar kecil nya');
                      } else {

                        if (tempDataVisit.isNotEmpty && tempDataVisit.first.jamOut == "") {

                          SharedPreferences pref =
                          await SharedPreferences.getInstance();
                          double distance = Geolocator.distanceBetween(
                              double.parse(absC.lat.isNotEmpty
                                  ? absC.lat.value
                                  : dataUser[6]),
                              double.parse(absC.long.isNotEmpty
                                  ? absC.long.value
                                  : dataUser[7]),
                              latitude.toDouble(),
                              longitude.toDouble());
                          await pref.setStringList('userLoc', <String>[
                            absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                            absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                          ]);

                          absC.distanceStore.value = distance;
                          // CEK POSISI USER SAAT HENDAK ABSEN
                          if (absC.optVisitSelected.value == "Store Visit" && absC.distanceStore.value >
                              num.parse(dataUser[11])) {
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
                              var data = {
                                "status": "update",
                                "id": dataUser[0],
                                "nama": dataUser[1],
                                "tgl_visit": DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(absC.dateNowServer)),
                                "visit_out":
                                absC.optVisitSelected.value == "Store Visit"
                                    ? absC.selectedCabangVisit.isNotEmpty
                                    ? absC.selectedCabangVisit.value
                                    : dataUser[8]
                                    : absC.rndLoc.text,
                                "visit_in": absC.cekVisit.value.kodeStore,
                                "jam_out": absC.timeNow.toString(),
                                "foto_out": File(absC.image!.path.toString()),
                                "lat_out": latitude.toString(),
                                "long_out": longitude.toString(),
                                "device_info2": absC.devInfo.value
                              };

                              loadingDialog("Sedang mengirim data...", "");

                              await SQLHelper.instance.updateDataVisit(
                                  {

                                    "visit_out": absC.optVisitSelected.value ==
                                        "Store Visit"
                                        ? absC.selectedCabangVisit.isNotEmpty
                                        ? absC.selectedCabangVisit.value
                                        : dataUser[8]
                                        : absC.rndLoc.text,
                                    "jam_out": absC.timeNow.toString(),
                                    "foto_out": absC.image!.path.toString(),
                                    "lat_out": latitude.toString(),
                                    "long_out": longitude.toString(),
                                    "device_info2": absC.devInfo.value
                                  },
                                  dataUser[0],
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.parse(absC.dateNowServer)),
                                  absC.optVisitSelected.value == "Store Visit"
                                      ? absC.selectedCabangVisit.isNotEmpty
                                      ? absC.selectedCabangVisit.value
                                      : dataUser[8]
                                      : absC.rndLoc.text);

                              await ServiceApi().submitVisit(data);
                              absC.selectedCabangVisit.value = "";
                              absC.lat.value = "";
                              absC.long.value = "";
                              absC.optVisitSelected.value = "";
                              absC.rndLoc.clear();

                            }
                            var paramVisitToday = {
                              "mode": "single",
                              "id_user": dataUser[0],
                              "tgl_visit": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer))
                            };

                            var paramLimitVisit = {
                              "mode": "limit",
                              "id_user": dataUser[0],
                              "tanggal1": absC.initDate1,
                              "tanggal2": absC.initDate2
                            };
                            absC.getVisitToday(paramVisitToday);
                            absC.getLimitVisit(paramLimitVisit);
                          }
                        } else {
                          showToast(
                              "sudah keluar dari kunjungan ke ${tempDataVisit.first.visitIn}");
                        }
                      }
                    }

                  } else {
                
                    if (absC.dataVisit.isNotEmpty &&
                        absC.dataVisit[0].isRnd == "1" &&
                        absC.dataVisit[0].visitOut == "" &&
                        absC.dataVisit[0].visitIn! != absC.rndLoc.text) {
                      dialogMsg('Info',
                          'Nama Mall yang di input berbeda dengan nama Mall saat absen masuk.\nPerhatikan huruf besar kecil nya');
                    } else {

                      await absC.cekDataVisit(
                          "pulang",
                          dataUser[0],
                          absC.dateNow,
                          absC.optVisitSelected.value == "Store Visit"
                              ? absC.selectedCabangVisit.isNotEmpty
                                  ? absC.selectedCabangVisit.value
                                  : dataUser[8]
                              : absC.rndLoc.text);

                      if (absC.cekVisit.value.total == "1") {
                    
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        double distance = Geolocator.distanceBetween(
                            double.parse(absC.lat.isNotEmpty
                                ? absC.lat.value
                                : dataUser[6]),
                            double.parse(absC.long.isNotEmpty
                                ? absC.long.value
                                : dataUser[7]),
                            latitude.toDouble(),
                            longitude.toDouble());
                        await pref.setStringList('userLoc', <String>[
                          absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                          absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                        ]);

                        absC.distanceStore.value = distance;
                        // CEK POSISI USER SAAT HENDAK ABSEN
                        if (absC.optVisitSelected.value == "Store Visit" && absC.distanceStore.value >
                            num.parse(dataUser[11])) {
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
                            var data = {
                              "status": "update",
                              "id": dataUser[0],
                              "nama": dataUser[1],
                              "tgl_visit": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              "visit_out":
                                  absC.optVisitSelected.value == "Store Visit"
                                      ? absC.selectedCabangVisit.isNotEmpty
                                          ? absC.selectedCabangVisit.value
                                          : dataUser[8]
                                      : absC.rndLoc.text,
                              "visit_in": absC.cekVisit.value.kodeStore,
                              "jam_out": absC.timeNow.toString(),
                              "foto_out": File(absC.image!.path.toString()),
                              "lat_out": latitude.toString(),
                              "long_out": longitude.toString(),
                              "device_info2": absC.devInfo.value
                            };
                         
                            loadingDialog("Sedang mengirim data...", "");

                            await SQLHelper.instance.updateDataVisit(
                                {

                                    "visit_out": absC.optVisitSelected.value ==
                                            "Store Visit"
                                        ? absC.selectedCabangVisit.isNotEmpty
                                            ? absC.selectedCabangVisit.value
                                            : dataUser[8]
                                        : absC.rndLoc.text,
                                    "jam_out": absC.timeNow.toString(),
                                    "foto_out": absC.image!.path.toString(),
                                    "lat_out": latitude.toString(),
                                    "long_out": longitude.toString(),
                                    "device_info2": absC.devInfo.value
                                },
                                dataUser[0],
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(absC.dateNowServer)),
                                absC.optVisitSelected.value == "Store Visit"
                                    ? absC.selectedCabangVisit.isNotEmpty
                                        ? absC.selectedCabangVisit.value
                                        : dataUser[8]
                                    : absC.rndLoc.text);

                            await ServiceApi().submitVisit(data);
                            absC.selectedCabangVisit.value = "";
                            absC.lat.value = "";
                            absC.long.value = "";
                            absC.optVisitSelected.value = "";
                            absC.rndLoc.clear();
                           
                          }
                          var paramVisitToday = {
                            "mode": "single",
                            "id_user": dataUser[0],
                            "tgl_visit": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer))
                          };

                          var paramLimitVisit = {
                            "mode": "limit",
                            "id_user": dataUser[0],
                            "tanggal1": absC.initDate1,
                            "tanggal2": absC.initDate2
                          };
                          absC.getVisitToday(paramVisitToday);
                          absC.getLimitVisit(paramLimitVisit);
                        }
                      } else {
                        showToast(
                            "sudah keluar dari kunjungan ke ${absC.selectedCabangVisit.isNotEmpty ? absC.selectedCabangVisit.value : dataUser[8]}");
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
  } else {
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
      await absC.cekDataAbsen("pulang", dataUser[0], previous);
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
                  FutureBuilder(
                    future: absC.getCabang(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var dataCabang = snapshot.data!;
                        return DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: dataUser[2]),
                          value: absC.selectedCabang.value == ""
                              ? null
                              : absC.selectedCabang.value,
                          onChanged: (data) {
                            absC.selectedCabang.value = data!;

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
                          absC.lat.isNotEmpty ? absC.lat.value : dataUser[6]),
                      double.parse(
                          absC.long.isNotEmpty ? absC.long.value : dataUser[7]),
                      latitude.toDouble(),
                      longitude.toDouble());
                  await pref.setStringList('userLoc', <String>[
                    absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                    absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                  ]);

                  absC.distanceStore.value = distance;
                  // CEK POSISI USER SAAT HENDAK ABSEN
                  if (absC.distanceStore.value > num.parse(dataUser[11])) {
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
                        "id": dataUser[0],
                        "tanggal_masuk": previous,
                        "tanggal_pulang": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer)),
                        "nama": dataUser[1],
                        "jam_absen_pulang": absC.timeNow.toString(),
                        "foto_pulang": File(absC.image!.path.toString()),
                        "lat_pulang": latitude.toString(),
                        "long_pulang": longitude.toString(),
                        "device_info2": absC.devInfo.value
                      };

                      loadingDialog("Sedang mengirim data...", "");
                      await SQLHelper.instance.updateDataAbsen({
                        "tanggal_pulang": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer)),
                        "nama": dataUser[1],
                        "jam_absen_pulang": absC.timeNow.toString(),
                        "foto_pulang": absC.image!.path.toString(),
                        "lat_pulang": latitude.toString(),
                        "long_pulang": longitude.toString(),
                        "device_info2": absC.devInfo.value
                      }, dataUser[0], previous);
                      await ServiceApi().submitAbsen(data);

                      var paramAbsenToday = {
                        "mode": "single",
                        "id_user": dataUser[0],
                        "tanggal_masuk": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(absC.dateNowServer))
                      };

                      var paramLimitAbsen = {
                        "mode": "limit",
                        "id_user": dataUser[0],
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
      await absC.cekDataAbsen(
          "masuk",
          dataUser[0],
          DateFormat('yyyy-MM-dd').format(DateTime.parse(
              absC.dateNowServer.isNotEmpty
                  ? absC.dateNowServer
                  : absC.dateNow)));

      // CEK ABSEN MASUK TODAY, JIKA HASIL = 0, ABSEN MASUK
      if (absC.cekAbsen.value.total == "0") {
        var localDataAbs =
            await SQLHelper.instance.getAbsenToday(dataUser[0], absC.dateNow);
        if (localDataAbs.isEmpty) {
          absC.msg.value = "Absen masuk hari ini?";
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
                      FutureBuilder(
                        future: absC.getCabang(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var dataCabang = snapshot.data!;
                            return DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: dataUser[2]),
                              value: absC.selectedCabang.value == ""
                                  ? null
                                  : absC.selectedCabang.value,
                              onChanged: (data) {
                                absC.selectedCabang.value = data!;

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
                      const SizedBox(height: 5),
                      FutureBuilder(
                        future: absC.getShift(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var dataShift = snapshot.data!;
                            return DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Pilih Shift Absen'),
                              value: absC.selectedShift.value == ""
                                  ? null
                                  : absC.selectedShift.value,
                              onChanged: (data) {
                                absC.selectedShift.value = data!;

                                if (absC.selectedShift.value == "5") {
                                  absC.jamMasuk.value = absC.timeNow;
                                  absC.jamPulang.value = DateFormat("HH:mm")
                                      .format(DateTime.parse(absC.dateNowServer)
                                          .add(const Duration(hours: 8)));
                                } else {
                                  for (int i = 0; i < dataShift.length; i++) {
                                    if (dataShift[i].id == data) {
                                      absC.jamMasuk.value =
                                          dataShift[i].jamMasuk!;
                                      absC.jamPulang.value =
                                          dataShift[i].jamPulang!;
                                    }
                                  }
                                }
                                dialogMsg('Info',
                                    'Pastikan Shift Kerja yang dipilih\nsudah sesuai');
                              },
                              items: dataShift
                                  .map((e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            e.namaShift.toString(),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            ' (${e.jamMasuk!} - ${e.jamPulang!})',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      )))
                                  .toList(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const CupertinoActivityIndicator();
                        },
                      )
                    ],
                  ),
                  btnCancelOnPress: () {
                    absC.selectedShift.value = "";
                    absC.selectedCabang.value = "";
                    absC.lat.value = "";
                    absC.long.value = "";
                    auth.selectedMenu(0);
                  },
                  btnOkOnPress: () async {
                    if (absC.selectedShift.isEmpty) {
                      showToast("Harap pilih Shift Absen");
                    } else {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      double distance = Geolocator.distanceBetween(
                          double.parse(absC.lat.isNotEmpty
                              ? absC.lat.value
                              : dataUser[6]),
                          double.parse(absC.long.isNotEmpty
                              ? absC.long.value
                              : dataUser[7]),
                          latitude.toDouble(),
                          longitude.toDouble());
                      await pref.setStringList('userLoc', <String>[
                        absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                        absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                      ]);

                      absC.distanceStore.value = distance;
                      // CEK POSISI USER SAAT HENDAK ABSEN
                      if (absC.distanceStore.value > num.parse(dataUser[11])) {
                        //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                        Get.back();
                        dialogMsgCncl('Terjadi Kesalahan',
                            'Anda berada diluar area absen\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');
                        absC.selectedShift.value = "";
                        absC.selectedCabang.value = "";
                        absC.lat.value = "";
                        absC.long.value = "";
                      } else {
                        await absC.uploadFotoAbsen();
                        Get.back();
                        if (absC.image != null) {
                          var data = {
                            "status": "add",
                            "id": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "kode_cabang": absC.selectedCabang.isNotEmpty
                                ? absC.selectedCabang.value
                                : dataUser[8],
                            "nama": dataUser[1],
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
                          await SQLHelper.instance.insertDataAbsen(Absen(
                              idUser: dataUser[0],
                              tanggalMasuk: DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)),
                              kodeCabang: absC.selectedCabang.isNotEmpty
                                  ? absC.selectedCabang.value
                                  : dataUser[8],
                              nama: dataUser[1],
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

                          await ServiceApi().submitAbsen(data);

                          var paramAbsenToday = {
                            "mode": "single",
                            "id_user": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer))
                          };

                          var paramLimitAbsen = {
                            "mode": "limit",
                            "id_user": dataUser[0],
                            "tanggal1": absC.initDate1,
                            "tanggal2": absC.initDate2
                          };
                          absC.getAbsenToday(paramAbsenToday);
                          absC.getLimitAbsen(paramLimitAbsen);
                          // await absC.cekDataAbsen(
                          //     "masuk",
                          //     dataUser[0],
                          //     DateFormat('yyyy-MM-dd').format(DateTime.parse(
                          //         absC.dateNowServer.isNotEmpty
                          //             ? absC.dateNowServer
                          //             : absC.dateNow)));
                          // if (absC.cekAbsen.value.total == "0") {
                          //   failedDialog(Get.context, 'PERINGATAN',
                          //       'Terjadi kesalahan saat melakukan absensi\nHarap mencoba kembali');
                          // } else {
                          //   succesDialog(Get.context, "N", "Anda berhasil Absen");
                          // }
                          absC.selectedShift.value = "";
                          absC.selectedCabang.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                        }else {
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Masuk dibatalkan");
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
        } else {
          // PROSES ABSEN PULANG
          await absC.cekDataAbsen(
              "pulang",
              dataUser[0],
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(absC.dateNowServer)));
          if (absC.cekAbsen.value.total == "0") {
            absC.msg.value =
                "Pilih lokasi absen pulang\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi";

            AwesomeDialog(
                    context: Get.context!,
                    dialogType: DialogType.info,
                    dismissOnTouchOutside: false,
                    dismissOnBackKeyPress: false,
                    headerAnimationLoop: false,
                    animType: AnimType.bottomSlide,
                    title: 'INFO',
                    desc: absC.msg.value,
                    body: Column(children: [
                      Center(child: Text(absC.msg.value)),
                      FutureBuilder(
                        future: absC.getCabang(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var dataCabang = snapshot.data!;
                            return DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: dataUser[2]),
                              value: absC.selectedCabang.value == ""
                                  ? null
                                  : absC.selectedCabang.value,
                              onChanged: (data) {
                                absC.selectedCabang.value = data!;

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
                    ]),
                    btnCancelOnPress: () {
                      absC.selectedCabang.value = "";
                      absC.lat.value = "";
                      absC.long.value = "";
                      auth.selectedMenu(0);
                    },
                    btnOkOnPress: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      double distance = Geolocator.distanceBetween(
                          double.parse(absC.lat.isNotEmpty
                              ? absC.lat.value
                              : dataUser[6]),
                          double.parse(absC.long.isNotEmpty
                              ? absC.long.value
                              : dataUser[7]),
                          latitude.toDouble(),
                          longitude.toDouble());
                      await pref.setStringList('userLoc', <String>[
                        absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                        absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                      ]);

                      absC.distanceStore.value = distance;
                      // CEK POSISI USER SAAT HENDAK ABSEN
                      if (absC.distanceStore.value > num.parse(dataUser[11])) {
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
                            "id": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "nama": dataUser[1],
                            "jam_absen_pulang": absC.timeNow.toString(),
                            "foto_pulang": File(absC.image!.path.toString()),
                            "lat_pulang": latitude.toString(),
                            "long_pulang": longitude.toString(),
                            "device_info2": absC.devInfo.value
                          };

                          loadingDialog("Sedang mengirim data...", "");
                          await SQLHelper.instance.updateDataAbsen(
                              {
                                "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(absC.dateNowServer)),
                                "nama": dataUser[1],
                                "jam_absen_pulang": absC.timeNow.toString(),
                                "foto_pulang": absC.image!.path.toString(),
                                "lat_pulang": latitude.toString(),
                                "long_pulang": longitude.toString(),
                                "device_info2": absC.devInfo.value
                              },
                              dataUser[0],
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)));
                          await ServiceApi().submitAbsen(data);

                          var paramAbsenToday = {
                            "mode": "single",
                            "id_user": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer))
                          };

                          var paramLimitAbsen = {
                            "mode": "limit",
                            "id_user": dataUser[0],
                            "tanggal1": absC.initDate1,
                            "tanggal2": absC.initDate2
                          };
                          absC.getAbsenToday(paramAbsenToday);
                          absC.getLimitAbsen(paramLimitAbsen);
                          // await absC.cekDataAbsen(
                          //     "masuk",
                          //     dataUser[0],
                          //     DateFormat('yyyy-MM-dd').format(DateTime.parse(
                          //         absC.dateNowServer.isNotEmpty
                          //             ? absC.dateNowServer
                          //             : absC.dateNow)));
                          // if (absC.cekAbsen.value.total == "0") {
                          //   failedDialog(Get.context, 'PERINGATAN',
                          //       'Terjadi kesalahan saat melakukan absensi\nHarap mencoba kembali');
                          // } else {
                          //   succesDialog(
                          //       Get.context, "N", "Anda berhasil Absen");
                          // }
                          absC.selectedCabang.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                          // await Future.delayed(
                          //     const Duration(milliseconds: 400));
                          // Get.back();
                          // succesDialog(
                          //     Get.context, "Y", "Anda berhasil Absen");
                        } else {
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Pulang dibatalkan");
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
            succesDialog(Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
          }
        }
      } else {
        // PROSES ABSEN PULANG
        await absC.cekDataAbsen(
            "pulang",
            dataUser[0],
            DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(absC.dateNowServer)));
        if (absC.cekAbsen.value.total == "0") {
          var localDataAbs =
              await SQLHelper.instance.getAbsenToday(dataUser[0], absC.dateNow);
          if (localDataAbs.isNotEmpty &&
              localDataAbs[0].tanggalPulang == null || localDataAbs.isEmpty) {
            absC.msg.value =
                "Pilih lokasi absen pulang\nJarak anda ${absC.distanceStore.value.toStringAsFixed(2)} m dari titik lokasi";

            AwesomeDialog(
                    context: Get.context!,
                    dialogType: DialogType.info,
                    dismissOnTouchOutside: false,
                    dismissOnBackKeyPress: false,
                    headerAnimationLoop: false,
                    animType: AnimType.bottomSlide,
                    title: 'INFO',
                    desc: absC.msg.value,
                    body: Column(children: [
                      Center(child: Text(absC.msg.value)),
                      FutureBuilder(
                        future: absC.getCabang(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var dataCabang = snapshot.data!;
                            return DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: dataUser[2]),
                              value: absC.selectedCabang.value == ""
                                  ? null
                                  : absC.selectedCabang.value,
                              onChanged: (data) {
                                absC.selectedCabang.value = data!;

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
                    ]),
                    btnCancelOnPress: () {
                      absC.selectedCabang.value = "";
                      absC.lat.value = "";
                      absC.long.value = "";
                      auth.selectedMenu(0);
                    },
                    btnOkOnPress: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      double distance = Geolocator.distanceBetween(
                          double.parse(absC.lat.isNotEmpty
                              ? absC.lat.value
                              : dataUser[6]),
                          double.parse(absC.long.isNotEmpty
                              ? absC.long.value
                              : dataUser[7]),
                          latitude.toDouble(),
                          longitude.toDouble());
                      await pref.setStringList('userLoc', <String>[
                        absC.lat.isNotEmpty ? absC.lat.value : dataUser[6],
                        absC.long.isNotEmpty ? absC.long.value : dataUser[7]
                      ]);

                      absC.distanceStore.value = distance;
                      // CEK POSISI USER SAAT HENDAK ABSEN
                      if (absC.distanceStore.value > num.parse(dataUser[11])) {
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
                            "id": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer)),
                            "nama": dataUser[1],
                            "jam_absen_pulang": absC.timeNow.toString(),
                            "foto_pulang": File(absC.image!.path.toString()),
                            "lat_pulang": latitude.toString(),
                            "long_pulang": longitude.toString(),
                            "device_info2": absC.devInfo.value
                          };

                          loadingDialog("Sedang mengirim data...", "");
                          await SQLHelper.instance.updateDataAbsen(
                              {
                                "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(absC.dateNowServer)),
                                "nama": dataUser[1],
                                "jam_absen_pulang": absC.timeNow.toString(),
                                "foto_pulang": absC.image!.path.toString(),
                                "lat_pulang": latitude.toString(),
                                "long_pulang": longitude.toString(),
                                "device_info2": absC.devInfo.value
                              },
                              dataUser[0],
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(absC.dateNowServer)));
                          await ServiceApi().submitAbsen(data);

                          var paramAbsenToday = {
                            "mode": "single",
                            "id_user": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(absC.dateNowServer))
                          };

                          var paramLimitAbsen = {
                            "mode": "limit",
                            "id_user": dataUser[0],
                            "tanggal1": absC.initDate1,
                            "tanggal2": absC.initDate2
                          };
                          absC.getAbsenToday(paramAbsenToday);
                          absC.getLimitAbsen(paramLimitAbsen);
                          // await absC.cekDataAbsen(
                          //     "masuk",
                          //     dataUser[0],
                          //     DateFormat('yyyy-MM-dd').format(DateTime.parse(
                          //         absC.dateNowServer.isNotEmpty
                          //             ? absC.dateNowServer
                          //             : absC.dateNow)));
                          // if (absC.cekAbsen.value.total == "0") {
                          //   failedDialog(Get.context, 'PERINGATAN',
                          //       'Terjadi kesalahan saat melakukan absensi\nHarap mencoba kembali');
                          // } else {
                          //   succesDialog(
                          //       Get.context, "N", "Anda berhasil Absen");
                          // }
                          absC.selectedCabang.value = "";
                          absC.lat.value = "";
                          absC.long.value = "";
                          // await Future.delayed(
                          //     const Duration(milliseconds: 400));
                          // Get.back();
                          // succesDialog(
                          //     Get.context, "Y", "Anda berhasil Absen");
                        } else {
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Pulang dibatalkan");
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
          }

          else {

            succesDialog(Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
          }
        } else {
          succesDialog(Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
        }
      }
    }
  }
}
