import 'dart:io';

import 'package:absensi/app/data/add_controller.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../services/service_api.dart';

final absC = Get.find<AbsenController>();
final homeC = Get.find<HomeController>();
final adC = Get.put(AdController());
checkOut(Data dataUser, double latitude, double longitude) async {
  // print('Check out woy');
  var previous = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
    ).add(const Duration(days: -1)),
  );

  // Detail waktu
  DateTime now = DateTime.now();
  TimeOfDay currentTime = TimeOfDay.fromDateTime(now);
  TimeOfDay targetTime = const TimeOfDay(hour: 09, minute: 01);
  DateTime currentDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    currentTime.hour,
    currentTime.minute,
  );
  DateTime targetDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    targetTime.hour,
    targetTime.minute,
  );
  bool isBefore9AM = currentDateTime.isBefore(targetDateTime);

  if (isBefore9AM) {
    await absC.cekDataAbsen("pulang", dataUser.id!, previous);

    if (absC.cekAbsen.value.total == "1" &&
        absC.cekAbsen.value.idShift != "0") {
      // Jika ada data absen pulang kemarin yang kosong (tanggal_pulang/jam_pulang kosong)
      // Maka jalankan perintah untuk update data absen pulang

      // Proses upload foto dan update absen pulang seperti kode yang sudah ada
      await absC.uploadFotoAbsen();
      Get.back();

      if (absC.image != null) {
        var localDataAbs = await SQLHelper.instance.getAbsenToday(
          dataUser.id!,
          absC.dateNow,
        );

        if (localDataAbs.isEmpty) {
          // Proses kirim data absen pulang baru
          loadingDialog("Sending data...", "");
          // await absC.timeNetwork(
          //   await FlutterNativeTimezone.getLocalTimezone(),
          // );
          await absC.fallbackTimeNetwork(
            await FlutterNativeTimezone.getLocalTimezone(),
            dotenv.env['API_KEY_WORLDTIME_API'],
          );

          var data = {
            "status": "update",
            "id": dataUser.id,
            "tanggal_masuk": previous,
            "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "nama": dataUser.nama,
            "jam_absen_pulang":
                absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
            "foto_pulang": File(absC.image!.path),
            "lat_pulang": latitude.toString(),
            "long_pulang": longitude.toString(),
            "device_info2": absC.devInfo.value,
          };

          await ServiceApi().submitAbsen(data, false);
          adC.loadInterstitialAd();
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
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
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
          homeC.reloadSummary(dataUser.id!);
          absC.stsAbsenSelected.value = "";
          absC.selectedShift.value = "";
          absC.selectedCabang.value = "";
          absC.lat.value = "";
          absC.long.value = "";
        } else if (localDataAbs.isNotEmpty) {
          // Jika data absen hari ini ditemukan, lakukan update lokal dan server
          loadingDialog("Sending data...", "");
          // await absC.timeNetwork(
          //   await FlutterNativeTimezone.getLocalTimezone(),
          // );

          await absC.fallbackTimeNetwork(
            await FlutterNativeTimezone.getLocalTimezone(),
            dotenv.env['API_KEY_WORLDTIME_API'],
          );

          var data = {
            "status": "update",
            "id": dataUser.id,
            "tanggal_masuk": previous,
            "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "nama": dataUser.nama,
            "jam_absen_pulang":
                absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
            "foto_pulang": File(absC.image!.path),
            "lat_pulang": latitude.toString(),
            "long_pulang": longitude.toString(),
            "device_info2": absC.devInfo.value,
          };

          await SQLHelper.instance.updateDataAbsen(
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
                  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              "foto_pulang": absC.image!.path,
              "lat_pulang": latitude.toString(),
              "long_pulang": longitude.toString(),
              "device_info2": absC.devInfo.value,
            },
            dataUser.id!,
            previous,
          );

          await ServiceApi().submitAbsen(data, false);
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
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
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
          homeC.reloadSummary(dataUser.id!);
          absC.startTimer(10);
          absC.resend();
          absC.stsAbsenSelected.value = "";
          absC.selectedShift.value = "";
          absC.selectedCabang.value = "";
          absC.lat.value = "";
          absC.long.value = "";
        }
      } else {
        //  Get.back();
        failedDialog(Get.context, "Warning", "Check out was cancelled");
      }
    } else {
      //absen pulang
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
          "Warning",
          "Check in data not found\nPlease check in first",
        );
      } else {
        await absC.uploadFotoAbsen();
        Get.back();

        if (absC.image != null) {
          var localDataAbs = await SQLHelper.instance.getAbsenToday(
            dataUser.id!,
            absC.dateNow,
          );

          if (localDataAbs.isEmpty) {
            loadingDialog("Sending data...", "");
            // await absC.timeNetwork(
            //   await FlutterNativeTimezone.getLocalTimezone(),
            // );
            await absC.fallbackTimeNetwork(
              await FlutterNativeTimezone.getLocalTimezone(),
              dotenv.env['API_KEY_WORLDTIME_API'],
            );
            var data = {
              "status": "update",
              "id": dataUser.id,
              "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
                ),
              ),
              "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
                ),
              ),
              "nama": dataUser.nama,
              "jam_absen_pulang":
                  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              // absC.timeNowOpt,
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
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
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
            homeC.reloadSummary(dataUser.id!);
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
            // await absC.timeNetwork(
            //   await FlutterNativeTimezone.getLocalTimezone(),
            // );
            await absC.fallbackTimeNetwork(
              await FlutterNativeTimezone.getLocalTimezone(),
              dotenv.env['API_KEY_WORLDTIME_API'],
            );
            var data = {
              "status": "update",
              "id": dataUser.id,
              "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
                ),
              ),
              "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
                ),
              ),
              "nama": dataUser.nama,
              "jam_absen_pulang":
                  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              // absC.timeNowOpt,
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
                    absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
                //  absC.timeNowOpt,
                "foto_pulang": absC.image!.path,
                "lat_pulang": latitude.toString(),
                "long_pulang": longitude.toString(),
                "device_info2": absC.devInfo.value,
              },
              dataUser.id!,
              DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
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
                  absC.dateNowServer.isNotEmpty
                      ? absC.dateNowServer
                      : absC.dateNow,
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
            homeC.reloadSummary(dataUser.id!);
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
          failedDialog(Get.context, "Warning", "Check out was cancelled");
        }
      }
    }
  } else {
    //absen pulang
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
        "Warning",
        "Check in data not found\nPlease check in first",
      );
    } else {
      await absC.uploadFotoAbsen();
      Get.back();

      if (absC.image != null) {
        var localDataAbs = await SQLHelper.instance.getAbsenToday(
          dataUser.id!,
          absC.dateNow,
        );

        if (localDataAbs.isEmpty) {
          loadingDialog("Sending data...", "");
          // await absC.timeNetwork(
          //   await FlutterNativeTimezone.getLocalTimezone(),
          // );
          await absC.fallbackTimeNetwork(
            await FlutterNativeTimezone.getLocalTimezone(),
            dotenv.env['API_KEY_WORLDTIME_API'],
          );
          var data = {
            "status": "update",
            "id": dataUser.id,
            "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "nama": dataUser.nama,
            "jam_absen_pulang":
                absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
            // absC.timeNowOpt,
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
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
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
          homeC.reloadSummary(dataUser.id!);
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
          // await absC.timeNetwork(
          //   await FlutterNativeTimezone.getLocalTimezone(),
          // );
          await absC.fallbackTimeNetwork(
            await FlutterNativeTimezone.getLocalTimezone(),
            dotenv.env['API_KEY_WORLDTIME_API'],
          );
          var data = {
            "status": "update",
            "id": dataUser.id,
            "tanggal_masuk": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "tanggal_pulang": DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            "nama": dataUser.nama,
            "jam_absen_pulang":
                absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
            // absC.timeNowOpt,
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
                  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              //  absC.timeNowOpt,
              "foto_pulang": absC.image!.path,
              "lat_pulang": latitude.toString(),
              "long_pulang": longitude.toString(),
              "device_info2": absC.devInfo.value,
            },
            dataUser.id!,
            DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
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
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
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
          homeC.reloadSummary(dataUser.id!);
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
        failedDialog(Get.context, "Warning", "Check out was cancelled");
      }
    }
  }
}
