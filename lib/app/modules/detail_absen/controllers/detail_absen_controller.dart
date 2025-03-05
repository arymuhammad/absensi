import 'dart:async';

import 'package:absensi/app/services/service_api.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/db_helper.dart';
import '../../../data/model/shift_kerja_model.dart';

class DetailAbsenController extends GetxController {
  var dateNowServer = DateFormat('HH:mm').format(DateTime.now());
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  var selectedShift = "".obs;
  var shiftKerja = <ShiftKerja>[].obs;
  var timeNow = DateFormat('HH:mm').format(DateTime.now());
  XFile? image;
  XFile? image2;
  final ImagePicker picker = ImagePicker();
  late TextEditingController tglMasuk,
      tglPulang,
      jamAbsenMasuk,
      jamAbsenPulang,
      _startTime;
  Rx<Time> time =
      Time(hour: DateTime.now().hour, minute: DateTime.now().minute).obs;
  var devInfo = "".obs;
  var lat = 0.0;
  var long = 0.0;

  @override
  void onInit() {
    super.onInit();
    getShift();

    tglMasuk = TextEditingController();
    tglPulang = TextEditingController();
    jamAbsenMasuk = TextEditingController();
    jamAbsenPulang = TextEditingController();
    _startTime = TextEditingController();
  }

  Future<List<ShiftKerja>> getShift() async {
    var tempShift = await SQLHelper.instance.getShift();
    return shiftKerja.value = tempShift;
  }

  onTimeChanged(Time newTime, BuildContext context) {
    time.value = newTime;
    _startTime.text = time.value.format(context);
  }

  void pickImg() async {
    image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 8);

    if (image != null) {
      update();
    } else {
      return;
    }
  }

  void pickImg2() async {
    image2 =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 8);

    if (image2 != null) {
      update();
    } else {
      return;
    }
  }

  submitApproval(String id, String nama) async {
    if (jamAbsenMasuk.text != "" && jamAbsenPulang.text == "") {
      if (image == null) {
        failedDialog(Get.context!, "Kesalahan",
            "Harap lampirkan bukti foto absen masuk");
      } else {
        var data = {
          "status": "update_masuk",
          "id_user": id,
          "nama": nama,
          "jam_absen_masuk": jamAbsenMasuk.text,
          "tgl_masuk": tglMasuk.text,
          "foto_masuk": image!.path
        };
        loadingDialog("Mengirim data...", "");
        await ServiceApi().reqUpdateAbs(data);
        jamAbsenMasuk.clear();
        image == null;
      }
    } else if (jamAbsenPulang.text != "" && jamAbsenMasuk.text == "") {
      if (tglPulang.text == "") {
        failedDialog(Get.context!, "Kesalahan", "Harap pilih tanggal pulang");
      } else {
        if (image2 == null) {
          failedDialog(Get.context!, "Kesalahan",
              "Harap lampirkan bukti foto absen pulang");
        } else {
          loadingDialog("Mengirim data...", "");
          await getLoc();
          var data = {
            "status": "update_pulang",
            "id_user": id,
            "nama": nama,
            "tgl_masuk": tglMasuk.text,
            "tgl_pulang": tglPulang.text,
            "jam_absen_pulang": jamAbsenPulang.text,
            "foto_pulang": image2!.path,
            "lat_out": lat.toString(),
            "long_out": long.toString(),
            "device_info2": devInfo.value,
          };
          await ServiceApi().reqUpdateAbs(data);
          tglPulang.clear();
          jamAbsenPulang.clear();
          image2 == null;
        }
      }
    } else if (jamAbsenMasuk.text != "" &&
        jamAbsenPulang.text != "" &&
        selectedShift.isEmpty) {
      if (tglPulang.text == "") {
        failedDialog(Get.context!, "Kesalahan", "Harap pilih tanggal pulang");
      } else {
        if (image == null && image2 == null ||
            image == null ||
            image2 == null) {
          failedDialog(Get.context!, "Kesalahan",
              "Harap lampirkan bukti foto absen masuk & pulang");
        } else {
          loadingDialog("Mengirim data...", "");
          await getLoc();
          var data = {
            "status": "update_data_absen",
            "id_user": id,
            "nama": nama,
            "tgl_masuk": tglMasuk.text,
            "tgl_pulang": tglPulang.text,
            "jam_absen_masuk": jamAbsenMasuk.text,
            "jam_absen_pulang": jamAbsenPulang.text,
            "foto_masuk": image!.path,
            "foto_pulang": image2!.path,
            "lat_out": lat.toString(),
            "long_out": long.toString(),
            "device_info2": devInfo.value,
          };
          await ServiceApi().reqUpdateAbs(data);
          tglPulang.clear();
          jamAbsenMasuk.clear();
          jamAbsenMasuk.clear();
          image == null;
          image2 == null;
        }
      }
    } else if (selectedShift.isNotEmpty &&
        jamAbsenMasuk.text == "" &&
        jamAbsenPulang.text == "") {
      var data = {
        "status": "update_shift",
        "id_user": id,
        "nama": nama,
        "id_shift": selectedShift.value,
        "jam_masuk": jamMasuk.value,
        "jam_pulang": jamPulang.value,
        "tgl_masuk": tglMasuk.text
      };
      loadingDialog("Mengirim data...", "");
      await ServiceApi().reqUpdateAbs(data);
      selectedShift.value = "";
      jamMasuk.value = "";
      jamPulang.value = "";
    } else {
      failedDialog(
          Get.context!, "Kesalahan", "Harap isi bagian yang ingi diperbarui");
    }
  }

  getLoc() async {
    try {
      final deviceNames = DeviceMarketingNames();
     
      devInfo.value = await deviceNames.getSingleName();
     
    // ignore: empty_catches
    } on PlatformException {}

    Position position = await determinePosition();
    lat = position.latitude;
    long = position.longitude;

    if (position.isMocked == true) {
      dialogMsgCncl('Peringatan',
          'Anda terdeteksi menggunakan\nlokasi palsu\nHarap matikan lokasi palsu');
    }
  }

  Future<Position> determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        showToast("Lokasi belum diaktifkan");
        // lokasi.value = "Lokasi Anda tidak diketahui";
        return Future.error('Location services are disabled.');
      }

      // loadingDialog("Memindai posisi Anda...", "");
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // loadingDialog("Memindai posisi Anda...", "");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.

          showToast("Izin Lokasi ditolak");
          return Future.error('Location permissions are denied');
        }
        await Future.delayed(const Duration(milliseconds: 400));
        // Get.back();
      }
      // await Future.delayed(const Duration(milliseconds: 400));

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        showToast(
            "Izin Lokasi ditolak.\nHarap berikan akses pada perizinan lokasi");
        // Get.back();
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      var loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      loc.isMocked;
      // Get.back();
      return loc;
    } on TimeoutException catch (e) {
      // determinePosition();
      return Future.error(e.toString());
    }
  }
}
