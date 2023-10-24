import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/helper/const.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/model/shift_kerja_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import '../Repo/service_api.dart';
import '../helper/loading_dialog.dart';
import '../model/absen_model.dart';
import '../model/cabang_model.dart';
import '../model/cek_absen_model.dart';

class AbsenController extends GetxController {
  var isLoading = true.obs;
  var ascending = true.obs;
  var lokasi = "".obs;
  // var devInfoWeb = "".obs;
  var devInfo = "".obs;
  var cekAbsen = CekAbsen().obs;
  var dataAbsen = <Absen>[].obs;
  var dataLimitAbsen = <Absen>[].obs;
  var dataAllAbsen = <Absen>[].obs;
  var shiftKerja = <ShiftKerja>[].obs;
  var cabang = <Cabang>[].obs;
  var msg = "".obs;
  var selectedShift = "".obs;
  var selectedCabang = "".obs;
  var distanceStore = 0.0.obs;
  var lat = "".obs;
  var long = "".obs;
  var userPostLat = 0.0.obs;
  var userPostLong = 0.0.obs;
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  var timeNow = "";
  var dateNowServer = "";
  var dateAbsen = "";
  var downloadProgress = 0.0.obs;
  var updateList = [];
  var currVer = "";
  var latestVer = "";
  RxList<Absen> searchAbsen = RxList<Absen>([]);
  late TextEditingController filterAbsen;
  late TextEditingController date1;
  late TextEditingController date2;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  FilePickerResult? imageWeb;
  var searchDate = "".obs;
  var dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  var thisMonth =
      DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()).toString();
  var initDate1 = DateFormat('yyyy-MM-dd')
      .format(DateTime.parse(
          DateTime(DateTime.now().year, DateTime.now().month, 1).toString()))
      .toString();
  var initDate2 = DateFormat('yyyy-MM-dd')
      .format(DateTime.parse(
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
              .toString()))
      .toString();

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = pref.getStringList('userDataLogin');
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin![0],
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin[0],
      "tanggal": dateNow
    };
    filterAbsen = TextEditingController();
    date1 = TextEditingController();
    date2 = TextEditingController();
    searchAbsen.value = dataAllAbsen;
    getAbsenToday(paramSingle);
    getLimitAbsen(paramLimit);
    getCabang();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      currVer = packageInfo.version;
      // String buildNumber = packageInfo.buildNumber;
    
    });

    final readDoc = await http
        .get(Uri.parse('http://103.156.15.60/update apk/updateLog.xml'));

    if (readDoc.statusCode == 200) {
      //parsing readDoc
      final document = xml.XmlDocument.parse(readDoc.body);
      final cLog = document.findElements('items').first;
      latestVer = cLog.findElements('versi').first.text;
      if (latestVer != currVer) {
        checkForUpdates("onInit");
      }
    }
    // Position position = await determinePosition();
    // print(position.latitude);
  }

  @override
  void onClose() {
    super.dispose();
    filterAbsen.dispose();
    date1.dispose();
    date2.dispose();
  }

  Future<List<Cabang>> getCabang() async {
    final response = await ServiceApi().getCabang({});
    return cabang.value = response;
  }

  timeNetwork(String timeZone) async {
    try {
      final response = await http
          .get(Uri.parse(
              'https://timeapi.io/api/Time/current/zone?timeZone=$timeZone'))
          .then((data) => jsonDecode(data.body));
      timeNow = response['time'];
      dateNowServer = response['dateTime'];
    } on HandshakeException catch (_) {
      // print(e.toString());
    }
  }

  getLoc(List<dynamic>? dataUser) async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo.value = '${androidInfo.brand} ${androidInfo.model}';
      // ignore: empty_catches
    } on PlatformException {}

    Position position = await determinePosition();

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    lokasi.value =
        '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
    userPostLat.value = position.latitude;
    userPostLong.value = position.longitude;

    if (position.isMocked == true) {
      dialogMsgCncl('Peringatan',
          'Anda terdeteksi menggunakan\nlokasi palsu\nHarap matikan lokasi palsu');
    } else {
      timeNetwork(currentTimeZone);
      await cekDataAbsen("masuk", dataUser![0]);
      if (cekAbsen.value.total == "0") {
        msg.value = "Absen masuk hari ini?";
        await Get.defaultDialog(
            title: 'Absen',
            content: Column(
              children: [
                Text(msg.value),
                const SizedBox(
                  height: 15,
                ),
                FutureBuilder(
                  future: getCabang(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var dataCabang = snapshot.data!;
                      return DropdownButtonFormField(
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: dataUser[2]),
                        value: selectedCabang.value == ""
                            ? null
                            : selectedCabang.value,
                        onChanged: (data) {
                          selectedCabang.value = data!;

                          for (int i = 0; i < dataCabang.length; i++) {
                            if (dataCabang[i].kodeCabang == data) {
                              lat.value = dataCabang[i].lat!;
                              long.value = dataCabang[i].long!;
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

                          if (selectedShift.value == "4") {
                            jamMasuk.value = timeNow;
                            jamPulang.value = DateFormat("HH:mm").format(
                                DateTime.parse(dateNowServer)
                                    .add(const Duration(hours: 8)));
                          } else {
                            for (int i = 0; i < dataShift.length; i++) {
                              if (dataShift[i].id == data) {
                                jamMasuk.value = dataShift[i].jamMasuk!;
                                jamPulang.value = dataShift[i].jamPulang!;
                              }
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
              selectedShift.value = "";
              selectedCabang.value = "";
            },
            textConfirm: 'Ambil Foto',
            confirmTextColor: Colors.white,
            onConfirm: () async {
              if (selectedShift.isEmpty) {
                showToast("Harap pilih Shift Absen");
              } else {
                SharedPreferences pref = await SharedPreferences.getInstance();
                double distance = Geolocator.distanceBetween(
                    double.parse(lat.isNotEmpty ? lat.value : dataUser[6]),
                    double.parse(long.isNotEmpty ? long.value : dataUser[7]),
                    position.latitude.toDouble(),
                    position.longitude.toDouble());
                await pref.setStringList('userLoc', <String>[
                  lat.isNotEmpty ? lat.value : dataUser[6],
                  long.isNotEmpty ? long.value : dataUser[7]
                ]);

                distanceStore.value = distance;

                if (distanceStore.value > 200) {
                  dialogMsgCncl(
                      'Terjadi Kesalahan', 'Anda berada diluar area absen');
                  selectedShift.value = "";
                  selectedCabang.value = "";
                } else {
                  if (kIsWeb) {
                    imageWeb = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                        withReadStream: true,
                        // this will return PlatformFile object with read stream
                        allowCompression: true);
                  } else {
                    await uploadFotoAbsen();
                  }
                  Get.back();
                  if (image != null || imageWeb != null) {
                    var data = {
                      "status": "add",
                      "tanggal": dateNow,
                      "kode_cabang": selectedCabang.isNotEmpty
                          ? selectedCabang.value
                          : dataUser[8],
                      "id": dataUser[0],
                      "nama": dataUser[1],
                      "id_shift": selectedShift.value,
                      "jam_masuk": jamMasuk.value,
                      "jam_pulang": jamPulang.value,
                      "jam_absen_masuk": timeNow.toString(),
                      "foto_masuk": kIsWeb
                          ? imageWeb!.files.single
                          : File(image!.path.toString()),
                      "lat_masuk": position.latitude.toString(),
                      "long_masuk": position.longitude.toString(),
                      "device_info": devInfo.value
                    };
                    // print(data);

                    loadingDialog("Sedang mengirim data...", "");
                    await ServiceApi().submitAbsen(data);
                    await Future.delayed(const Duration(milliseconds: 600));
                    Get.back();
                    dialogMsgAbsen("Sukses", "Anda berhasil Absen");
                    imageWeb = null;
                  }
                  var paramAbsenToday = {
                    "mode": "single",
                    "id_user": dataUser[0],
                    "tanggal": dateNow
                  };

                  var paramLimitAbsen = {
                    "mode": "limit",
                    "id_user": dataUser[0],
                    "tanggal1": initDate1,
                    "tanggal2": initDate2
                  };
                  getAbsenToday(paramAbsenToday);
                  getLimitAbsen(paramLimitAbsen);
                  selectedShift.value = "";
                  selectedCabang.value = "";
                }
              }
            },
            barrierDismissible: false);
      } else {
        await cekDataAbsen("pulang", dataUser[0]);
        if (cekAbsen.value.total == "0") {
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
                SharedPreferences pref = await SharedPreferences.getInstance();
                List<String> userLoc = pref.getStringList('userLoc') ?? [""];
                double distance = Geolocator.distanceBetween(
                    double.parse(userLoc[0]),
                    double.parse(userLoc[1]),
                    position.latitude.toDouble(),
                    position.longitude.toDouble());

                distanceStore.value = distance;
                if (distanceStore.value > 200) {
                  dialogMsgCncl('Terjadi Kesalahan',
                      'Posisi Anda berada diluar jangkauan area.\nHarap berpindah posisi ke area yang sudah ditentukan');
                } else {
                  if (kIsWeb) {
                    imageWeb = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                        withReadStream: true,

                        // this will return PlatformFile object with read stream
                        allowCompression: true);
                  } else {
                    await uploadFotoAbsen();
                  }
                  Get.back();
                  loadingDialog("Sedang mengirim data...", "");

                  if (image != null || imageWeb != null) {
                    var data = {
                      "status": "update",
                      "id": dataUser[0],
                      "tanggal": dateNow,
                      "nama": dataUser[1],
                      "jam_absen_pulang": timeNow.toString(),
                      "foto_pulang": kIsWeb
                          ? imageWeb!.files.single
                          : File(image!.path.toString()),
                      "lat_pulang": position.latitude.toString(),
                      "long_pulang": position.longitude.toString(),
                      "device_info2": devInfo.value
                    };
                    await ServiceApi().submitAbsen(data);
                  }
                  var paramAbsenToday = {
                    "mode": "single",
                    "id_user": dataUser[0],
                    "tanggal": dateNow
                  };

                  var paramLimitAbsen = {
                    "mode": "limit",
                    "id_user": dataUser[0],
                    "tanggal1": initDate1,
                    "tanggal2": initDate2
                  };
                  getAbsenToday(paramAbsenToday);
                  getLimitAbsen(paramLimitAbsen);
                  await Future.delayed(const Duration(milliseconds: 400));
                  Get.back();
                  dialogMsgAbsen("Sukses", "Anda berhasil Absen");
                }
              },
              barrierDismissible: false);
        } else {
          dialogMsgCncl(
              "Terjadi Kesalahan", "Anda sudah Absen Pulang hari ini.");
        }
      }
    }
  }

  Future<CekAbsen> cekDataAbsen(String status, String id) async {
    var data = {
      "status": status,
      "id_user": id,
      "tanggal": dateAbsen != "" ? dateAbsen : dateNow
    };
    final response = await ServiceApi().cekDataAbsen(data);
    cekAbsen.value = response;
    dateAbsen =
        cekAbsen.value.tanggal != null ? cekAbsen.value.tanggal! : dateNow;
    // print(cekAbsen.value.tanggal);
    return cekAbsen.value;
  }

  Future<void> uploadFotoAbsen() async {
    image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxHeight: 600,
        maxWidth: 600);

    if (image != null) {
      update();
    } else {}
  }

  Future<Position> determinePosition() async {
    try {
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
      }

      loadingDialog("Memindai posisi Anda...", "");
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
          // return Future.error('Location permissions are denied');
          // await Future.delayed(const Duration(milliseconds: 400));
          // Get.back();
          showToast("Izin Lokasi ditolak");
          return Future.error('Location permissions are denied');
        }
        await Future.delayed(const Duration(milliseconds: 400));
        Get.back();
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

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      // Get.back();
      // loadingDialog("Memindai posisi Anda...", "");
      var loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        // timeLimit: const Duration(seconds: 10),
        // forceAndroidLocationManager: true
        //
      );
      loc.isMocked;
      // print(loc.isMocked);
      Get.back();
      return loc;

      // Get.back();
    } on TimeoutException catch (e) {
      // determinePosition();
      return Future.error(e.toString());
    }
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
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };
    final response = await ServiceApi().getAbsen(param);
    dataAllAbsen.value = response;
    isLoading.value = false;
    return dataAllAbsen;
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

  Future<List<Absen>> getFilteredAbsen(idUser) async {
    if (date1.text != "" && date2.text != "") {
      var data = {
        "mode": "filtered",
        "id_user": idUser,
        "tanggal1": date1.text,
        "tanggal2": date2.text,
      };
      loadingDialog("Sedang memuat data...", "");
      final response = await ServiceApi().getFilteredAbsen(data);
      dataAllAbsen.value = response;
      isLoading.value = false;
      searchDate.value =
          '${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date1.text))} - ${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date2.text))} ';
      Get.back();
      Get.back();
    } else {
      showToast("Harap masukkan tanggal untuk mencari data");
    }
    return dataAllAbsen;
  }

  checkForUpdates(status) async {
    if (status != "onInit") {
      loadingDialog("Memeriksa pembaruan...", "");
    }

    try {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.60/update apk/updateLog.xml'));

      final response = await http
          .head(Uri.parse('http://103.156.15.60/update apk/absensiApp.apk'))
          .timeout(const Duration(seconds: 3));
      Get.back();
      if (response.statusCode == 200) {
        //parsing readDoc
        final document = xml.XmlDocument.parse(readDoc.body);
        final itemsNode = document.findElements('items').first;
        final updates = itemsNode.findElements('update');
        latestVer = itemsNode.findElements('versi').first.text;
        //start looping item on readDoc
        updateList.clear();
        for (final listUpdates in updates) {
          final name = listUpdates.findElements('name').first.text;
          final desc = listUpdates.findElements('desc').first.text;
          final icon = listUpdates.findElements('icon').first.text;
          final color = listUpdates.findElements('color').first.text;

          updateList
              .add({'name': name, 'desc': desc, 'icon': icon, 'color': color});
        }
        //end loop item on readDoc
        if (latestVer == currVer) {
          if (status != "onInit") {
            Get.back(closeOverlays: true);
            dialogMsgScsUpd("", "Tidak ada pembaruan sistem");
          }
        } else {
          Get.defaultDialog(
              radius: 2,
              onWillPop: () async {
                return false;
              },
              title: 'Pembaruan Tersedia',
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apa yang baru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('versi $latestVer',
                      style: TextStyle(color: subTitleColor)),
                  const SizedBox(
                    height: 5,
                  ),
                  for (var i in updateList)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              IconData(int.parse(i['icon']),
                                  fontFamily: 'MaterialIcons'),
                              color: Color(int.parse(i['color'])),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text('${i['name']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        Text(
                          i['desc'],
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    )
                ],
              ),
              // middleText: 'Ditemukan pembaruan sistem terbaru.',
              textCancel: 'Batal',
              onCancel: () => Get.back(),
              textConfirm: 'Unduh',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.back(closeOverlays: true);
                try {
                  Get.defaultDialog(
                      title: 'Pembaruan perangkat lunak',
                      radius: 2,
                      barrierDismissible: false,
                      onWillPop: () async {
                        return false;
                      },
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text('Mengunduh pembaruan...'),
                          Obx(
                            () => Text('${(downloadProgress.value).toInt()}%'),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Obx(
                            () => LinearPercentIndicator(
                                lineHeight: 10.0,
                                percent: downloadProgress.value / 100,
                                backgroundColor: Colors.grey[220],
                                progressColor: Colors.blue,
                                barRadius: const Radius.circular(5)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ));
                  //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
                  OtaUpdate()
                      .execute(
                    'http://103.156.15.60/update apk/absensiApp.apk',
                    // OPTIONAL
                    // destinationFilename: '/',
                    //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
                    // sha256checksum:
                    //     "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478",
                  )
                      .listen(
                    (OtaEvent event) {
                      downloadProgress.value = double.parse(event.value!);
                    },
                    // onError: errorHandle(Error()),
                    onDone: () => Get.back(),
                  );
                } on http.ClientException catch (e) {
                  print('Failed to make OTA update. Details: $e');
                }
              });
        }
      } else {
        Get.defaultDialog(
            title: 'Pesan',
            middleText:
                'Tidak ada pembaruan aplikasi. \nSistem anda sudah yang terbaru',
            onCancel: () => Get.back(),
            textCancel: 'Tutup');
      }
    } on SocketException catch (e) {
      Get.back(closeOverlays: true);
      Get.defaultDialog(
        title: e.toString(),
        middleText: 'Periksa koneksi internet anda',
        textConfirm: 'Refresh',
        confirmTextColor: Colors.white,
        onConfirm: () {
          checkForUpdates("");
          Get.back(closeOverlays: true);
        },
      );
    }
  }

  errorHandle(Error error) {
    Get.back(closeOverlays: true);
    Get.defaultDialog(
      title: 'Error',
      middleText:
          'Kesalahan saat mengunduh pembaruan sistem\nHarap periksa koneksi internet anda',
      textCancel: 'Refresh',
      onCancel: () => Get.back(closeOverlays: true),
      // onConfirm: () {
      //   checkForUpdates();
      //   Get.back(closeOverlays: true);
      // },
    );
    print('Failed to make OTA update. Details: ${error.stackTrace} .');
  }
}
