import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:client_information/client_information.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import '../Repo/service_api.dart';
import '../helper/loading_dialog.dart';
import '../model/absen_model.dart';
import '../model/cabang_model.dart';
import '../model/cek_absen_model.dart';

class AbsenController extends GetxController {
  var isLoading = true.obs;
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
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  var timeNow = "";
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
  }

  @override
  void onClose() {
    super.dispose();
    filterAbsen.dispose();
    date1.dispose();
    date2.dispose();
  }

  timeNetwork(String timeZone) async {
    try {
      final response = await http
          .get(Uri.parse('https://worldtimeapi.org/api/timezone/$timeZone'))
          .then((data) => jsonDecode(data.body));
      timeNow = response['datetime'];
    } on SocketException catch (_) {}
  }

  Future<List<Cabang>> getCabang() async {
    final response = await ServiceApi().getCabang();
    return cabang.value = response;
  }

  getLoc(List<dynamic>? dataUser) async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();

    await timeNetwork(currentTimeZone);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // print('Running on ${androidInfo.brand}'); // e.g. "Moto G (4)"

    // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    // print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"

    // WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    // print('Running on  ${webBrowserInfo}');

    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfo.webBrowserInfo);
        print(deviceData);

        ClientInformation info = await ClientInformation.fetch();
        devInfo.value = '${info.deviceName} ${info.softwareName}';
      } else {
        if (Platform.isAndroid) {
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfo.iosInfo);
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfo.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfo.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData = _readWindowsDeviceInfo(await deviceInfo.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    Position position = await determinePosition();
    if (!kIsWeb) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      lokasi.value =
          '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
    } else {
      lokasi.value = '${position.latitude} , ${position.longitude}';
    }

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
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Pilih Cabang'),
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
                          jamMasuk.value = DateFormat("HH:mm:ss")
                              .format(DateTime.parse(timeNow).toLocal());
                          jamPulang.value = DateFormat("HH:mm:ss").format(
                              DateTime.parse(timeNow)
                                  .toLocal()
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
                              value: e.id, child: Text(e.namaShift.toString())))
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
                dialogMsgCncl('Terjadi Kesalahan',
                    'Posisi Anda berada diluar jangkauan area.\nHarap berpindah posisi ke area yang sudah ditentukan');
                selectedShift.value = "";
                selectedCabang.value = "";
              } else {
                if (kIsWeb) {
                  imageWeb = await FilePicker.platform.pickFiles(
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
                    "jam_absen_masuk": DateFormat("HH:mm:ss")
                        .format(DateTime.parse(timeNow).toLocal()),
                    "foto_masuk": kIsWeb
                        ? imageWeb!.files.single
                        : File(image!.path.toString()),
                    "lat_masuk": position.latitude.toString(),
                    "long_masuk": position.longitude.toString(),
                    "device_info": devInfo.value
                  };

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
            // Get.back();
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
                    "jam_absen_pulang": DateFormat("HH:mm:ss")
                        .format(DateTime.parse(timeNow).toLocal()),
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
        dialogMsgCncl("Terjadi Kesalahan", "Anda sudah Absen Pulang hari ini.");
      }
    }
    // }
  }

  Future<CekAbsen> cekDataAbsen(String status, String id) async {
    var data = {"status": status, "id_user": id, "tanggal": dateNow};
    final response = await ServiceApi().cekDataAbsen(data);
    
    return cekAbsen.value = response;
  }

  Future<void> uploadFotoAbsen() async {
    image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxHeight: 600,
        maxWidth: 600);
  
    if (image != null) {
      update();
    } else {
      
    }
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

      // loadingDialog("Memindai posisi Anda...", "");
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        loadingDialog("Memindai posisi Anda...", "");
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
        }
        await Future.delayed(const Duration(milliseconds: 400));
        Get.back();
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        showToast(
            "Izin Lokasi ditolak.\nHarap berikan akses pada perizinan lokasi");
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          // timeLimit: const Duration(seconds: 10),
          forceAndroidLocationManager: true);
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
    isLoading.value = false;
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
      isLoading.value = false;
      dataAllAbsen.value = response;
      searchDate.value =
          '${DateFormat("d MMMM yyyy", "id_ID").format(DateTime.parse(date1.text))} - ${DateFormat("d MMMM yyyy", "id_ID").format(DateTime.parse(date2.text))} ';
      Get.back();
      Get.back();
    } else {
      showToast("Harap masukkan tanggal untuk mencari data");
    }
    return dataAllAbsen;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }
}
