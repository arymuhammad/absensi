import 'dart:io' as fileMob;

import 'package:absensi/app/model/shift_kerja_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Repo/service_api.dart';
import '../helper/loading_dialog.dart';
import '../model/absen_model.dart';
import '../model/cek_absen_model.dart';

class AbsenController extends GetxController {
  var isLoading = true.obs;
  var lokasi = "".obs;
  var cekAbsen = CekAbsen().obs;
  var dataAbsen = <Absen>[].obs;
  var dataLimitAbsen = <Absen>[].obs;
  var dataAllAbsen = <Absen>[].obs;
  var shiftKerja = <ShiftKerja>[].obs;
  var msg = "".obs;
  var selectedShift = "".obs;
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  RxList<Absen> searchAbsen = RxList<Absen>([]);
  late TextEditingController filterAbsen;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  FilePickerResult? imageWeb;

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = pref.getStringList('userDataLogin');
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin![0],
      "tanggal1": DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1)
                  .toString()))
          .toString(),
      "tanggal2": DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
                  .toString()))
          .toString()
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin[0],
      "tanggal": DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()
    };
    filterAbsen = TextEditingController();
    searchAbsen.value = dataAllAbsen;
    getAbsenToday(paramSingle);
    getLimitAbsen(paramLimit);
  }

  @override
  void onClose() {
    super.dispose();
    filterAbsen.dispose();
  }

  getLoc(List<dynamic>? dataUser) async {
    // print(dataUser![0]);
    Position position = await determinePosition();
    print('${position.latitude} , ${position.longitude}');
    print('${dataUser![6]} , ${dataUser[7]}');
    if (!kIsWeb) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      lokasi.value =
          '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
    } else {
      lokasi.value = '${position.latitude} , ${position.longitude}';
    }
    double distance = Geolocator.distanceBetween(
        double.parse(dataUser[6]),
        double.parse(dataUser[7]),
        position.latitude.toDouble(),
        position.longitude.toDouble());

    print('$distance ini jarak');
    if (distance >= 200) {
      dialogMsgCncl('Terjadi Kesalahan',
          'Posisi Anda berada diluar jangkauan area.\nHarap berpindah posisi ke area yang sudah ditentukan');
    } else {
      await countDataAbsen(dataUser[0]);
      // print(dataAbsen.value.total);
      if (cekAbsen.value.total == "0") {
        msg.value = "Absen masuk hari ini?";
        Get.defaultDialog(
            title: 'Absen',
            content: Column(
              children: [
                Text(msg.value),
                const SizedBox(
                  height: 15,
                ),
                FutureBuilder(
                  future: getShift(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var dataShift = snapshot.data!;
                      return DropdownButtonFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Pilih Shift Absen'),
                        value: selectedShift.value == ""
                            ? null
                            : selectedShift.value,
                        onChanged: (data) {
                          selectedShift.value = data!;
                          for (int i = 0; i < dataShift.length; i++) {
                            if (dataShift[i].id == data) {
                              jamMasuk.value = dataShift[i].jamMasuk!;
                              jamPulang.value = dataShift[i].jamPulang!;
                              // print(jamMasuk);
                              // print(jamPulang);
                            }
                          }
                        },
                        items: dataShift
                            .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.namaShift.toString())))
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
            textCancel: 'Batal',
            onCancel: () {
              Get.back();
              Get.back();
            },
            textConfirm: 'Ambil Foto',
            confirmTextColor: Colors.white,
            onConfirm: () async {
              if (kIsWeb) {
                imageWeb = await FilePicker.platform.pickFiles(
                    withReadStream: true,
                    // this will return PlatformFile object with read stream
                    allowCompression: true);
              } else {
                await uploadFotoAbsen();
              }
              loadingDialog("Sedang mengirim data...", "");
              if (image != null || imageWeb != null) {
                // // print(File(imageWeb!.files.single.name.toString()));
                // Position position = await determinePosition();
                // // print('${position.latitude} , ${position.longitude}');
                // // List<Placemark> placemarks = await placemarkFromCoordinates(
                // //     position.latitude, position.longitude);
                // // print(placemarks);
                // lokasi.value = '${position.latitude} , ${position.longitude}';
                // // '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
                var data = {
                  "status": "add",
                  "id": dataUser[0],
                  "tanggal": DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString(),
                  "nama": dataUser[1],
                  "id_shift": selectedShift.value,
                  "jam_masuk": jamMasuk.value,
                  "jam_pulang": jamPulang.value,
                  "jam_absen_masuk":
                      DateFormat('HH:mm:ss').format(DateTime.now()).toString(),
                  "foto_masuk": kIsWeb
                      ? imageWeb!.files.single
                      : fileMob.File(image!.path.toString()),
                  "lat_masuk": position.latitude.toString(),
                  "long_masuk": position.longitude.toString(),
                };

                await ServiceApi().submitAbsen(data);
              }
              var paramAbsenToday = {
                "mode": "single",
                "id_user": dataUser[0],
                "tanggal":
                    DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()
              };

              var paramLimitAbsen = {
                "mode": "limit",
                "id_user": dataUser[0],
                "tanggal1": DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .toString()))
                    .toString(),
                "tanggal2": DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(DateTime(
                            DateTime.now().year, DateTime.now().month + 1, 0)
                        .toString()))
                    .toString()
              };
              getAbsenToday(paramAbsenToday);
              getLimitAbsen(paramLimitAbsen);
              // Get.defaultDialog(content: CircularProgressIndicator());
              dialogMsgAbsen("Sukses", "Anda berhasil Absen");
              // Get.back();
            },
            barrierDismissible: false);
      } else {
        msg.value = "Anda yakin ingin absen pulang hari ini?";
        Get.defaultDialog(
            title: 'Absen',
            middleText: msg.value,
            textCancel: 'Batal',
            onCancel: () {
              Get.back();
              Get.back();
            },
            textConfirm: 'Ambil Foto',
            confirmTextColor: Colors.white,
            onConfirm: () async {
              if (kIsWeb) {
                imageWeb = await FilePicker.platform.pickFiles(
                    withReadStream: true,
                    // this will return PlatformFile object with read stream
                    allowCompression: true);
              } else {
                await uploadFotoAbsen();
              }
              loadingDialog("Sedang mengirim data...", "");

              // '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';

              if (image != null || imageWeb != null) {
                var data = {
                  "status": "update",
                  "id": dataUser[0],
                  "tanggal": DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString(),
                  "nama": dataUser[1],
                  "jam_absen_pulang":
                      DateFormat('HH:mm:ss').format(DateTime.now()).toString(),
                  "foto_pulang": kIsWeb
                      ? imageWeb!.files.single
                      : fileMob.File(image!.path.toString()),
                  "lat_pulang": position.latitude.toString(),
                  "long_pulang": position.longitude.toString(),
                };
                await ServiceApi().submitAbsen(data);
              }
              var paramAbsenToday = {
                "mode": "single",
                "id_user": dataUser[0],
                "tanggal":
                    DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()
              };

              var paramLimitAbsen = {
                "mode": "limit",
                "id_user": dataUser[0],
                "tanggal1": DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .toString()))
                    .toString(),
                "tanggal2": DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(DateTime(
                            DateTime.now().year, DateTime.now().month + 1, 0)
                        .toString()))
                    .toString()
              };
              getAbsenToday(paramAbsenToday);
              getLimitAbsen(paramLimitAbsen);
              // Get.defaultDialog(content: CircularProgressIndicator());
              dialogMsgAbsen("Sukses", "Anda berhasil Absen");
              // Get.back();
            },
            barrierDismissible: false);
      }
    }
  }

  Future<CekAbsen> countDataAbsen(String id) async {
    var data = {
      "id_user": id,
      "tanggal": DateFormat('yyyy-MM-dd').format(DateTime.now())
    };
    final response = await ServiceApi().cekDataAbsen(data);
    // print(response);
    return cekAbsen.value = response;
  }

  Future<void> uploadFotoAbsen() async {
    image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxHeight: 600,
        maxWidth: 600);
    print(image!.name);
    print(image!.path);
    if (image != null) {
      update();
    } else {
      print(image);
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      showToast("Lokasi belum diaktifkan");
      return Future.error('Location services are disabled.');
    } else {
      loadingDialog("Memindai posisi Anda...", "");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<List<ShiftKerja>> getShift() async {
    final response = await ServiceApi().getShift();
    return shiftKerja.value = response;
  }

  getAbsenToday(paramAbsen) async {
    final response = await ServiceApi().getAbsen(paramAbsen);
    return dataAbsen.value = response;
  }

  Future<List<Absen>> getLimitAbsen(paramLimitAbsen) async {
    final response = await ServiceApi().getAbsen(paramLimitAbsen);
    isLoading.value = false;
    return dataLimitAbsen.value = response;
  }

  Future<List<Absen>> getAllAbsen(String id) async {
    var param = {
      "mode": "",
      "id_user": id,
      "tanggal1": DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1)
                  .toString()))
          .toString(),
      "tanggal2": DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
                  .toString()))
          .toString()
    };
    final response = await ServiceApi().getAbsen(param);
    isLoading.value = false;
    return dataAllAbsen.value = response;
  }

  filterDataAbsen(String data) {
    List<Absen> result = [];

    if (data.isEmpty) {
      result = dataAllAbsen;
    } else {
      result = dataAllAbsen
          .where((e) =>
              e.tanggal.toString().toLowerCase().contains(data.toLowerCase()))
          .toList();
    }
    searchAbsen.value = result;
  }
}
