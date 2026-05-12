import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// import 'dart:developer';
import 'dart:io';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/model/cek_visit_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/data/model/visit_model.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_face_api/flutter_face_api.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/helper/db_result.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:device_info_null_safety/device_info_null_safety.dart';
import 'package:path_provider/path_provider.dart';
import '../../login/controllers/login_controller.dart';
import '../views/logic/absen_usecase.dart';
import '../views/widget/custom_qr_page.dart';

class AbsenController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
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
  // var downloadProgress = 0.0.obs;
  // var downloadStatus = "".obs;
  // var updateList = [];
  // var currVer = "";
  // var latestVer = "";
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
  // late StreamSubscription _sub;
  var remainingSec = 30.obs;
  var timerStat = false.obs;
  File? capturedImage;
  var barcodeScanRes = ''.obs;
  var scannedLatLng = Rx<LatLng?>(null);
  final isEnabled = true.obs;
  // int maxRetries = 3;

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
  var isSyncing = false.obs;
  var syncTotal = 0.obs;
  var syncCurrent = 0.obs;
  Timer? timer;
  var isOffline = false.obs;
  StreamSubscription? connectivitySub;
  final isTimeUntrusted = false.obs;
  bool isSyncingTime = false;
  final isAppLocked = false.obs;
  var visit = "".obs;
  var isAnimReady = false.obs;
  final AbsenUseCase useCase = AbsenUseCase();

  // bool _hasTriggeredInitialSync = false;
  // bool _isHandlingReconnect = false;

  @override
  void onInit() {
    // print("AbsenController INIT: ${hashCode}");
    super.onInit();
    animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSeconds.value),
    );
    isAnimReady.value = true;
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

    _init();
  }

  Future<void> _init() async {
    WidgetsBinding.instance.addObserver(this);

    try {
      final dataUser = await _loadUser();

      await _safeRun(() => _initBasic(dataUser), "initBasic");
      await _safeRun(() => _initConnectivity(dataUser), "initConnectivity");
      await _safeRun(() => _initControllers(dataUser), "initControllers");
      await _safeRun(() => _handleAbsenOrVisit(dataUser), "handleAbsenOrVisit");

      _safeRunSync(() => _initBackground(dataUser), "initBackground");
      _safeRunSync(() => _initReactivity(dataUser), "initReactivity");
    } catch (e) {
      // print("FATAL ERROR onInit: $e");
      log('FATAL ERROR onInit: $e', name: 'ERROR fungsi _init');
    }
  }

  @override
  void onReady() {
    triggerSyncSafe(isVisit: visit.value == "1");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initTime(); // 🔥 app balik dari background
    }
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
    stopAutoSync();
    WidgetsBinding.instance.removeObserver(this);
    connectivitySub?.cancel();
    filterAbsen.dispose();
    super.onClose();
  }

  Future<Data> _loadUser() async {
    final pref = await SharedPreferences.getInstance();
    return Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
  }

  Future<void> _initBasic(Data user) async {
    await getShift();

    idUser.value = user.id!;
    visit.value = user.visit!;

    isOffline.value = !(await isReallyOnline());
    await initTime();
  }

  Future<void> _initConnectivity(Data user) async {
    connectivitySub = Connectivity().onConnectivityChanged.listen((_) async {
      final nowOnline = await isReallyOnline();
      final nowOffline = !nowOnline;

      if (isOffline.value == true && !nowOffline) {
        showToast("Reconnection, syncing data...");
        triggerSyncSafe(isVisit: visit.value == "1");
      }

      if (nowOffline != isOffline.value) {
        isOffline.value = nowOffline;

        if (!nowOffline) {
          await initTime();
        }
      }
    });
  }

  Future<void> _initControllers(Data user) async {
    date1 = TextEditingController();
    date2 = TextEditingController();
    store = TextEditingController();
    userCab = TextEditingController();
    rndLoc = TextEditingController();

    selectedDate.value = null;

    storeLatLng.value = LatLng(
      double.parse(user.lat!),
      double.parse(user.long!),
    );
  }

  Future<void> _handleAbsenOrVisit(Data user) async {
    final isVisit = user.visit == "1";

    // print("isVisit: $isVisit");

    var paramLimit = {
      "mode": "limit",
      "id_user": user.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2,
    };

    if (!isVisit) {
      // print("jalan kan absen");

      var paramSingle = {
        "mode": "single",
        "id_user": user.id,
        "tanggal_masuk": realDateServer,
      };

      await getAbsenToday(paramSingle);
      await getLimitAbsen(paramLimit);
    } else {
      // print("jalan kan visit");

      var paramSingleVisit = {
        "mode": "single",
        "id_user": user.id,
        "tgl_visit": realDateServer,
      };

      await getVisitToday(paramSingleVisit);
      await getLimitVisit(paramLimit);
    }
  }

  void _initBackground(Data user) {
    _initHeavy(user);
    getCabang();
  }

  void _initReactivity(Data user) {
    everAll([lat, long, scannedLatLng, latFromGps, longFromGps], (_) {
      if (!isMapReady.value) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerSmartZoom(user);
      });
    });

    ever(isOffline, (offline) {
      if (!offline) {
        storeLatLng.value = LatLng(
          double.parse(user.lat!),
          double.parse(user.long!),
        );
      }
    });
  }

  Future<void> _initHeavy(Data dataUserLogin) async {
    final isVisit = dataUserLogin.visit == "1";

    final isDone = isVisit ? await syncVisit() : await syncAbsen();

    if (!isDone) {
      startAutoSync(isVisit: isVisit);
    }

    // await initTime();
  }

  Future<void> _safeRun(Future<void> Function() fn, String name) async {
    try {
      await fn();
    } catch (e) {
      // print("ERROR di $name: $e");
      log('ERROR di $name: $e', name: 'ERROR safeRun');
    }
  }

  void _safeRunSync(void Function() fn, String name) {
    try {
      fn();
    } catch (e) {
      log('ERROR di $name: $e', name: 'ERROR safeRunSync');
    }
  }

  Future<void> initTime() async {
    if (isSyncingTime) return;
    isSyncingTime = true;

    try {
      final t = await getSecureTime();

      // ✅ VALID TIME (ONLINE / CACHE VALID)
      isTimeUntrusted.value = false;
      isAppLocked.value = false;

      timeServer = t;
      realDateServer = DateFormat('yyyy-MM-dd').format(t);
      realTimeServer = DateFormat('HH:mm').format(t);
    } catch (e) {
      // 🔥 CEK: apakah ini karena offline?
      final offline = !(await isReallyOnline());

      if (offline) {
        final prefs = await SharedPreferences.getInstance();
        final isLocked = prefs.getBool("is_time_locked") ?? false;

        if (isLocked) {
          isTimeUntrusted.value = true;
          isAppLocked.value = true;
        } else {
          final offline = !(await isReallyOnline());

          if (offline) {
            isTimeUntrusted.value = false;
            isAppLocked.value = false;
          } else {
            isTimeUntrusted.value = true;
            isAppLocked.value = true;
          }
        }
      } else {
        // ❌ ONLINE TAPI ERROR = MANIPULASI / INVALID
        isTimeUntrusted.value = true;
        isAppLocked.value = true;
      }

      // fallback
      final now = DateTime.now();
      timeServer = now;
      realDateServer = DateFormat('yyyy-MM-dd').format(now);
      realTimeServer = DateFormat('HH:mm').format(now);
    } finally {
      isSyncingTime = false;
    }
  }

  void startLoading({
    int seconds = 20,
    String title = "Finding your location",
  }) {
    if (!isAnimReady.value) return;

    durationSeconds.value = seconds;
    secondsLeft.value = seconds;

    animController.stop(); // 🔥 reset dulu
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
    return now!.isBefore(DateTime(now.year, now.month, now.day, 9, 1));
  }

  Future<DbResult> executeAction(Data data) async {
    return await useCase.handleAction(data: data, controller: this);
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

  // int compareVersion(String v1, String v2) {
  //   List<String> parts1 = v1.split('.');
  //   List<String> parts2 = v2.split('.');

  //   int length =
  //       (parts1.length > parts2.length) ? parts1.length : parts2.length;

  //   for (int i = 0; i < length; i++) {
  //     int p1 = (i < parts1.length) ? int.tryParse(parts1[i]) ?? 0 : 0;
  //     int p2 = (i < parts2.length) ? int.tryParse(parts2[i]) ?? 0 : 0;

  //     if (p1 > p2) return 1;
  //     if (p1 < p2) return -1;
  //   }
  //   return 0; // sama
  // }

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
    Position position;
    try {
      position = await determinePosition();
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
    } catch (e) {
      stopLoading();
      return;
    }

    latFromGps.value = position.latitude;
    longFromGps.value = position.longitude;
    // print(latFromGps.value);
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
            "your distance from the store (${(distanceStore.value / 1000).toStringAsFixed(2)} Km)";
      } else {
        isLoading.value = false;
        isEnabled.value = true;
        locNote.value = "Inside area";
      }
    }

    barcodeScanRes.value = "";
    isLoading.value = false;

    stopLoading();
  }

  Future<bool> isOnline() async {
    final online = await isReallyOnline();
    isOffline.value = !online;
    return online;
  }

  Future<bool> isReallyOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    final hasNetwork = connectivityResult.any(
      (e) => e != ConnectivityResult.none,
    );

    if (!hasNetwork) return false;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Position> determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showToast("Lokasi belum diaktifkan");
        stopLoading();
        return Future.error('Location disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoading.value = false;
          isEnabled.value = false;
          showToast("Permission denied");
          // Get.back();
          stopLoading();
          return Future.error('Permission denied');
        }
      }
      // await Future.delayed(const Duration(milliseconds: 400));

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        isLoading.value = false;
        isEnabled.value = false;
        showToast("Permission denied forever");
        // Get.back();
        stopLoading();
        return Future.error('Permission denied forever');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      // Pakai last known position dulu
      // Position? lastKnown = await Geolocator.getLastKnownPosition();
      // if (lastKnown != null) {
      //   lokasi.value =
      //       "Posisi sementara: (${lastKnown.latitude}, ${lastKnown.longitude})";
      // }

      /// 🔥 1. coba ambil last known dulu (CEPAT)
      Position? lastKnown = await Geolocator.getLastKnownPosition();

      /// 🔥 2. coba ambil GPS real (TAPI ADA LIMIT)
      try {
        final fresh = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        );

        if (fresh.isMocked) {
          isLoading.value = false;
          isEnabled.value = false;
          failedDialog(Get.context, 'Warning', 'Fake GPS detected');
          throw Exception("Fake GPS detected");
        }
        stopLoading();
        return fresh;
      } catch (_) {
        /// 🔥 fallback ke last known
        if (lastKnown != null) {
          return lastKnown;
        }
        rethrow;
      }

      // Position loc = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      //   timeLimit: const Duration(seconds: 20),
      //   // forceAndroidLocationManager: true
      //   //
      // );
      // // print(loc.latitude);
      // // print(loc.longitude);
      // if (loc.isMocked) {
      //   isLoading.value = false;
      //   isEnabled.value = false;
      //   failedDialog(
      //     Get.context,
      //     'Warning',
      //     'You have been detected using\nfake location',
      //   );
      //   // Get.back();
      // }
      // stopLoading();
      // return loc;
    } on TimeoutException {
      isLoading.value = false;
      isEnabled.value = false;
      // Get.back(); // Tutup loading
      showToast("Failed to get location, please try again.");
      // Get.back();
      stopLoading();
      return Future.error('Timeout while getting location');
    } catch (e) {
      showToast("Failed to get location");
      stopLoading();
      return Future.error(e);
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

      // if (barcodeScanRes.isNotEmpty &&
      //     ((barcodeScanRes.value.split(' ').length > 2 &&
      //             barcodeScanRes.value.split(' ')[2] != "URBAN&CO") ||
      //         barcodeScanRes.isNotEmpty &&
      //             barcodeScanRes.value.split(' ').length < 3)) {
      if (!barcodeScanRes.value.contains('|')) {
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

        // scannedLatLng.value = LatLng(
        //   double.parse(barcodeScanRes.value.split(' ')[0]),
        //   double.parse(barcodeScanRes.value.split(' ')[1]),
        // );
        final split = barcodeScanRes.value.split('|');

        if (split.length < 2) {
          showToast("QR tidak valid");
          return;
        }

        // final kodeCabang = split[0];
        // final token = split[1];
        final kodeCabang = split[0].trim();
        final token = split[1].trim();

        // Step 2: Dapatkan posisi user
        startLoading(seconds: 15, title: 'Validating your QR code');
        final qrRes = await ServiceApi().validateQr(
          kode: kodeCabang,
          token: token,
        );

        stopLoading();

        if (!qrRes['success']) {
          showToast('QR tidak valid');
          return;
        }
        final qrData = qrRes['data'];

        final qrLat = double.parse(qrData['lat'].toString());
        final qrLong = double.parse(qrData['long'].toString());

        scannedLatLng.value = LatLng(qrLat, qrLong);
        // 🔥 Paksa circle tetap tampil
        storeLatLng.value = scannedLatLng.value;

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
          qrLat,
          qrLong,
        );

        // Step 4: Validasi

        // getCoveredQR(kodeCabang: barcodeScanRes.value.split(' ')[3]);

        // print(distanceMeter);
        // print(num.parse(dataUser!.areaCoverQR!));
        // final allowedRadius = await getCoveredQR(kodeCabang: kodeCabang);
        final allowedRadius = double.parse(
          qrData['area_coverage_qr'].toString(),
        );

        if (distanceMeter <= allowedRadius) {
          // dataUser!.visit == "1"
          // ?
          if (dataUser!.visit == "1") {
            selectedCabangVisit.value = kodeCabang;
          } else {
            selectedCabang.value = kodeCabang;
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

          updateCircleFromQr(qrLat, qrLong);

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

          updateCircleFromQr(qrLat, qrLong);

          refreshZoom(dataUser!);

          // Tolak absensi/scan, bisa kasih opsi retry
        }
      }
    } on PlatformException {
      barcodeScanRes.value = 'Failed to get platform version.';
    }
  }

  // Future<num> getCoveredQR({required String kodeCabang}) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         '${ServiceApi().baseUrl}get_covered_qr?kode_cabang=$kodeCabang',
  //       ),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception("Server error ${response.statusCode}");
  //     }

  //     final result = jsonDecode(response.body);

  //     if (result['success'] != true || result['data'] == null) {
  //       throw Exception("Invalid response");
  //     }

  //     return num.parse(result['data']['area_coverage_qr']);
  //   } catch (e) {
  //     showToast("Failed to get QR radius");
  //     return 0; // fallback aman
  //   }
  // }

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

  Future<void> uploadFotoAbsen({required bool isVisit}) async {
    image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxHeight: 600,
      maxWidth: 600,
    );

    // if (image != null) {
    //   // var img = base64.encode(File(image!.path).readAsBytesSync());
    //   // log(image!.path, name: 'PATH');
    //   update();
    // } else {
    //   return;
    // }

    if (image == null) return;
    try {
      // 🔥 pindahkan ke storage permanent
      final savedPath = await saveImage(
        image!.path,
        isVisit ? 'visit' : 'absen',
      );

      // 👉 simpan path baru (BUKAN cache)
      image = XFile(savedPath);

      // kalau kamu pakai variable lain untuk DB:
      // fotoMasukPath = savedPath;

      update();
    } catch (e) {
      showToast("Gagal menyimpan foto");
    }
  }

  Future<String> saveImage(String sourcePath, String type) async {
    final dir = await getApplicationDocumentsDirectory();

    final folder = Directory('${dir.path}/UrbanCoSpot/$type');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${basename(sourcePath)}';

    final newPath = '${folder.path}/$fileName';

    final newFile = await File(sourcePath).copy(newPath);

    return newFile.path;
  }

  Future<void> deleteFileIfExists(String? path) async {
    if (path == null || path.isEmpty) return;

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> cleanupOrphanFiles({required bool isVisit}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory(
        '${dir.path}/UrbanCoSpot/${isVisit ? 'visit' : 'absen'}',
      );

      if (!await photoDir.exists()) return;

      // 🔥 ambil semua file di folder
      final files = photoDir.listSync();

      // 🔥 ambil semua path dari DB
      final dbPaths = await SQLHelper.instance.getAllPhotoPaths(
        isVisit: isVisit,
      );

      for (var file in files) {
        if (file is File) {
          final path = file.path;

          // // kalau file tidak ada di DB → hapus
          // if (!dbPaths.contains(path)) {
          //   await file.delete();
          //   // optional debug
          //   print('Deleted orphan file: $path');
          // }

          final dbSet = dbPaths.toSet();

          if (!dbSet.contains(path)) {
            await file.delete();
          }
        }
      }

      showToast('Cleanup selesai');
    } catch (e) {
      print('Cleanup error: $e');
    }
  }

  Future<List<ShiftKerja>> getShift() async {
    var tempShift = await SQLHelper.instance.getShift();

    if (tempShift.isNotEmpty) {
      shiftKerja.value =
          tempShift.where((e) => e.id != "0" && e.id != null).toList();
      return shiftKerja;
    } else {
      final response = await ServiceApi().getShift();

      shiftKerja.value =
          response.where((e) => e.id != "0" && e.id != null).toList();

      for (final e in shiftKerja) {
        await SQLHelper.instance.insertShift(
          ShiftKerja(
            id: e.id,
            namaShift: e.namaShift,
            jamMasuk: e.jamMasuk,
            jamPulang: e.jamPulang,
          ),
        );
      }

      return shiftKerja;
    }
  }

  Future<bool> syncAbsen() async {
    if (!await isOnline()) return true;

    isSyncing.value = true;

    try {
      final pendingData = await SQLHelper.instance.getPendingAbsen();

      if (pendingData.isEmpty) {
        stopAutoSync();
        showToast('no pending data on local storage');
        return true;
      }

      syncTotal.value = pendingData.length;
      syncCurrent.value = 0;
      showToast('sync started');

      for (var item in pendingData) {
        try {
          Map<String, dynamic> data;
          // =========================
          // 🔥 CEK JENIS (MASUK / PULANG)
          // =========================
          if (item.jamAbsenPulang == null || item.jamAbsenPulang == '') {
            // =========================
            // ✅ INSERT (CHECK-IN)
            // =========================
            final file = File(item.fotoMasuk!);

            if (!await file.exists()) {
              showToast('Sync failed, check in photo missing.');
              await SQLHelper.instance.updateStatusAbsen(
                item.idUser!,
                item.tanggalMasuk!,
                "FAILED",
              );
              continue; // ⛔ skip item ini
            }

            data = {
              "status": "add",
              "id": item.idUser,
              "tanggal_masuk": item.tanggalMasuk,
              "kode_cabang": item.kodeCabang,
              "nama": item.nama,
              "id_shift": item.idShift,
              "jam_masuk": item.jamMasuk,
              "jam_pulang": item.jamPulang,
              "jam_absen_masuk": item.jamAbsenMasuk,
              "foto_masuk": File(item.fotoMasuk!),
              "lat_masuk": item.latMasuk,
              "long_masuk": item.longMasuk,
              "device_info": item.devInfo,
            };
          } else {
            // =========================
            // 🔄 UPDATE (CHECK-OUT)
            // =========================
            final file = File(item.fotoPulang!);

            if (!await file.exists()) {
              showToast('Sync failed, check out photo missing.');
              await SQLHelper.instance.updateStatusAbsen(
                item.idUser!,
                item.tanggalMasuk!,
                "FAILED",
              );
              continue; // ⛔ skip item ini
            }

            data = {
              "status": "update",
              "id": item.idUser,
              "tanggal_masuk": item.tanggalMasuk,
              "tanggal_pulang":
                  item.tanggalPulang, // atau field khusus kalau ada
              "nama": item.nama,
              "jam_absen_pulang": item.jamAbsenPulang,
              "foto_pulang": File(item.fotoPulang!),
              "lat_pulang": item.latPulang,
              "long_pulang": item.longPulang,
              "device_info2": item.devInfo2,
            };
          }
          final res = await ServiceApi().submitAbsen(data, true);
          if (res != null && res['success'] == true) {
            await SQLHelper.instance.updateStatusAbsen(
              item.idUser!,
              item.tanggalMasuk!,
              "SUCCESS",
            );
            // stopAutoSync();

            // =========================
            // 🧹 HAPUS FILE FOTO
            // =========================
            if (item.jamAbsenPulang == null || item.jamAbsenPulang == '') {
              // hanya hapus foto masuk kalau ini memang data check-in saja
              await deleteFileIfExists(item.fotoMasuk);
            } else {
              // kalau sudah check-out → hapus dua-duanya
              await deleteFileIfExists(item.fotoMasuk);
              await deleteFileIfExists(item.fotoPulang);
            }
          } else {
            throw Exception('API gagal');
          }
        } catch (e) {
          await SQLHelper.instance.updateStatusAbsen(
            item.idUser!,
            item.tanggalMasuk!,
            "FAILED",
          );
        }
        // 🔥 update progress tiap item
        syncCurrent.value++;
      }
      // 🔥 cek ulang setelah loop
      final remaining = await SQLHelper.instance.getPendingAbsen();
      if (remaining.isEmpty) {
        await cleanupOrphanFiles(isVisit: false);
        showToast('sync process is complete');
        stopAutoSync();
        var paramLimit = {
          "mode": "limit",
          "id_user": idUser.value,
          "tanggal1": initDate1,
          "tanggal2": initDate2,
        };

        var paramSingle = {
          "mode": "single",
          "id_user": idUser.value,
          "tanggal_masuk": realDateServer,
        };
        getAbsenToday(paramSingle);
        getLimitAbsen(paramLimit);
        isSyncing.value = false;
        syncTotal.value = 0;
        syncCurrent.value = 0;
        return true;
      } else {
        showToast('some data failed, retrying...');
        return false;
      }
    } finally {
      isSyncing.value = false; // 🔥 WAJIB di finally
    }
  }

  Future<bool> syncVisit() async {
    if (!await isOnline()) return false;

    isSyncing.value = true;

    try {
      final pendingData = await SQLHelper.instance.getPendingVisit();

      if (pendingData.isEmpty) {
        stopAutoSync();
        showToast('no pending data on local storage');
        return true;
      }

      syncTotal.value = pendingData.length;
      syncCurrent.value = 0;
      showToast('sync started');

      for (var item in pendingData) {
        try {
          Map<String, dynamic> data;
          final isVisitIn = item.jamOut == null || item.jamOut == '';
          final visitKey = isVisitIn ? item.visitIn : item.visitOut;
          // =========================
          // 🔥 CEK JENIS (MASUK / PULANG)
          // =========================
          if (isVisitIn) {
            // =========================
            // ✅ INSERT (CHECK-IN)
            // =========================
            final file = File(item.fotoIn!);

            if (!await file.exists()) {
              showToast('Sync failed, check in photo missing.');
              await SQLHelper.instance.updateStatusVisit(
                item.id!,
                item.tglVisit!,
                item.visitIn!,
                "FAILED",
              );
              continue; // ⛔ skip item ini
            }

            data = {
              "status": "add",
              "id": item.id,
              "nama": item.nama,
              "tgl_visit": item.tglVisit,
              "visit_in": item.visitIn,
              "jam_in": item.jamIn,
              "foto_in": file,
              "foto_out": "",
              "lat_in": item.latIn,
              "long_in": item.longIn,
              "device_info": item.deviceInfo,
              "is_rnd": item.isRnd,
            };
          } else {
            // =========================
            // 🔄 UPDATE (CHECK-OUT)
            // =========================
            final file = File(item.fotoOut!);

            if (!await file.exists()) {
              showToast('Sync failed, check out photo missing.');
              await SQLHelper.instance.updateStatusVisit(
                item.id!,
                item.tglVisit!,
                item.visitOut!,
                "FAILED",
              );
              continue; // ⛔ skip item ini
            }

            data = {
              "status": "update",
              "id": item.id,
              "nama": item.nama,
              "tgl_visit": item.tglVisit,
              "visit_out": item.visitOut,
              "visit_in": item.visitIn,
              "jam_out": item.jamOut,
              "foto_out": file,
              "lat_out": item.latOut,
              "long_out": item.longOut,
              "device_info2": item.deviceInfo2,
            };
          }
          final res = await ServiceApi().submitVisit(data, true);
          if (res != null && res['success'] == true) {
            await SQLHelper.instance.updateStatusVisit(
              item.id!,
              item.tglVisit!,
              visitKey!,
              "SUCCESS",
            );
            // stopAutoSync();

            // =========================
            // 🧹 HAPUS FILE FOTO
            // =========================
            if (isVisitIn) {
              // hanya hapus foto masuk kalau ini memang data check-in saja
              await deleteFileIfExists(item.fotoIn);
            } else {
              // kalau sudah check-out → hapus dua-duanya
              await deleteFileIfExists(item.fotoIn);
              await deleteFileIfExists(item.fotoOut);
            }
          } else {
            throw Exception('API gagal');
          }
        } catch (e) {
          await SQLHelper.instance.updateStatusVisit(
            item.id!,
            item.tglVisit!,
            item.visitIn!,
            "FAILED",
          );
        }
        // 🔥 update progress tiap item
        syncCurrent.value++;
      }
      // 🔥 cek ulang setelah loop
      final remaining = await SQLHelper.instance.getPendingVisit();
      if (remaining.isEmpty) {
        await cleanupOrphanFiles(isVisit: true);
        showToast('sync process is complete');
        stopAutoSync();
        var paramLimit = {
          "mode": "limit",
          "id_user": idUser.value,
          "tanggal1": initDate1,
          "tanggal2": initDate2,
        };

        var paramSingle = {
          "mode": "single",
          "id_user": idUser.value,
          "tgl_visit": realDateServer,
        };

        getVisitToday(paramSingle);
        getLimitVisit(paramLimit);
        isSyncing.value = false;
        syncTotal.value = 0;
        syncCurrent.value = 0;
        return true;
      } else {
        showToast('some data failed, retrying...');
        return false;
      }
    } finally {
      isSyncing.value = false; // 🔥 WAJIB di finally
    }

    ////////////////////////////////////
    ////////////////////////////////////

    // try {
    //   final pendingData = await SQLHelper.instance.getPendingVisit();

    //   if (pendingData.isEmpty) {
    //     stopAutoSync();
    //     showToast('no pending data on local storage');
    //     return true;
    //   }

    //   syncTotal.value = pendingData.length;
    //   syncCurrent.value = 0;
    //   showToast('sync started');

    //   for (var item in pendingData) {
    //     bool isSuccess = false;

    //     final isVisitIn = item.jamOut == null || item.jamOut == '';
    //     final visitKey = isVisitIn ? item.visitIn : item.visitOut;

    //     try {
    //       Map<String, dynamic> data;

    //       if (isVisitIn) {
    //         // ✅ VISIT IN
    //         final file = File(item.fotoIn ?? '');

    //         if (item.fotoIn == null || !await file.exists()) {
    //           showToast('Sync failed, check in photo missing.');
    //           throw Exception('foto_in tidak ada');
    //         }

    //         data = {
    //           "status": "add",
    //           "id": item.id,
    //           "nama": item.nama,
    //           "tgl_visit": item.tglVisit,
    //           "visit_in": item.visitIn,
    //           "jam_in": item.jamIn,
    //           "foto_in": file,
    //           "foto_out": "",
    //           "lat_in": item.latIn,
    //           "long_in": item.longIn,
    //           "device_info": item.deviceInfo,
    //           "is_rnd": item.isRnd,
    //         };
    //       } else {
    //         // 🔄 VISIT OUT
    //         final file = File(item.fotoOut ?? '');

    //         if (item.fotoOut == null || !await file.exists()) {
    //           showToast('Sync failed, check out photo missing.');
    //           throw Exception('foto_out tidak ada');
    //         }

    //         data = {
    //           "status": "update",
    //           "id": item.id,
    //           "nama": item.nama,
    //           "tgl_visit": item.tglVisit,
    //           "visit_out": item.visitOut,
    //           "visit_in": item.visitIn,
    //           "jam_out": item.jamOut,
    //           "foto_out": file,
    //           "lat_out": item.latOut,
    //           "long_out": item.longOut,
    //           "device_info2": item.deviceInfo2,
    //         };
    //       }

    //       final res = await ServiceApi().submitVisit(data, true);

    //       if (res != null && res['success'] == true) {
    //         isSuccess = true;
    //       } else {
    //       print('API RESPONSE: $res');
    //         throw Exception('API gagal');
    //       }
    //     } catch (e) {
    //       print('SYNC ERROR ID ${item.id}: $e');
    //       isSuccess = false;
    //     }

    //     // 🔥 UPDATE STATUS SEKALI SAJA (ANTI KETIMPA)
    //     await SQLHelper.instance.updateStatusVisit(
    //       item.id!,
    //       item.tglVisit!,
    //       visitKey!,
    //       isSuccess ? "SUCCESS" : "FAILED",
    //     );

    //     // 🧹 CLEANUP (TIDAK BOLEH GANGGU STATUS)
    //     if (isSuccess) {
    //       try {
    //         if (isVisitIn) {
    //           await deleteFileIfExists(item.fotoIn);
    //         } else {
    //           await deleteFileIfExists(item.fotoIn);
    //           await deleteFileIfExists(item.fotoOut);
    //         }
    //       } catch (e) {
    //         print('DELETE FILE ERROR: $e');
    //       }
    //     }

    //     syncCurrent.value++;
    //   }

    //   final remaining = await SQLHelper.instance.getPendingVisit();

    //   if (remaining.isEmpty) {
    //     await cleanupOrphanFiles(isVisit: true);
    //     showToast('sync process is complete');
    //     stopAutoSync();

    //     var paramLimit = {
    //       "mode": "limit",
    //       "id_user": idUser.value,
    //       "tanggal1": initDate1,
    //       "tanggal2": initDate2,
    //     };

    //     var paramSingle = {
    //       "mode": "single",
    //       "id_user": idUser.value,
    //       "tgl_visit": realDateServer,
    //     };

    //     getVisitToday(paramSingle);
    //     getLimitVisit(paramLimit);

    //     syncTotal.value = 0;
    //     syncCurrent.value = 0;

    //     return true;
    //   } else {
    //     showToast('some data failed, retrying...');
    //     return false;
    //   }
    // } finally {
    //   isSyncing.value = false;
    // }
  }

  Timer? _syncDebounce;

  void triggerSyncSafe({required bool isVisit}) {
    _syncDebounce?.cancel();

    _syncDebounce = Timer(const Duration(seconds: 1), () {
      triggerSync(isVisit: isVisit);
    });
  }

  void triggerSync({required bool isVisit}) async {
    if (isSyncing.value) return;
    bool isDone;

    if (isVisit) {
      isDone = await syncVisit();
    } else {
      isDone = await syncAbsen();
    }
    // final isDone = await syncAbsen();

    if (!isDone) {
      Future.delayed(const Duration(seconds: 3), () {
        startAutoSync(isVisit: isVisit);
      }); // masih ada pending
    }
  }

  void startAutoSync({required bool isVisit}) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      if (isVisit) {
        await syncVisit();
      } else {
        await syncAbsen();
      }
    });
  }

  void stopAutoSync() {
    timer?.cancel();
  }

  getAbsenToday(paramAbsen) async {
    final online = await isOnline();

    // ===============================
    // ⚠️ OFFLINE → LANGSUNG LOCAL
    // ===============================
    final dateNow =
        realDateServer ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (!online) {
      var tempDataAbs = await SQLHelper.instance.getAbsenToday(
        idUser.value,
        dateNow,
      );

      dataAbsen.value = tempDataAbs;
      return dataAbsen;
    }

    // ===============================
    // ✅ ONLINE → API + LOCAL
    // ===============================
    final response = await ServiceApi().getAbsen(paramAbsen);

    var tempDataAbs = await SQLHelper.instance.getAbsenToday(
      idUser.value,
      dateNow,
    );

    dataAbsen.value = tempDataAbs;

    if (tempDataAbs.isNotEmpty) {
      if (response.isNotEmpty && response[0].jamAbsenPulang != "") {
        dataAbsen.value = response;
      } else if (response.isNotEmpty &&
          (response[0].jamAbsenMasuk != tempDataAbs[0].jamAbsenMasuk! ||
              response[0].idShift != tempDataAbs[0].idShift!)) {
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
    isLoading.value = true;

    /// 🔥 ambil data lokal dulu (fallback / cache)
    var localData = await SQLHelper.instance.getLimitDataAbsen(
      idUser.value,
      initDate1,
      initDate2,
    );
    try {
      final online = await isOnline();

      /// =========================
      /// 🔴 OFFLINE MODE
      /// =========================
      if (!online) {
        if (localData.isNotEmpty) {
          dataLimitAbsen.value = localData;
          statsCon.value = 'Offline mode\nData loaded from local storage';
        } else {
          dataLimitAbsen.clear();
          statsCon.value = 'Offline & no local data';
        }
        return dataLimitAbsen;
      }

      /// =========================
      /// 🟢 ONLINE MODE
      /// =========================
      final response = await ServiceApi()
          .getAbsen(paramLimitAbsen)
          .timeout(const Duration(seconds: 10));

      /// =========================
      /// 🔥 LOGIC SYNC (LOCAL vs SERVER)
      /// =========================
      if (localData.isNotEmpty) {
        final localDate = DateTime.parse(localData.first.tanggalMasuk!);
        final serverDate =
            response.isNotEmpty
                ? DateTime.parse(response.first.tanggalMasuk!)
                : null;

        final useLocal =
            response.isEmpty ||
            (serverDate != null && serverDate.isBefore(localDate)) ||
            (serverDate != null &&
                serverDate.isAtSameMomentAs(localDate) &&
                response.first.jamAbsenPulang == "" &&
                localData.first.jamAbsenPulang != "");

        if (useLocal) {
          dataLimitAbsen.value = localData;
          statsCon.value =
              'Wait for a stable internet connection\nThis data saved on local storage';

          /// optional: merge data server
          if (response.isNotEmpty) {
            dataLimitAbsen.addAll(response);
          }
        } else {
          dataLimitAbsen.value = response;
          statsCon.value = "";
        }
      } else {
        /// tidak ada data lokal
        dataLimitAbsen.value = response;
        statsCon.value = "";
      }

      return dataLimitAbsen;
    } catch (e) {
      if (localData.isNotEmpty) {
        dataLimitAbsen.value = localData;
        statsCon.value = 'Connection unstable\nLoad data from local storage';
      } else {
        dataLimitAbsen.clear();
        statsCon.value = 'Failed to load data';
      }

      return dataLimitAbsen;
    } finally {
      /// 🔥 hanya 1x di sini
      isLoading.value = false;
    }
  }

  Future<List<Absen>> getAllAbsen(String id, String? d1, String? d2) async {
    isLoading.value = true;

    var param = {
      "mode": "",
      "id_user": id,
      "tanggal1": d1!.isNotEmpty ? d1 : initDate1,
      "tanggal2": d2!.isNotEmpty ? d2 : initDate2,
    };

    /// 🔥 ambil data lokal dulu (fallback)
    var localData = await SQLHelper.instance.getAllDataAbsen(
      id,
      d1.isNotEmpty ? d1 : initDate1,
      d2.isNotEmpty ? d2 : initDate2,
    );

    final online = await isOnline();

    /// =========================
    /// 🔴 OFFLINE MODE
    /// =========================
    if (!online) {
      dataAllAbsen.value = localData;
      searchAbsen.value = localData;

      statsCon.value = 'Offline mode\nLoad data from local storage';

      isLoading.value = false;
      return dataAllAbsen;
    }

    /// =========================
    /// 🟢 ONLINE MODE
    /// =========================
    List<Absen> response = [];

    try {
      response = await ServiceApi().getAbsen(param);
    } catch (e) {
      /// 🔥 fallback kalau error API
      dataAllAbsen.value = localData;
      searchAbsen.value = localData;

      statsCon.value = 'Connection unstable\nLoad data from local storage';

      isLoading.value = false;
      return dataAllAbsen;
    }

    /// =========================
    /// 🔥 LOGIC ASLI (TIDAK DIUBAH)
    /// =========================
    dataAllAbsen.value = response;
    searchAbsen.value = response;
    statsCon.value = "";

    isLoading.value = false;
    return dataAllAbsen;
  }

  Future<List<Visit>> getAllVisited(String id, String? d1, String? d2) async {
    isLoading.value = true;

    var param = {
      "mode": "",
      "id_user": id,
      "tanggal1": d1!.isNotEmpty ? d1 : initDate1,
      "tanggal2": d2!.isNotEmpty ? d2 : initDate2,
    };

    /// 🔥 ambil data lokal dulu (fallback)
    var localData = await SQLHelper.instance.getAllDataVisit(
      id,
      d1.isNotEmpty ? d1 : initDate1,
      d2.isNotEmpty ? d2 : initDate2,
    );

    final online = await isOnline();

    /// =========================
    /// 🔴 OFFLINE MODE
    /// =========================
    if (!online) {
      dataAllVisit.value = localData;
      searchVisit.value = localData;

      statsCon.value = 'Offline mode\nLoad data from local storage';

      isLoading.value = false;
      return dataAllVisit;
    }

    /// =========================
    /// 🟢 ONLINE MODE
    /// =========================
    List<Visit> response = [];

    try {
      response = await ServiceApi().getVisit(param);
    } catch (e) {
      /// 🔥 fallback kalau error API
      dataAllVisit.value = localData;
      searchVisit.value = localData;

      statsCon.value = 'Connection unstable\nLoad data from local storage';

      isLoading.value = false;
      return dataAllVisit;
    }

    /// =========================
    /// 🔥 LOGIC ASLI (TETAP)
    /// =========================
    dataAllVisit.value = response;
    searchVisit.value = response;
    statsCon.value = "";

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
    // print(data);
    final response = await ServiceApi().getFilteredAbsen(data);
    Get.back();
    dataAllAbsen.value = response;
    isLoading.value = false;
    searchDate.value =
        '${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date1.text))} - ${DateFormat("d MMM yyyy", "id_ID").format(DateTime.parse(date2.text))} ';
    searchAbsen.value = response;
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

  // checkForUpdates(status) async {
  //   if (status != "onInit") {
  //     loadingDialog("Checking for updates...", "");
  //   }

  //   try {
  //     final readDoc = await http
  //         .get(Uri.parse('http://103.156.15.61/update_apk/updateLog.xml'))
  //         .timeout(const Duration(seconds: 20));
  //     final response = await http
  //         .head(
  //           Uri.parse(
  //             // supportedAbi == 'arm64-v8a'
  //             //     ? 'http://103.156.15.61/update apk/absensiApp.arm64v8a.apk'
  //             // :
  //             'http://103.156.15.61/update_apk/latest.apk',
  //           ),
  //         )
  //         .timeout(const Duration(seconds: 20));

  //     Get.back();
  //     if (response.statusCode == 200) {
  //       //parsing readDoc
  //       final document = xml.XmlDocument.parse(readDoc.body);
  //       final itemsNode = document.findElements('items').first;
  //       final updates = itemsNode.findElements('update');
  //       latestVer = itemsNode.findElements('versi').first.innerText;
  //       //start looping item on readDoc
  //       updateList.clear();
  //       for (final listUpdates in updates) {
  //         final name = listUpdates.findElements('name').first.innerText;
  //         final desc = listUpdates.findElements('desc').first.innerText;
  //         final icon = listUpdates.findElements('icon').first.innerText;
  //         final color = listUpdates.findElements('color').first.innerText;

  //         updateList.add({
  //           'name': name,
  //           'desc': desc,
  //           'icon': icon,
  //           'color': color,
  //         });
  //       }
  //       //end loop item on readDoc
  //       if (compareVersion(latestVer, currVer) > 0) {
  //         dialogUpdateApp();
  //       } else {
  //         // print(compareVersion(latestVer, currVer) > 0);
  //         // print(latestVer);
  //         // print(currVer);
  //         if (status != "onInit") {
  //           Get.back(closeOverlays: true);
  //           succesDialog(
  //             context: Get.context!,
  //             pageAbsen: "N",
  //             desc: "No system updates",
  //             type: DialogType.info,
  //             title: 'INFO',
  //             btnOkOnPress: () => Get.back(),
  //           );
  //         }
  //       }
  //     } else {
  //       showToast("No update available");
  //       // succesDialog(
  //       //   context: Get.context!,
  //       //   pageAbsen: "N",
  //       //   desc: "No system updates",
  //       //   type: DialogType.info,
  //       //   title: 'INFO',
  //       //   btnOkOnPress: () => Get.back(),
  //       // );
  //     }
  //   } on SocketException catch (e) {
  //     Get.back(closeOverlays: true);
  //     Get.defaultDialog(
  //       title: e.toString(),
  //       middleText: 'Check your internet connection',
  //       textConfirm: 'Refresh',
  //       confirmTextColor: Colors.white,
  //       onConfirm: () {
  //         checkForUpdates("");
  //         Get.back(closeOverlays: true);
  //       },
  //     );
  //   } on TimeoutException catch (_) {
  //     Get.back(closeOverlays: true);
  //     showToast("The connection to the server has timed out.");
  //   }
  // }

  Future<List<Visit>> getVisitToday(
    Map<String, dynamic> paramSingleVisit,
  ) async {
    final online = await isOnline();

    // ===============================
    // ⚠️ OFFLINE → LANGSUNG LOCAL
    // ===============================
    if (!online) {
      var tempDataVisit = await SQLHelper.instance.getVisitToday(
        idUser.value,
        realDateServer!,
        '',
        1,
      );

      dataVisit.value = tempDataVisit;
      isLoading.value = false;
      return dataVisit;
    }

    // ===============================
    // ✅ ONLINE → API + LOCAL
    // ===============================
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
          response.first.visitIn == tempDataVisit.first.visitIn) {
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
    isLoading.value = true;

    /// 🔥 ambil data lokal dulu (biar selalu ada fallback)
    var tempLimitVisit = await SQLHelper.instance.getLimitDataVisit(
      idUser.value,
      initDate1,
      initDate2,
    );
    try {
      // 🔥 CEK REAL CONNECTION (bukan state)
      final online = await isReallyOnline();

      /// =========================
      /// 🔴 OFFLINE MODE
      /// =========================
      if (!online) {
        dataLimitVisit.value = tempLimitVisit;
        statsCon.value = 'Offline mode\nLoad data from local storage';
        isLoading.value = false;
        return dataLimitVisit;
      }

      /// =========================
      /// 🟢 ONLINE MODE
      /// =========================
      final response = await ServiceApi().getLimitVisit(paramLimitVisit);
      dataLimitVisit.clear();

      // =========================
      /// 🔥 LOGIC ASLI (TIDAK DIUBAH)
      /// =========================
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
          dataLimitVisit.value = tempLimitVisit;
          statsCon.value =
              'Wait for a stable internet connection\nThis data saved on local storage';
          dataLimitVisit.addAll(response);
        } else {
          statsCon.value = "";
          dataLimitVisit.value = response;
        }
      } else {
        statsCon.value = "";
        dataLimitVisit.value = response;
      }
      return dataLimitVisit;
    } catch (e) {
      /// 🔥 kalau error API → fallback ke lokal
      dataLimitVisit.value = tempLimitVisit;
      statsCon.value = 'Connection unstable\nLoad data from local storage';
      return dataLimitVisit;
    } finally {
      isLoading.value = false;
    }
  }

  // resend() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   var dataUserLogin = Data.fromJson(
  //     jsonDecode(pref.getString('userDataLogin')!),
  //   );
  //   // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
  //   idUser.value = dataUserLogin.id!;
  //   var paramLimit = {
  //     "mode": "limit",
  //     "id_user": dataUserLogin.id!,
  //     "tanggal1": initDate1,
  //     "tanggal2": initDate2,
  //   };

  //   // var paramLimitVisit = {
  //   //   "mode": "limit",
  //   //   "id_user": dataUserLogin.id!,
  //   //   "tanggal1": initDate1,
  //   //   "tanggal2": initDate2,
  //   // };

  //   var paramSingle = {
  //     "mode": "single",
  //     "id_user": dataUserLogin.id,
  //     "tanggal_masuk": realDateServer,
  //   };

  //   var paramSingleVisit = {
  //     "mode": "single",
  //     "id_user": dataUserLogin.id,
  //     "tgl_visit": realDateServer,
  //   };

  //   // return _startDateStream(
  //   //   paramSingle,
  //   //   paramLimit,
  //   //   paramSingleVisit,
  //   //   dataUserLogin,
  //   // );
  // }

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

  void updateCircleFromQr(double latQr, double longQr) {
    final newLatLng = LatLng(latQr, longQr);

    scannedLatLng.value = newLatLng;
    storeLatLng.value = newLatLng;
  }

  // void updateCircleFromQr(String qrValue) {
  //   final parts = qrValue.split(' ');
  //   if (parts.length >= 2) {
  //     final latQr = double.parse(parts[0]);
  //     final longQr = double.parse(parts[1]);

  //     final newLatLng = LatLng(latQr, longQr);

  //     scannedLatLng.value = newLatLng;
  //     storeLatLng.value = newLatLng; // 🔥 ini kuncinya
  //   }
  // }

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
