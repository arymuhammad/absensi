import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/model/cek_visit_model.dart';
import 'package:absensi/app/model/user_model.dart';
import 'package:absensi/app/model/visit_model.dart';
import 'package:absensi/app/modules/home/views/dialog_absen.dart';
import 'package:absensi/app/modules/home/views/dialog_update_app.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/model/shift_kerja_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import '../services/service_api.dart';
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
  var cekVisit =
      CekVisit(total: '', tglVisit: '', kodeStore: '', namaStore: '').obs;
  var dataAbsen = <Absen>[].obs;
  var dataVisit = <Visit>[].obs;
  var dataLimitAbsen = <Absen>[].obs;
  var dataLimitVisit = <Visit>[].obs;
  var dataAllAbsen = <Absen>[].obs;
  var dataAllVisit = <Visit>[].obs;
  var shiftKerja = <ShiftKerja>[].obs;
  var cabang = <Cabang>[].obs;
  var userCabang = <User>[].obs;
  var msg = "".obs;
  var selectedShift = "".obs;
  var selectedCabang = "".obs;
  var selectedUserCabang = "".obs;
  var userMonitor = "".obs;
  var selectedCabangVisit = "".obs;
  var distanceStore = 0.0.obs;
  var lat = "".obs;
  var long = "".obs;
  // var userPostLat = 0.0.obs;
  // var userPostLong = 0.0.obs;
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  var timeNow = "";
  var dateNowServer = "";
  var tglStream = DateTime.now().obs;
  var dateAbsen = "";
  var downloadProgress = 0.0.obs;
  var updateList = [];
  var currVer = "";
  var latestVer = "";
  RxList<Absen> searchAbsen = RxList<Absen>([]);
  RxList<Visit> searchVisit = RxList<Visit>([]);
  late TextEditingController filterAbsen,
      filterVisit,
      date1,
      date2,
      store,
      userCab;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  var searchDate = "".obs;
  var dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
  DateTime? lastTime;
  final _dateStream = Rx<DateTime?>(null);

  // Stream<DateTime?> get dateStream => _dateStream.stream;

  @override
  void onInit() async {
    super.onInit();

    timeNetwork(await FlutterNativeTimezone.getLocalTimezone());

    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = pref.getStringList('userDataLogin');
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin![0],
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramLimitVisit = {
      "mode": "limit",
      "id_user": dataUserLogin[0],
      // "tanggal1": initDate1,
      // "tanggal2": initDate2
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin[0],
      "tanggal_masuk": dateNow
    };

    var paramSingleVisit = {
      "mode": "single",
      "id_user": dataUserLogin[0],
      "tgl_visit": dateNow
    };

    filterAbsen = TextEditingController();
    filterVisit = TextEditingController();
    date1 = TextEditingController();
    date2 = TextEditingController();
    store = TextEditingController();
    userCab = TextEditingController();
    searchAbsen.value = dataAllAbsen;
    searchVisit.value = dataAllVisit;
    getAbsenToday(paramSingle);
    getLimitAbsen(paramLimit);
    getVisitToday(paramSingleVisit);
    getLimitVisit(paramLimitVisit);
    getCabang();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      currVer = packageInfo.version;
      // String buildNumber = packageInfo.buildNumber;
    });

    if (Platform.isAndroid) {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.60/update apk/updateLog.xml'));

      if (readDoc.statusCode == 200) {
        //parsing readDoc
        final document = xml.XmlDocument.parse(readDoc.body);
        final cLog = document.findElements('items').first;
        latestVer = cLog.findElements('versi').first.innerText;
        if (latestVer != currVer) {
          checkForUpdates("onInit");
        }
      }
    } else {}

    _startDateStream();
  }

  void _startDateStream() {
    // Buat Stream yang mengeluarkan tanggal setiap detik
    final dateStream =
        Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

    // Perbarui nilai tanggal di _dateStream setiap kali Stream mengeluarkan nilai baru
    dateStream.listen((date) {
      _dateStream.value = date;
      tglStream.value = date;
      // print(DateFormat('yyyy-MM-dd').format(tglStream.value));
    });
  }

  @override
  void onClose() {
    super.dispose();
    filterAbsen.dispose();
    filterVisit.dispose();
    date1.dispose();
    date2.dispose();
    _dateStream.close();
  }

  Future<List<Cabang>> getCabang() async {
    final response = await ServiceApi().getCabang({});
    return cabang.value = response;
  }

  Future<List<User>> getUserCabang(String idStore) async {
    final response = await ServiceApi().getUserCabang(idStore);
    return userCabang.value = response;
  }

  timeNetwork(String timeZone) async {
    try {
      final response = await http
          .get(Uri.parse(
              'https://timeapi.io/api/Time/current/zone?timeZone=$timeZone'))
          .then((data) => jsonDecode(data.body));
      timeNow = response['time'];
      // timeNow = DateFormat('HH:mm').format(DateTime.now()).toString();

      dateNowServer = response['dateTime'];
    } on HandshakeException catch (_) {
      // print(e.toString());
    }
  }

  getLoc(List<dynamic>? dataUser) async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();

    try {
      final deviceNames = DeviceMarketingNames();
      // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      // if (Platform.isAndroid) {
         devInfo.value = await deviceNames.getSingleName();
        // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // devInfo.value = '${androidInfo.brand} ${androidInfo.model}';
      // } else {
      //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      //   devInfo.value = '${iosInfo.name} ${iosInfo.model}';
      // }
      // ignore: empty_catches
    } on PlatformException {}

    Position position = await determinePosition();

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    lokasi.value =
        '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
    // userPostLat.value = position.latitude;
    // userPostLong.value = position.longitude;

    if (position.isMocked == true) {
      dialogMsgCncl('Peringatan',
          'Anda terdeteksi menggunakan\nlokasi palsu\nHarap matikan lokasi palsu');
    } else {
      timeNetwork(currentTimeZone);
      dialogAbsenView(dataUser, position.latitude, position.longitude);
    }
  }

  Future<CekAbsen> cekDataAbsen(
      String status, String id, String tglAbsen) async {
    var data = {
      "status": status,
      "id_user": id,
      "tanggal_masuk": tglAbsen,
      "tanggal_pulang": DateFormat('yyyy-MM-dd').format(tglStream.value)
    };
    final response = await ServiceApi().cekDataAbsen(data);
    cekAbsen.value = response;

    dateAbsen = cekAbsen.value.tanggalMasuk != null
        ? cekAbsen.value.tanggalMasuk!
        : dateNow;
    return cekAbsen.value;
  }

  Future<CekVisit> cekDataVisit(
      String status, String id, String tglVisit, String storeCode) async {
    var data = {
      "status": status,
      "id_user": id,
      "tgl_visit": tglVisit,
      "branch_code": storeCode
    };
    final response = await ServiceApi().cekDataVisit(data);
    cekVisit.value = response;
    return cekVisit.value;
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
        lokasi.value = "Lokasi Anda tidak diketahui";
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

      var loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // timeLimit: const Duration(seconds: 10),
        // forceAndroidLocationManager: true
        //
      );
      loc.isMocked;
      Get.back();
      return loc;
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

  Future<List<Visit>> getAllVisited(String id) async {
    var param = {
      "mode": "",
      "id_user": id,
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };
    final response = await ServiceApi().getVisit(param);
    dataAllVisit.value = response;
    isLoading.value = false;
    return dataAllVisit;
  }

  filterDataAbsen(String data) {
    List<Absen> result = [];

    if (data.isEmpty) {
      result = dataAllAbsen;
    } else {
      result = dataAllAbsen
          .where((e) => e.tanggalMasuk
              .toString()
              .toLowerCase()
              .contains(data.toLowerCase()))
          .toList();
    }
    searchAbsen.value = result;
  }

  filterDataVisit(String data) {
    List<Visit> result = [];

    if (data.isEmpty) {
      result = dataAllVisit;
    } else {
      result = dataAllVisit
          .where((e) => e.namaCabang
              .toString()
              .toLowerCase()
              .contains(data.toLowerCase()))
          .toList();
    }
    searchVisit.value = result;
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

  Future<List<Visit>> getFilteredVisit(idUser) async {
    if (date1.text != "" && date2.text != "") {
      var data = {
        "mode": "filtered",
        "id_user": idUser,
        "tanggal1": date1.text,
        "tanggal2": date2.text,
      };
      loadingDialog("Sedang memuat data...", "");
      final response = await ServiceApi().getFilteredVisit(data);
      dataAllVisit.value = response;
      isLoading.value = false;
      searchDate.value =
          '${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date1.text))} - ${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date2.text))} ';
      Get.back();
      Get.back();
    } else {
      showToast("Harap masukkan tanggal untuk mencari data");
    }
    return dataAllVisit;
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
        latestVer = itemsNode.findElements('versi').first.innerText;
        //start looping item on readDoc
        updateList.clear();
        for (final listUpdates in updates) {
          final name = listUpdates.findElements('name').first.innerText;
          final desc = listUpdates.findElements('desc').first.innerText;
          final icon = listUpdates.findElements('icon').first.innerText;
          final color = listUpdates.findElements('color').first.innerText;

          updateList
              .add({'name': name, 'desc': desc, 'icon': icon, 'color': color});
        }
        //end loop item on readDoc
        if (latestVer == currVer) {
          if (status != "onInit") {
            Get.back(closeOverlays: true);
            succesDialog(Get.context!, "N", "Tidak ada pembaruan sistem");
          }
        } else {
          dialogUpdateApp();
        }
      } else {
        succesDialog(Get.context!, "N", "Tidak ada pembaruan sistem");
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

  getVisitToday(Map<String, dynamic> paramSingleVisit) async {
    final response = await ServiceApi().getVisit(paramSingleVisit);
    return dataVisit.value = response;
  }

  getLimitVisit(Map<String, dynamic> paramLimitVisit) async {
    final response = await ServiceApi().getLimitVisit(paramLimitVisit);
    isLoading.value = false;
    return dataLimitVisit.value = response;
  }
}
