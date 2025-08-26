import 'dart:io';
import 'package:absensi/app/data/add_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/db_helper.dart';
import '../../../../data/model/login_model.dart';
import '../../../../data/model/visit_model.dart';
import '../../../../services/service_api.dart';
import '../../controllers/absen_controller.dart';

final absC = Get.find<AbsenController>();
final adC = Get.put(AdController());
visitIn({
  required Data dataUser,
  required double latitude,
  required double longitude,
}) async {
  await absC.cekDataVisit(
    "masuk",
    dataUser.id!,
    absC.dateNow,
    absC.optVisitSelected.value == "Store Visit"
        ? absC.selectedCabangVisit.isNotEmpty
            ? absC.selectedCabangVisit.value
            : dataUser.kodeCabang!
        : absC.rndLoc.text,
  );

  if (absC.cekVisit.value.total == "0") {
    var tempDataVisit = await SQLHelper.instance.getVisitToday(
      dataUser.id!,
      absC.dateNow,
      absC.optVisitSelected.value == "Store Visit"
          ? absC.selectedCabangVisit.isNotEmpty
              ? absC.selectedCabangVisit.value
              : dataUser.kodeCabang!
          : absC.rndLoc.text,
      1,
    );

    if (tempDataVisit.isEmpty) {
      // simpan dulu ke sqlite
      await absC.uploadFotoAbsen();
      Get.back();
      if (absC.image != null) {
        loadingDialog("Sending data...", "");
        absC.timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
        var data = {
          "status": "add",
          "id": dataUser.id,
          "nama": dataUser.nama,
          "tgl_visit": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "visit_in":
              absC.optVisitSelected.value == "Store Visit"
                  ? absC.selectedCabangVisit.isNotEmpty
                      ? absC.selectedCabangVisit.value
                      : dataUser.kodeCabang
                  : absC.rndLoc.text,
          "jam_in":
              //  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              absC.timeNowOpt,
          "foto_in": File(absC.image!.path),
          "foto_out": "",
          "lat_in": latitude.toString(),
          "long_in": longitude.toString(),
          "device_info": absC.devInfo.value,
          "is_rnd":
              absC.optVisitSelected.value == "Research and Development"
                  ? "1"
                  : "0",
        };

        // submit data visit ke local storage
        SQLHelper.instance.insertDataVisit(
          Visit(
            id: dataUser.id,
            nama: dataUser.nama,
            tglVisit: DateFormat('yyyy-MM-dd').format(
              DateTime.parse(
                absC.dateNowServer.isNotEmpty
                    ? absC.dateNowServer
                    : absC.dateNow,
              ),
            ),
            visitIn:
                absC.optVisitSelected.value == "Store Visit"
                    ? absC.selectedCabangVisit.isNotEmpty
                        ? absC.selectedCabangVisit.value
                        : dataUser.kodeCabang
                    : absC.rndLoc.text,
            jamIn:
                //  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
                absC.timeNowOpt,
            visitOut: '',
            jamOut: '',
            fotoIn: absC.image!.path,
            latIn: latitude.toString(),
            longIn: longitude.toString(),
            fotoOut: '',
            latOut: '',
            longOut: '',
            deviceInfo: absC.devInfo.value,
            deviceInfo2: '',
            isRnd:
                absC.optVisitSelected.value == "Research and Development"
                    ? "1"
                    : "0",
          ),
        );
        // submit data visit ke server

        await ServiceApi().submitVisit(data, false);
        // adC.loadInterstitialAd();
        adC.showInterstitialAd(() {});
        var paramVisitToday = {
          "mode": "single",
          "id_user": dataUser.id,
          "tgl_visit": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
        };

        var paramLimitVisit = {
          "mode": "limit",
          "id_user": dataUser.id,
          "tanggal1": absC.initDate1,
          "tanggal2": absC.initDate2,
        };
        absC.getVisitToday(paramVisitToday);
        absC.getLimitVisit(paramLimitVisit);
        absC.startTimer(10);
        absC.resend();
        absC.stsAbsenSelected.value = "";
        absC.selectedCabangVisit.value = "";
        absC.optVisitSelected.value = "";
        absC.rndLoc.clear();
        absC.lat.value = "";
        absC.long.value = "";
      } else {
        Get.back();
        failedDialog(Get.context, "Peringatan", "Visit dibatalkan");
      }
    } else {
      // langsung kirim ke server
      await absC.uploadFotoAbsen();
      Get.back();
      if (absC.image != null) {
        loadingDialog("Sending data...", "");
        absC.timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
        var data = {
          "status": "add",
          "id": dataUser.id,
          "nama": dataUser.nama,
          "tgl_visit": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
          "visit_in":
              absC.optVisitSelected.value == "Store Visit"
                  ? absC.selectedCabangVisit.isNotEmpty
                      ? absC.selectedCabangVisit.value
                      : dataUser.kodeCabang
                  : absC.rndLoc.text,
          "jam_in":
              //  absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt,
              absC.timeNowOpt,
          "foto_in": File(absC.image!.path),
          "foto_out": "",
          "lat_in": latitude.toString(),
          "long_in": longitude.toString(),
          "device_info": absC.devInfo.value,
          "is_rnd":
              absC.optVisitSelected.value == "Research and Development"
                  ? "1"
                  : "0",
        };
        // submit data visit ke server
        await ServiceApi().submitVisit(data, false);
        adC.loadInterstitialAd();
        adC.showInterstitialAd(() {});
        var paramVisitToday = {
          "mode": "single",
          "id_user": dataUser.id,
          "tgl_visit": DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
            ),
          ),
        };

        var paramLimitVisit = {
          "mode": "limit",
          "id_user": dataUser.id,
          "tanggal1": absC.initDate1,
          "tanggal2": absC.initDate2,
        };
        absC.getVisitToday(paramVisitToday);
        absC.getLimitVisit(paramLimitVisit);
        absC.startTimer(10);
        absC.resend();
        absC.stsAbsenSelected.value = "";
        absC.selectedCabangVisit.value = "";
        absC.optVisitSelected.value = "";
        absC.rndLoc.clear();
        absC.lat.value = "";
        absC.long.value = "";
      } else {
        Get.back();
        failedDialog(Get.context, "Peringatan", "Visit dibatalkan");
      }
    }
  } else {
    absC.stsAbsenSelected.value = "";
    absC.optVisitSelected.value = "";
    absC.rndLoc.clear();
    absC.selectedCabangVisit.value = "";
    Get.back();
    succesDialog(
      context: Get.context!,
      pageAbsen: "N",
      desc: "Anda sudah Check In hari ini",
      type: DialogType.info,
      title: 'INFO',
      btnOkOnPress: () => Get.back(),
    );
  }
}
