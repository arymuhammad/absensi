import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import 'dart:io';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/model/cek_visit_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/data/model/visit_model.dart';
import 'package:absensi/app/modules/home/views/dialog_update_app.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_face_api/flutter_face_api.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xml/xml.dart' as xml;
import '../../../data/helper/loading_progress.dart';
import '../../../data/helper/time_service.dart';
import '../../../data/model/login_model.dart';
import '../../../services/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/absen_model.dart';
import '../../../data/model/cabang_model.dart';
import '../../../data/model/cek_absen_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:device_info_null_safety/device_info_null_safety.dart';

import '../../login/controllers/login_controller.dart';
import '../views/widget/custom_qr_page.dart';
// import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class AbsenController extends GetxController with GetTickerProviderStateMixin {
  var isLoading = true.obs;
  var ascending = true.obs;
  var lokasi = "".obs;
  // var devInfoWeb = "".obs;
  var devInfo = "".obs;
  var cekAbsen = CekAbsen().obs;
  var cekVisit =
      CekVisit(total: '', tglVisit: '', kodeStore: '', namaStore: '').obs;
  // var stsAbsen = ['', 'Check In', 'Check Out', 'Break Start', 'Break End'];
  var stsAbsen = ['', 'Check In', 'Check Out'];
  var optVisit = ['', 'Research and Development', 'Store Visit'];
  var optVisitSelected = "".obs;
  var stsAbsenSelected = "".obs;
  var optVisitVisible = true.obs;
  var dataAbsen = <Absen>[].obs;
  var dataVisit = <Visit>[].obs;
  var dataLimitAbsen = <Absen>[].obs;
  var dataLimitVisit = <Visit>[].obs;
  var dataAllAbsen = <Absen>[].obs;
  var dataAllVisit = <Visit>[].obs;
  var shiftKerja = <ShiftKerja>[].obs;
  var cabang = <Cabang>[].obs;
  var userCabang = <User>[].obs;
  var idUser = "".obs;
  var msg = "".obs;
  var selectedShift = "".obs;
  var selectedCabang = "".obs;
  var selectedUserCabang = "".obs;
  var userMonitor = "".obs;
  var selectedCabangVisit = "".obs;
  var distanceStore = 0.0.obs;
  var locNote = "".obs; // keterangan lokasi (dalam radius/diluar radius)
  var lat = "".obs; // tampung koordinat lat dari store yang dipilih
  var long = "".obs; // tampung koordinat long dari store yang dipilih
  var latFromGps = 0.0.obs; // tampung koordinat lat dari gps device
  var longFromGps = 0.0.obs; // tampung koordinat long dari gps device
  Rx<LatLng?> validatedQrLatLng = Rx<LatLng?>(null);

  // var userPostLat = 0.0.obs;
  // var userPostLong = 0.0.obs;
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  var timeNow = "";
  // var timeNowOpt = DateFormat('HH:mm').format(DateTime.now()).toString();
  // var dateNowServer = "";
  var tglStream = DateTime.now().obs;
  var dateAbsen = "";
  var downloadProgress = 0.0.obs;
  var updateList = [];
  var currVer = "";
  var latestVer = "";
  // var supportedAbi = "";
  var statsCon = "".obs;
  RxList<Absen> searchAbsen = RxList<Absen>([]);
  RxList<Visit> searchVisit = RxList<Visit>([]);
  late TextEditingController date1, date2, store, userCab, rndLoc;
  final TextEditingController filterAbsen = TextEditingController();
  final TextEditingController filterVisit = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? image;

  var searchDate = "".obs;
  var calendarFormat = CalendarFormat.month.obs;
  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rx<DateTime?> rangeStart = Rx<DateTime?>(null);
  final Rx<DateTime?> rangeEnd = Rx<DateTime?>(null);
  final Rx<RangeSelectionMode> rangeSelectionMode = Rx(
    RangeSelectionMode.toggledOff,
  );

  var thisMonth =
      DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()).toString();
  var initDate1 =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
            ),
          )
          .toString();
  var initDate2 =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                0,
              ).toString(),
            ),
          )
          .toString();
  DateTime? lastTime;
  final _dateStream = Rx<DateTime?>(null);
  late StreamSubscription _sub;
  var remainingSec = 30.obs;
  var timerStat = false.obs;
  File? capturedImage;
  var barcodeScanRes = ''.obs;
  var scannedLatLng = Rx<LatLng?>(null);
  final isEnabled = true.obs;
  int maxRetries = 3;

  final RxBool mustCheckoutYesterday = false.obs;
  final RxBool isCheckingAbsen = false.obs;
  final RxString searchKeyword = ''.obs;
  DateTime? timeServer;
  String? realDateServer;
  String? realTimeServer;
  late AnimationController animController;

  var progress = 1.0.obs;
  final durationSeconds = 20.obs;
  var secondsLeft = 20.obs;
  var progressColor = Colors.green.obs;

  final mapController = MapController();
  RxDouble currentZoom = 17.0.obs;
  RxBool isInsideRadius = false.obs;
  String lastZoomMode = "";
  Rxn<LatLng> storeLatLng = Rxn<LatLng>();

  final lineProgress = 0.0.obs;

  var isMapReady = false.obs;

  @override
  void onInit() async {
    super.onInit();
    date1 = TextEditingController();
    date2 = TextEditingController();
    store = TextEditingController();
    userCab = TextEditingController();
    rndLoc = TextEditingController();
    selectedDate.value = null;
    timeServer = await getServerTimeLocal();
    realDateServer = DateFormat('yyyy-MM-dd').format(timeServer!);
    realTimeServer = DateFormat('HH:mm').format(timeServer!);

    // Timer.periodic(const Duration(seconds: 1), (Timer t) async => timeNowOpt);

    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = Data.fromJson(
      jsonDecode(pref.getString('userDataLogin')!),
    );
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;

    storeLatLng.value = LatLng(
      double.parse(dataUserLogin.lat!),
      double.parse(dataUserLogin.long!),
    );
    refreshAbsen(dataUserLogin);
    idUser.value = dataUserLogin.id!;
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2,
    };

    var paramLimitVisit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2,
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tanggal_masuk": realDateServer,
    };

    var paramSingleVisit = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tgl_visit": realDateServer,
    };

    searchAbsen.value = dataAllAbsen;
    searchVisit.value = dataAllVisit;

    if (dataUserLogin.visit == "0") {
      getAbsenToday(paramSingle);
      getLimitAbsen(paramLimit);
    } else {
      getVisitToday(paramSingleVisit);
      getLimitVisit(paramLimitVisit);
    }
    getCabang();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currVer = packageInfo.version;

    // print('VERSI SEKARANG $currVer');

    final readDoc = await http.get(
      Uri.parse('http://103.156.15.61/update_apk/updateLog.xml'),
    );

    if (readDoc.statusCode == 200) {
      //parsing readDoc
      final document = xml.XmlDocument.parse(readDoc.body);
      final cLog = document.findElements('items').first;
      latestVer = cLog.findElements('versi').first.innerText;
      if (compareVersion(latestVer, currVer) > 0) {
        if (Platform.isAndroid) {
          // final DeviceInfoNullSafety deviceInfoNullSafety =
          //     DeviceInfoNullSafety();
          // Map<String, dynamic> abiInfo = await deviceInfoNullSafety.abiInfo;
          // var abi = abiInfo.entries.toList();
          // supportedAbi = abi[1].value;
          checkForUpdates("onInit");
        }
        // disable redirect to appstore for ios when update is available
        // else {
        //   launchUrl(
        //     Uri.parse(
        //       'https://apps.apple.com/us/app/urbanco-spot/id6476486235',
        //     ),
        //   );
        // }
      }
    }

    _startDateStream(
      paramSingle,
      paramLimit,
      paramSingleVisit,
      paramLimitVisit,
      dataUserLogin,
    );

    animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSeconds.value),
    );
    animController.addListener(() {
      progress.value = 1 - animController.value;
      final total = durationSeconds.value;

      secondsLeft.value = (total - (total * animController.value)).ceil();

      double p = progress.value;

      if (p > 0.5) {
        progressColor.value = Colors.green;
      } else if (p > 0.2) {
        progressColor.value = Colors.orange;
      } else {
        progressColor.value = Colors.red;
      }
    });

    everAll([lat, long, scannedLatLng, latFromGps, longFromGps], (_) {
      if (!isMapReady.value) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerSmartZoom(dataUserLogin);
      });
    });
  }

  @override
  void onClose() {
    date1.dispose();
    date2.dispose();
    store.dispose();
    userCab.dispose();
    rndLoc.dispose();
    filterVisit.dispose();
    _dateStream.close();
    animController.dispose();
    super.onClose();
  }

  void startLoading({
    int seconds = 20,
    String title = "Finding your location",
  }) {
    durationSeconds.value = seconds;
    secondsLeft.value = seconds;

    animController.duration = Duration(seconds: seconds);
    animController.forward(from: 0);

    showLoadingDialog(title);
  }

  void stopLoading() {
    animController.stop();
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void showLoadingDialog(String title) {
    Get.dialog(LoadingDialog(title: title), barrierDismissible: false);
  }

  bool get isBeforeCheckoutLimitNow {
    final now = timeServer;
    return now!.isBefore(DateTime(now.year, now.month, now.day, 09, 1));
  }

  Future<void> refreshAbsen(Data data) async {
    isCheckingAbsen.value = true;

    try {
      if (!isBeforeCheckoutLimitNow) {
        mustCheckoutYesterday.value = false;
        return;
      }

      final now = timeServer;
      final previousDate = DateFormat(
        'yyyy-MM-dd',
      ).format(now!.subtract(const Duration(days: 1)));

      await cekDataAbsen("pulang", data.id!, previousDate);

      mustCheckoutYesterday.value =
          cekAbsen.value.total == "1" && cekAbsen.value.idShift != "0";
    } finally {
      isCheckingAbsen.value = false;
    }
  }

  /// 🔥 PANGGIL INI SETIAP DATA ABSEN BERUBAH
  Future<void> invalidateAbsen(Data data) async {
    await refreshAbsen(data);
  }

  Future<void> resetAbsenToday(Data data) async {
    final today = realDateServer;

    // Reset state penting
    cekAbsen.value = CekAbsen();
    stsAbsenSelected.value = "";
    selectedShift.value = "";
    mustCheckoutYesterday.value = false;
    isCheckingAbsen.value = false;
    // Reload data absen hari ini
    await getAbsenToday({
      "mode": "single",
      "id_user": data.id,
      "tanggal_masuk": today,
    });
  }

  void resetFilter() {
    searchKeyword.value = "";
    searchDate.value = "";
  }

  int compareVersion(String v1, String v2) {
    List<String> parts1 = v1.split('.');
    List<String> parts2 = v2.split('.');

    int length =
        (parts1.length > parts2.length) ? parts1.length : parts2.length;

    for (int i = 0; i < length; i++) {
      int p1 = (i < parts1.length) ? int.tryParse(parts1[i]) ?? 0 : 0;
      int p2 = (i < parts2.length) ? int.tryParse(parts2[i]) ?? 0 : 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0; // sama
  }

  void startTimer(int sec) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sec > 0) {
        remainingSec.value = sec;
        sec--;
        timerStat.value = true;
      } else {
        timer.cancel();
        timerStat.value = false;
      }
    });
  }

  void _startDateStream(
    paramSingle,
    paramLimit,
    paramSingleVisit,
    paramLimitVisit,
    Data dataUserLogin,
  ) {
    // Buat Stream yang mengeluarkan tanggal setiap detik
    final dateStream = Stream.periodic(
      const Duration(seconds: 5),
      (_) => DateTime.now(),
    );
    // Perbarui nilai tanggal di _dateStream setiap kali Stream mengeluarkan nilai baru
    _sub = dateStream.listen((date) async {
      _dateStream.value = date;
      tglStream.value = date;

      if (dataUserLogin.visit == "0") {
        // start cek absen

        var tempDataAbs = await SQLHelper.instance.getAllAbsenToday(
          realDateServer!,
        );

        await cekDataAbsen("masuk", idUser.value, realDateServer!);

        if (cekAbsen.value.total == "0") {
          if (tempDataAbs.isNotEmpty) {
            for (var i in tempDataAbs) {
              var data = {
                "status": "add",
                "id": i.idUser!,
                "tanggal_masuk": i.tanggalMasuk!,
                "kode_cabang": i.kodeCabang!,
                "nama": i.nama!,
                "id_shift": i.idShift!,
                "jam_masuk": i.jamMasuk!,
                "jam_pulang": i.jamPulang!,
                "jam_absen_masuk": i.jamAbsenMasuk!,
                "foto_masuk": File(i.fotoMasuk!),
                "lat_masuk": i.latMasuk!,
                "long_masuk": i.longMasuk!,
                "device_info": i.devInfo!,
              };
              // submit data absensi ke server
              // log(data.toString());
              await ServiceApi().submitAbsen(data, true);
            }
            getAbsenToday(paramSingle);
            getLimitAbsen(paramLimit);
            _sub.cancel();
          } else {
            _sub.cancel();
          }
        } else {
          await cekDataAbsen("pulang", idUser.value, realDateServer!);
          if (cekAbsen.value.total == "1") {
            if (tempDataAbs.isNotEmpty &&
                tempDataAbs.first.tanggalPulang != null) {
              for (var i in tempDataAbs) {
                var data = {
                  "status": "update",
                  "id": i.idUser!,
                  "tanggal_masuk": i.tanggalMasuk!,
                  "tanggal_pulang": i.tanggalPulang!,
                  "nama": i.nama!,
                  "jam_absen_pulang": i.jamAbsenPulang!,
                  "foto_pulang": File(i.fotoPulang!),
                  "lat_pulang": i.latPulang!,
                  "long_pulang": i.longPulang!,
                  "device_info2": i.devInfo2!,
                };
                await ServiceApi().submitAbsen(data, true);
              }
              getAbsenToday(paramSingle);
              getLimitAbsen(paramLimit);
              _sub.cancel();
            } else {
              _sub.cancel();
            }
          } else {
            _sub.cancel();
          }
        }
        // urut.value++;
        // end cek absen
      } else {
        // cek visit

        var tempDataVisit = await SQLHelper.instance.getVisitToday(
          idUser.value,
          realDateServer!,
          '',
          0,
        );

        if (tempDataVisit.isNotEmpty) {
          await cekDataVisit(
            tempDataVisit.isNotEmpty && tempDataVisit.length == 1
                ? "masuk"
                : "masukv2",
            idUser.value,
            realDateServer!,
            tempDataVisit.isNotEmpty && tempDataVisit.length == 1
                ? tempDataVisit.first.visitIn!
                : '',
          );

          if (cekVisit.value.total == "0" ||
              int.parse(cekVisit.value.total) < tempDataVisit.length) {
            if (tempDataVisit.isNotEmpty) {
              for (var i in tempDataVisit) {
                var data = {
                  "status": "add",
                  "id": i.id!,
                  "nama": i.nama!,
                  "tgl_visit": i.tglVisit!,
                  "visit_in": i.visitIn!,
                  "jam_in": i.jamIn!,
                  // "foto_in": File(i.fotoIn!.toString()),
                  "foto_in": File(i.fotoIn!),
                  "lat_in": i.latIn!,
                  "long_in": i.longIn!,
                  "device_info": i.deviceInfo!,
                  "is_rnd": i.isRnd!,
                };
                // log(data.toString());
                await ServiceApi().submitVisit(data, true);
              }
              getVisitToday(paramSingleVisit);
              getLimitVisit(paramLimitVisit);
              _sub.cancel();
            } else {
              // timerStat.value = false;
              // startTimer(0);
              _sub.cancel();
            }
          } else {
            await cekDataVisit(
              tempDataVisit.length == 1 ? "pulang" : "pulangv2",
              idUser.value,
              realDateServer!,
              tempDataVisit.length == 1 ? tempDataVisit.first.visitIn! : '',
            );

            if (int.parse(cekVisit.value.total) > 0) {
              if (tempDataVisit.first.jamOut != "") {
                for (var i in tempDataVisit) {
                  var data = {
                    "status": "update",
                    "id": i.id!,
                    "nama": i.nama!,
                    "tgl_visit": i.tglVisit!,
                    "visit_out": i.visitOut!,
                    "visit_in": i.visitIn!,
                    "jam_in": i.jamIn!,
                    "jam_out": i.jamOut!,
                    // "foto_out": File(i.fotoOut!.toString()),
                    "foto_out": File(i.fotoOut!),
                    "lat_out": i.latOut!,
                    "long_out": i.longOut!,
                    "device_info2": i.deviceInfo2!,
                  };

                  await ServiceApi().submitVisit(data, true);
                }
                getVisitToday(paramSingleVisit);
                getLimitVisit(paramLimitVisit);
                _sub.cancel();
              } else {
                _sub.cancel();
              }
            } else {
              _sub.cancel();
            }
          }
        } else {
          _sub.cancel();
        }
      }
    });
  }

  Future<List<Cabang>> getCabang() async {
    var tempCabang = await SQLHelper.instance.getCabang();
    if (tempCabang.isNotEmpty) {
      return cabang.value = tempCabang;
    } else {
      final response = await ServiceApi().getCabang({});
      cabang.value = response;
      cabang
          .map(
            (e) async => await SQLHelper.instance.insertCabang(
              Cabang(
                kodeCabang: e.kodeCabang,
                brandCabang: e.brandCabang,
                namaCabang: e.namaCabang,
                lat: e.lat,
                long: e.long,
              ),
            ),
          )
          .toList();
      return cabang;
    }
  }

  Future<List<User>> getUserCabang(String idStore, String parentId) async {
    final response = await ServiceApi().getUserCabang(idStore, parentId);
    return userCabang.value = response;
  }

  getLoc(Data? dataUser) async {
    startLoading(seconds: 20);
    Position position = await determinePosition();
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
    // print(position.isMocked);
    // if (position.isMocked == true) {
    //   isLoading.value = false;
    //   failedDialog(
    //     Get.context,
    //     'Warning',
    //     'You have been detected using\nfake location\nPlease turn off fake location',
    //   );
    // } else {
    // try {
    //   List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude,
    //     position.longitude,
    //   ).timeout(const Duration(seconds: 15));

    //   lokasi.value =
    //       '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
    //   // print(lokasi.value);
    // } on TimeoutException {
    //   isLoading.value = false;
    //   showToast("Failed to get location, please try again.");
    //   return Future.error('Timeout while getting location');
    // } catch (e) {
    //   isLoading.value = false;
    //   isEnabled.value = false;
    //   showToast("There is an error: $e");
    //   return Future.error(e.toString());
    // }
    // timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
    latFromGps.value = position.latitude;
    longFromGps.value = position.longitude;

    //cek user visit atau bukan
    if (optVisitSelected.isNotEmpty &&
        optVisitSelected.value == "Research and Development") {
      isEnabled.value = true;
      locNote.value = "";
    } else {
      await calcDistanceBetween(
        LatLng(
          double.parse(lat.isNotEmpty ? lat.value : dataUser!.lat!),
          double.parse(long.isNotEmpty ? long.value : dataUser!.long!),
        ),
        LatLng(position.latitude, position.longitude),
      );

      if (distanceStore.value > num.parse(dataUser!.areaCover!)) {
        isLoading.value = false;
        isEnabled.value = false;
        locNote.value =
            "Your position is far from the permitted area (${(distanceStore.value / 1000).toStringAsFixed(2)} Km)";
      } else {
        isLoading.value = false;
        isEnabled.value = true;
        locNote.value = "You are in the radius area";
      }
    }

    barcodeScanRes.value = "";
    isLoading.value = false;
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
        // Get.back();
        stopLoading();
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
          isLoading.value = false;
          isEnabled.value = false;
          showToast("Izin Lokasi ditolak");
          // Get.back();
          stopLoading();
          return Future.error('Location permissions are denied');
        }
        // await Future.delayed(const Duration(milliseconds: 400));
        // Get.back();
      }
      // await Future.delayed(const Duration(milliseconds: 400));

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        isLoading.value = false;
        isEnabled.value = false;
        showToast(
          "Izin Lokasi ditolak.\nHarap berikan akses pada perizinan lokasi",
        );
        // Get.back();
        stopLoading();
        return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      // Pakai last known position dulu
      // Position? lastKnown = await Geolocator.getLastKnownPosition();
      // if (lastKnown != null) {
      //   lokasi.value =
      //       "Posisi sementara: (${lastKnown.latitude}, ${lastKnown.longitude})";
      // }

      Position loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
        // forceAndroidLocationManager: true
        //
      );
      // print(loc.latitude);
      // print(loc.longitude);
      if (loc.isMocked) {
        isLoading.value = false;
        isEnabled.value = false;
        failedDialog(
          Get.context,
          'Warning',
          'You have been detected using\nfake location',
        );
        // Get.back();
      }
      stopLoading();
      return loc;
    } on TimeoutException {
      isLoading.value = false;
      isEnabled.value = false;
      // Get.back(); // Tutup loading
      showToast("Failed to get location, please try again.");
      // Get.back();
      stopLoading();
      return Future.error('Timeout while getting location');
    } catch (e) {
      Get.back();
      isLoading.value = false;
      isEnabled.value = false;
      showToast("There is an error: $e");
      stopLoading();
      return Future.error(e.toString());
    }
  }

  calcDistanceBetween(LatLng a, LatLng b) {
    double distance = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    return distanceStore.value = distance;
  }

  scanQrLoc(Data? dataUser) async {
    // String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // barcodeScanRes.value = await FlutterBarcodeScanner.scanBarcode(
      //   '#ff6666',
      //   'Cancel',
      //   false,
      //   ScanMode.QR,
      // );
      // String? result =
      await Get.to(
        () => CustomQrScannerPage(
          onDetect: (code) {
            // print('ini lokasi QR $code');
            barcodeScanRes.value = code;
          },
        ),
      );
      isLoading.value = false;
      isEnabled.value = false;
      distanceStore.value = 0.0;
      lokasi.value = "Unknown, please try again";
      locNote.value = "";

      Get.back();

      if (barcodeScanRes.isNotEmpty &&
          ((barcodeScanRes.value.split(' ').length > 2 &&
                  barcodeScanRes.value.split(' ')[2] != "URBAN&CO") ||
              barcodeScanRes.isNotEmpty &&
                  barcodeScanRes.value.split(' ').length < 3)) {
        selectedCabang.value = "";
        selectedCabangVisit.value = "";
        isLoading.value = false;
        isEnabled.value = false;
        distanceStore.value = 0.0;
        barcodeScanRes.value = "";
        lokasi.value = "Unknown, please try again";
        locNote.value = "";
        showToast("Unrecognized QR Code");
        if (lat.isNotEmpty && long.isNotEmpty) {
          storeLatLng.value = LatLng(
            double.parse(lat.value),
            double.parse(long.value),
          );
        }
      } else {
       
        // List<Placemark> placemarks = await placemarkFromCoordinates(
        //   double.parse(barcodeScanRes.value.split(' ')[0]),
        //   double.parse(barcodeScanRes.value.split(' ')[1]),
        // );
        // lokasi.value =
        //     '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';

        scannedLatLng.value = LatLng(
          double.parse(barcodeScanRes.value.split(' ')[0]),
          double.parse(barcodeScanRes.value.split(' ')[1]),
        );
        // 🔥 Paksa circle tetap tampil
        storeLatLng.value = scannedLatLng.value;

        // Step 2: Dapatkan posisi user
        startLoading(seconds: 15, title: 'Validating your QR code');
        // loadingDialog(, '');
        Position userPosition;
        try {
          userPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15),
          );
          // Get.back();
          stopLoading();
        } catch (e) {
          // Get.back();
          stopLoading();
          showToast('Failed to get location! Make sure GPS is active.');
          // ScaffoldMessenger.of(Get.context!).showSnackBar(
          //   const SnackBar(
          //     content: Text("Gagal mendapatkan lokasi! Pastikan GPS aktif"),
          //   ),
          // );
          return;
        }
        // Step 3: Hitung jarak user ke koordinat QR
        double distanceMeter = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          double.parse(barcodeScanRes.value.split(' ')[0]),
          double.parse(barcodeScanRes.value.split(' ')[1]),
        );

        // Step 4: Validasi

        // getCoveredQR(kodeCabang: barcodeScanRes.value.split(' ')[3]);

        // print(distanceMeter);
        // print(num.parse(dataUser!.areaCoverQR!));
        final allowedRadius = await getCoveredQR(
          kodeCabang: barcodeScanRes.value.split(' ')[3],
        );

        if (distanceMeter <= allowedRadius) {
          // dataUser!.visit == "1"
          // ?
          if (dataUser!.visit == "1") {
            selectedCabangVisit.value = barcodeScanRes.value.split(' ')[3];
          } else {
            selectedCabang.value = barcodeScanRes.value.split(' ')[3];
          }

          // print(selectedCabangVisit.value);
          // print(selectedCabang.value);
          // print(barcodeScanRes.value.split(' ')[3]);
          // kode lama
          // latFromGps.value = userPosition.latitude;
          // longFromGps.value = userPosition.longitude;
          validatedQrLatLng.value = LatLng(
            userPosition.latitude,
            userPosition.longitude,
          );
          isLoading.value = false;
          isEnabled.value = true;
          locNote.value = "You are in the radius area";
          showToast(
            'Location validation successful. You are within the QR code area.',
          );

         
          updateCircleFromQr(barcodeScanRes.value);

          refreshZoom(dataUser);

          // Lanjutkan proses absensi/kehadiran
        } else {
          selectedCabang.value = "";
          selectedCabangVisit.value = "";
          barcodeScanRes.value = "";
          isLoading.value = false;
          isEnabled.value = false;
          locNote.value =
              "You are outside the QR area (${(distanceMeter / 1000).toStringAsFixed(2)} Km)";
          distanceStore.value = distanceMeter;
          showToast('Validation failed!');
          
          updateCircleFromQr(barcodeScanRes.value);

          refreshZoom(dataUser!);

          // Tolak absensi/scan, bisa kasih opsi retry
        }
      }
    } on PlatformException {
      barcodeScanRes.value = 'Failed to get platform version.';
    }
  }

  Future<num> getCoveredQR({required String kodeCabang}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ServiceApi().baseUrl}get_covered_qr?kode_cabang=$kodeCabang',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Server error ${response.statusCode}");
      }

      final result = jsonDecode(response.body);

      if (result['success'] != true || result['data'] == null) {
        throw Exception("Invalid response");
      }

      return num.parse(result['data']['area_coverage_qr']);
    } catch (e) {
      showToast("Failed to get QR radius");
      return 0; // fallback aman
    }
  }

  Future<CekAbsen> cekDataAbsen(
    String status,
    String id,
    String tglAbsen,
  ) async {
    var data = {
      "status": status,
      "id_user": id,
      "tanggal_masuk": tglAbsen,
      "tanggal_pulang": DateFormat('yyyy-MM-dd').format(tglStream.value),
    };
    // print(data);
    final response = await ServiceApi().cekDataAbsen(data);
    cekAbsen.value = response;

    dateAbsen =
        cekAbsen.value.tanggalMasuk != null
            ? cekAbsen.value.tanggalMasuk!
            : realDateServer!;
    return cekAbsen.value;
  }

  Future<CekVisit> cekDataVisit(
    String status,
    String id,
    String tglVisit,
    String storeCode,
  ) async {
    var data = {
      "status": status,
      "id_user": id,
      "tgl_visit": tglVisit,
      "branch_code": storeCode,
    };
    final response = await ServiceApi().cekDataVisit(data);
    cekVisit.value = response;
    return cekVisit.value;
  }

  exportPdf() async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final List<pw.TableRow> rows = await _loadData();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          pageFormat: PdfPageFormat.a4.landscape,
        ),
        build:
            (context) => [
              pw.Center(
                child: pw.Table(border: pw.TableBorder.all(), children: rows),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<List<pw.TableRow>> _loadData() async {
    List<pw.TableRow> rows = [];
    final font = await PdfGoogleFonts.nunitoRegular();

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue700),
        children: [
          pw.Text(
            'Tanggal',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Cabang',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Nama',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Shift',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Masuk',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Foto',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Status Masuk',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Keluar',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Foto',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Status Keluar',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
        ],
      ),
    );

    for (var data in searchAbsen) {
      pw.MemoryImage? imageMasuk;
      if (data.fotoMasuk! != "") {
        final img1 = await http
            .get(Uri.parse('${ServiceApi().baseUrl}${data.fotoMasuk!}'))
            .then((value) => value.bodyBytes);
        imageMasuk = pw.MemoryImage(img1);
      }
      // // print('${img1.bodyBytes}');
      pw.MemoryImage? imageKeluar;
      if (data.fotoPulang! != "") {
        final img2 = await http.get(
          Uri.parse('${ServiceApi().baseUrl}${data.fotoPulang!}'),
        );
        imageKeluar = pw.MemoryImage(img2.bodyBytes);
      }

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.parse(data.tanggalMasuk!)),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            ),
            pw.Text(
              data.namaCabang!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              data.nama!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              data.namaShift!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              data.jamAbsenMasuk!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            data.fotoMasuk! != ""
                ? pw.Container(
                  width: 30,
                  height: 30,
                  child: pw.Center(child: pw.Image(imageMasuk!)),
                )
                : pw.Container(width: 30, height: 30),
            pw.Text(
              DateFormat("HH:mm")
                      .parse(data.jamAbsenMasuk!)
                      .isBefore(DateFormat("HH:mm").parse(data.jamMasuk!))
                  ? "Awal Waktu"
                  : "Telat",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              data.jamAbsenPulang!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            data.fotoPulang! != ""
                ? pw.Container(
                  width: 30,
                  height: 30,
                  child: pw.Center(child: pw.Image(imageKeluar!)),
                )
                : pw.Container(width: 30, height: 30),
            pw.Text(
              data.jamAbsenPulang! == ""
                  ? "Belum Absen"
                  : DateFormat("HH:mm")
                      .parse(data.jamAbsenPulang!)
                      .isBefore(DateFormat("HH:mm").parse(data.jamPulang!))
                  ? "Pulang Cepat"
                  : "Lembur",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  Future<void> uploadFotoAbsen() async {
    image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxHeight: 600,
      maxWidth: 600,
    );

    if (image != null) {
      // var img = base64.encode(File(image!.path).readAsBytesSync());
      // log(image!.path, name: 'PATH');
      update();
    } else {
      return;
    }
  }

  Future<List<ShiftKerja>> getShift() async {
    var tempShift = await SQLHelper.instance.getShift();
    if (tempShift.isNotEmpty) {
      return shiftKerja.value = tempShift;
    } else {
      final response = await ServiceApi().getShift();
      shiftKerja.value = response;
      shiftKerja
          .map(
            (e) async => await SQLHelper.instance.insertShift(
              ShiftKerja(
                id: e.id,
                namaShift: e.namaShift,
                jamMasuk: e.jamMasuk,
                jamPulang: e.jamPulang,
              ),
            ),
          )
          .toList();

      return shiftKerja;
    }
  }

  getAbsenToday(paramAbsen) async {
    final response = await ServiceApi().getAbsen(paramAbsen);

    var tempDataAbs = await SQLHelper.instance.getAbsenToday(
      idUser.value,
      realDateServer!,
    );
    dataAbsen.value = tempDataAbs;

    if (tempDataAbs.isNotEmpty) {
      if (response.isNotEmpty && response[0].jamAbsenPulang != "") {
        dataAbsen.value = response;
      } else if (response.isNotEmpty &&
              response[0].jamAbsenMasuk != tempDataAbs[0].jamAbsenMasuk! ||
          response.isNotEmpty &&
              response[0].idShift != tempDataAbs[0].idShift!) {
        dataAbsen.value = response;
      } else {
        dataAbsen.value = tempDataAbs;
      }
    } else {
      isLoading.value = false;
      dataAbsen.value = response;
    }

    return dataAbsen;
  }

  Future<List<Absen>> getLimitAbsen(paramLimitAbsen) async {
    final response = await ServiceApi().getAbsen(paramLimitAbsen);
    dataLimitAbsen.clear();
    // isLoading.value = true;
    var tempSingleAbs = await SQLHelper.instance.getLimitDataAbsen(
      idUser.value,
      initDate1,
      initDate2,
    );

    if (tempSingleAbs.isNotEmpty) {
      if (response.isEmpty ||
          response.isNotEmpty &&
              DateTime.parse(
                response.first.tanggalMasuk!,
              ).isBefore(DateTime.parse(tempSingleAbs.first.tanggalMasuk!)) ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tanggalMasuk!).isAtSameMomentAs(
                DateTime.parse(tempSingleAbs.first.tanggalMasuk!),
              ) &&
              response.first.jamAbsenPulang! == "" &&
              tempSingleAbs.first.jamAbsenPulang! != "") {
        isLoading.value = false;
        dataLimitAbsen.value = tempSingleAbs;
        statsCon.value =
            'Wait for a stable internet connection\nThis data saved on local storage';
        dataLimitAbsen.addAll(response);
      } else {
        isLoading.value = false;
        statsCon.value = "";
        dataLimitAbsen.value = response;
      }
    } else {
      isLoading.value = false;
      statsCon.value = "";
      dataLimitAbsen.value = response;
    }
    return dataLimitAbsen;
  }

  Future<List<Absen>> getAllAbsen(String id, String? d1, String? d2) async {
    var param = {
      "mode": "",
      "id_user": id,
      "tanggal1": d1!.isNotEmpty ? d1 : initDate1,
      "tanggal2": d2!.isNotEmpty ? d2 : initDate2,
    };
    final response = await ServiceApi().getAbsen(param);
    dataAllAbsen.value = response;
    searchAbsen.value = response;
    isLoading.value = false;
    return dataAllAbsen;
  }

  Future<List<Visit>> getAllVisited(String id) async {
    var param = {
      "mode": "",
      "id_user": id,
      "tanggal1": initDate1,
      "tanggal2": initDate2,
    };
    final response = await ServiceApi().getVisit(param);
    dataAllVisit.value = response;
    searchVisit.value = response;
    isLoading.value = false;
    return dataAllVisit;
  }

  List<Absen> get filterDataAbsen {
    final q = searchKeyword.value.toLowerCase();

    if (q.isEmpty) return dataAllAbsen;

    return searchAbsen.where((e) {
      return e.namaCabang!.toLowerCase().contains(q) ||
          e.tanggalMasuk!.toLowerCase().contains(q) ||
          e.jamAbsenMasuk!.contains(q) ||
          e.jamAbsenPulang!.contains(q);
    }).toList();
  }

  List<Visit> get filterDataVisit {
    final q = searchKeyword.value.toLowerCase();

    if (q.isEmpty) return dataAllVisit;
    return searchVisit.where((e) {
      return e.namaCabang!.toLowerCase().contains(q) ||
          e.tglVisit!.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<Absen>> getFilteredAbsen(idUser, d1, d2) async {
    // if (date1.text != "" && date2.text != "") {
    loadingDialog("Sedang memuat data...", "");
    var data = {
      "mode": "filtered",
      "id_user": idUser,
      "tanggal1": d1 != "" ? d1 : date1.text,
      "tanggal2": d2 != "" ? d2 : date2.text,
    };
    final response = await ServiceApi().getFilteredAbsen(data);
    Get.back();
    dataAllAbsen.value = response;
    isLoading.value = false;
    searchDate.value =
        '${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date1.text))} - ${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date2.text))} ';

    return dataAllAbsen;
  }

  Future<List<Visit>> getFilteredVisit(idUser) async {
    if (date1.text != "" && date2.text != "") {
      var data = {
        "mode": "filter",
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
      loadingDialog("Checking for updates...", "");
    }

    try {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.61/update_apk/updateLog.xml'))
          .timeout(const Duration(seconds: 20));
      final response = await http
          .head(
            Uri.parse(
              // supportedAbi == 'arm64-v8a'
              //     ? 'http://103.156.15.61/update apk/absensiApp.arm64v8a.apk'
                  // :
                   'http://103.156.15.61/update_apk/absensiApp.apk',
            ),
          )
          .timeout(const Duration(seconds: 20));

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

          updateList.add({
            'name': name,
            'desc': desc,
            'icon': icon,
            'color': color,
          });
        }
        //end loop item on readDoc
        if (compareVersion(latestVer, currVer) > 0) {
          dialogUpdateApp();
        } else {
          if (status != "onInit") {
            Get.back(closeOverlays: true);
            succesDialog(
              context: Get.context!,
              pageAbsen: "N",
              desc: "No system updates",
              type: DialogType.info,
              title: 'INFO',
              btnOkOnPress: () => Get.back(),
            );
          }
        }
      } else {
        succesDialog(
          context: Get.context!,
          pageAbsen: "N",
          desc: "No system updates",
          type: DialogType.info,
          title: 'INFO',
          btnOkOnPress: () => Get.back(),
        );
      }
    } on SocketException catch (e) {
      Get.back(closeOverlays: true);
      Get.defaultDialog(
        title: e.toString(),
        middleText: 'Check your internet connection',
        textConfirm: 'Refresh',
        confirmTextColor: Colors.white,
        onConfirm: () {
          checkForUpdates("");
          Get.back(closeOverlays: true);
        },
      );
    } on TimeoutException catch (_) {
      Get.back(closeOverlays: true);
      showToast("The connection to the server has timed out.");
    }
  }

  getVisitToday(Map<String, dynamic> paramSingleVisit) async {
    final response = await ServiceApi().getVisit(paramSingleVisit);
    var tempDataVisit = await SQLHelper.instance.getVisitToday(
      idUser.value,
      realDateServer!,
      '',
      1,
    );

    if (tempDataVisit.isNotEmpty) {
      if (response.isNotEmpty &&
          response.first.jamOut != "" &&
          response.first.visitIn! == tempDataVisit.first.visitIn!) {
        dataVisit.value = response;
      } else {
        dataVisit.value = tempDataVisit;
      }
    } else {
      dataVisit.value = response;
    }
    isLoading.value = false;
    return dataVisit;
  }

  getLimitVisit(Map<String, dynamic> paramLimitVisit) async {
    final response = await ServiceApi().getLimitVisit(paramLimitVisit);
    dataLimitVisit.clear();

    var tempLimitVisit = await SQLHelper.instance.getVisitToday(
      idUser.value,
      realDateServer!,
      '',
      0,
    );

    if (tempLimitVisit.isNotEmpty) {
      if (response.isEmpty ||
          response.isNotEmpty &&
              DateTime.parse(
                response.first.tglVisit!,
              ).isBefore(DateTime.parse(tempLimitVisit.first.tglVisit!)) ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tglVisit!).isAtSameMomentAs(
                DateTime.parse(tempLimitVisit.first.tglVisit!),
              ) &&
              response.first.jamOut! == "" &&
              tempLimitVisit.first.jamOut! != "" ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tglVisit!).isAtSameMomentAs(
                DateTime.parse(tempLimitVisit.first.tglVisit!),
              ) &&
              response.first.visitIn != tempLimitVisit.first.visitIn) {
        isLoading.value = false;
        dataLimitVisit.value = tempLimitVisit;
        statsCon.value =
            'Wait for a stable internet connection\nThis data saved on local storage';
        dataLimitVisit.addAll(response);
      } else {
        isLoading.value = false;
        statsCon.value = "";
        dataLimitVisit.value = response;
      }
    } else {
      isLoading.value = false;
      statsCon.value = "";
      dataLimitVisit.value = response;
    }
    return dataLimitVisit;
  }

  resend() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = Data.fromJson(
      jsonDecode(pref.getString('userDataLogin')!),
    );
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
    idUser.value = dataUserLogin.id!;
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2,
    };

    var paramLimitVisit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2,
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tanggal_masuk": realDateServer,
    };

    var paramSingleVisit = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tgl_visit": realDateServer,
    };

    return _startDateStream(
      paramSingle,
      paramLimit,
      paramSingleVisit,
      paramLimitVisit,
      dataUserLogin,
    );
  }

  //send data to xmor
  sendDataToXmor(
    String id,
    String type,
    String dateTime,
    String shift,
    String lat,
    String long,
    String address,
    String namaCabang,
    String kodeCabang,
    String device,
  ) async {
    var img = "";
    if (image != null) {
      img =
          "data:image/jpg;base64,${base64.encode(File(image!.path).readAsBytesSync())}";
    }
    var data = {
      "emp_id": id,
      "type": type,
      "date": dateTime,
      "shift": shift,
      "lat": lat,
      "long": long,
      "address": address,
      "note": namaCabang,
      "store": kodeCabang,
      "image": img,
      "device_info": device,
    };
    await ServiceApi().sendDataToXmor(data);
  }

  Future<void> getLastUserData({required Data dataUser}) async {
    var newUser = await ServiceApi().fetchCurrentUser({
      "username": dataUser.username!,
      "password": dataUser.password!,
    });
    if (Get.isRegistered<LoginController>()) {
      final logC = Get.find<LoginController>();
      logC.logUser.value = newUser;
      // update sharedpreff
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDataLogin', jsonEncode(newUser.toJson()));

      SQLHelper.instance.updateDataUser(
        newUser.toJson(),
        newUser.id!,
        newUser.username!,
      );
      logC.refresh();
    }
  }

  Stream<Duration> countdownToCheckout(DateTime checkInTime) async* {
    // Hitung jam pulang = jam masuk + 8 jam
    final checkOutTime = checkInTime.add(const Duration(hours: 8));

    while (true) {
      final now = DateTime.now();
      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        checkOutTime.hour,
        checkOutTime.minute,
      );
      Duration diff = endTime.difference(now);
      if (diff.isNegative) {
        diff = Duration.zero;
      }
      yield diff;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // double get dynamicRadius {
  //   // Zoom 5 – 18
  //   // Semakin zoom in → semakin besar
  //   return (currentZoom.value * 8).clamp(40, 160);
  // }

  void autoSmartZoom({
    required LatLng userLatLng,
    required LatLng storeLatLng,
    required double allowedRadius,
    bool force = false,
  }) {
    final distance = const Distance().as(
      LengthUnit.Meter,
      userLatLng,
      storeLatLng,
    );

    final inside = distance <= allowedRadius;

    isInsideRadius.value = inside;

    // 🔥 Kalau force true, reset mode
    if (force) {
      lastZoomMode = "";
    }

    if (inside && lastZoomMode != "inside") {
      lastZoomMode = "inside";

      mapController.moveAndRotate(userLatLng, 15.5, 0);
    } else if (!inside && lastZoomMode != "outside") {
      lastZoomMode = "outside";

      final bounds = LatLngBounds.fromPoints([userLatLng, storeLatLng]);

      mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
      );
    }
    // print(userLatLng);
    // print(storeLatLng);
    // print(lastZoomMode);
    // print(distance);
    // print(allowedRadius);
    // print(barcodeScanRes.value);
  }

  void _triggerSmartZoom(Data? data) {
    final userLatLng =
        scannedLatLng.value ?? LatLng(latFromGps.value, longFromGps.value);

    final storeLatLng = LatLng(
      double.parse(lat.isNotEmpty ? lat.value : data!.lat!),
      double.parse(long.isNotEmpty ? long.value : data!.long!),
    );

    autoSmartZoom(
      userLatLng: userLatLng,
      storeLatLng: storeLatLng,
      allowedRadius: double.parse(data!.areaCover!),
    );
  }

  // void updateStore(LatLng newStore) {
  //   lat.value = newStore.latitude.toString();
  //   long.value = newStore.longitude.toString();

  //   lastZoomMode = ""; // reset supaya zoom trigger ulang
  // }

  void changeCabang(Cabang cabang, Data dataUser) async {
    if (dataUser.visit == "1") {
      selectedCabangVisit.value = cabang.kodeCabang!;
    } else {
      selectedCabang.value = cabang.kodeCabang!;
    }

    lat.value = cabang.lat!;
    long.value = cabang.long!;

    storeLatLng.value = LatLng(
      double.parse(cabang.lat!),
      double.parse(cabang.long!),
    );
    // print('storeLatLong Cabang: ${storeLatLng.value}');

    // print(storeLatLng.value);
    // print(dynamicRadius);
    barcodeScanRes.value = "";
    // 🔥 Hitung ulang posisi user
    // final userLatLng =
    //     scannedLatLng.value ?? LatLng(latFromGps.value, longFromGps.value);

    // final storeLatLng = LatLng(
    //   double.parse(cabang.lat!),
    //   double.parse(cabang.long!),
    // );

    await getLoc(dataUser);
    refreshZoom(dataUser);
    // isLoading.value = true;
  }

  void updateCircleFromQr(String qrValue) {
    final parts = qrValue.split(' ');
    if (parts.length >= 2) {
      final latQr = double.parse(parts[0]);
      final longQr = double.parse(parts[1]);

      final newLatLng = LatLng(latQr, longQr);

      scannedLatLng.value = newLatLng;
      storeLatLng.value = newLatLng; // 🔥 ini kuncinya
    }
  }

  double get distanceKm {
    if (storeLatLng.value == null) return 0;

    final meter = const Distance().as(
      LengthUnit.Meter,
      LatLng(latFromGps.value, longFromGps.value),
      storeLatLng.value!,
    );

    return meter / 1000;
  }

  void refreshZoom(Data dataUser) {
    if (storeLatLng.value == null) return;

    final userLatLng =
        validatedQrLatLng.value ?? LatLng(latFromGps.value, longFromGps.value);

    autoSmartZoom(
      userLatLng: userLatLng,
      storeLatLng: storeLatLng.value!,
      allowedRadius: double.parse(dataUser.areaCover!),
      force: true,
    );
  }
}
