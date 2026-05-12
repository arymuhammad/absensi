import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/data/model/notif_model.dart';
import 'package:absensi/app/data/model/summary_absen_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/greeting_helper.dart';
import '../../../data/model/login_model.dart';
import '../views/dialog_update_app.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var currentPage = 0.obs;
  late TabController tabController;
  // var summAttPerMonth = SummaryAbsenModel().obs;
  // late Rx<Future<SummaryAbsenModel>> futureSummary =
  //     Rx<Future<SummaryAbsenModel>>(Future.value(SummaryAbsenModel()));
  // var summPendApp = NotifModel().obs;
  var hadir = 0.obs;
  var tepatWaktu = 0.obs;
  var telat = 0.obs;
  var pendingAppCount = 0.obs;
  var pendingAdjCount = 0.obs;
  var isLoadingSumm = true.obs;
  var isLoadingAdj = true.obs;
  var isLoadingPending = true.obs;
  var isErrorPending = false.obs;
  var isErrorSumm = false.obs;
  var isErrorAdj = false.obs;
  var isOffline = false.obs;
  var initDate = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
    ),
  );
  var endDate = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString(),
    ),
  );

  var totalNotif = 0.obs;
  final greeting = ''.obs;
  final icon = Rx<Widget>(Lottie.asset('assets/animation/pagi.json'));
  Timer? timer;
  final Dio dio = Dio();
  var downloadedBytes = 0.obs;
  var totalBytes = 0.obs;
  var downloadProgress = 0.0.obs;
  CancelToken cancelToken = CancelToken();
  String currentFilePath = '';
  var isDownloading = false.obs;
  var updateList = [];
  var currVer = "";
  var latestVer = "";

  var speed = ''.obs;
  var eta = ''.obs;

  int lastBytes = 0;
  DateTime lastTime = DateTime.now();
  bool isPaused = false;

  var selectedTab = 0.obs;
  var search = ''.obs;
  var isTabLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currVer = packageInfo.version;

    // print('VERSI SEKARANG $currVer');
    final online = await isOnline();
    if (online) {
      try {
        final readDoc = await http
            .get(Uri.parse('http://103.156.15.61/update_apk/updateLog.xml'))
            .timeout(const Duration(seconds: 5));

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
            } else {
              launchUrl(
                Uri.parse(
                  'https://apps.apple.com/us/app/urbanco-spot/id6476486235',
                ),
              );
            }
          }
        }
      } catch (e) {
        print("Update check failed: $e");
      }
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = Data.fromJson(
      jsonDecode(pref.getString('userDataLogin')!),
    );
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
    tabController = TabController(length: 3, vsync: this);
    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage.value) {
        changePage(value);
        // print(value);
      }
    });
    if (dataUserLogin.visit == "0") {
      getSummAttPerMonth(dataUserLogin.id!);
    }
    if ((dataUserLogin.parentId == "3" &&
            (dataUserLogin.level == "19" ||
                dataUserLogin.level == "20" ||
                dataUserLogin.level == "26")) ||
        (dataUserLogin.parentId == "4" &&
            (dataUserLogin.level == "1" || dataUserLogin.level == "43")) ||
        (dataUserLogin.parentId == "5" && dataUserLogin.level == "77") ||
        (dataUserLogin.parentId == "7" && dataUserLogin.level == "23") ||
        (dataUserLogin.parentId == "8" && dataUserLogin.level == "18") ||
        (dataUserLogin.parentId == "9" && dataUserLogin.level == "41") ||
        (dataUserLogin.parentId == "2" && dataUserLogin.level == "10") ||
        (dataUserLogin.parentId == "1")) {
      getPendingApproval(
        idUser: dataUserLogin.id!,
        kodeCabang: dataUserLogin.kodeCabang!,
        level: dataUserLogin.level!,
        parentId: dataUserLogin.parentId!,
      );

      getPendingAdj(
        idUser: dataUserLogin.id!,
        idCabang: dataUserLogin.kodeCabang!,
        level: dataUserLogin.level!,
      );
    }

    _refresh();

    // update tiap 30 detik (aman & smooth)
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refresh();
    });
  }

  void _refresh() async {
    greeting.value = await GreetingHelper.getGreeting();
    icon.value = await GreetingHelper.getIcon();
  }

  void changePage(int newPage) {
    currentPage.value = newPage;
  }

  @override
  void dispose() {
    tabController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Stream<String> getTime() async* {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 1));
      DateTime now = DateTime.now();
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');

      yield " $hour : $minute : $second";
    }
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

  Future<void> getSummAttPerMonth(String idUser) async {
    var data = {
      "type": "summ_month",
      "date1": initDate,
      "date2": endDate,
      "id_user": idUser,
    };
    try {
      isLoadingSumm.value = true;
      isErrorSumm.value = false;

      SummaryAbsenModel res = await ServiceApi().getNotif(data);

      hadir.value = res.hadir ?? 0;
      tepatWaktu.value = res.tepatWaktu ?? 0;
      telat.value = res.telat ?? 0;
    } catch (e) {
      isErrorSumm.value = true;
    } finally {
      isLoadingSumm.value = false;
    }
  }

  Future<void> getPendingApproval({
    required String idUser,
    required String kodeCabang,
    required String level,
    required String parentId,
  }) async {
    var data = {
      "type": "approval",
      "id_user": idUser,
      "kode_cabang": kodeCabang,
      "level": level,
      "parent_id": parentId,
    };
    try {
      isLoadingPending.value = true;
      isErrorPending.value = false;

      NotifModel res = await ServiceApi().getNotif(data);

      pendingAppCount.value = res.totalRequest ?? 0;
      // print(pendingAppCount.value);
      totalNotif.value = pendingAdjCount.value + pendingAppCount.value;
    } catch (e) {
      isErrorPending.value = true;
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> getPendingAdj({
    required String idUser,
    required String idCabang,
    required String level,
  }) async {
    var data = {
      "type": "adjusment",
      "id_user": idUser,
      "kode_cabang": idCabang,
      "level": level,
      "date1": initDate,
      "date2": endDate,
    };
    // print(data);
    try {
      isLoadingAdj.value = true;
      isErrorAdj.value = false;

      NotifModel res = await ServiceApi().getNotif(data);

      pendingAdjCount.value = res.totalNotif ?? 0;
      totalNotif.value = pendingAdjCount.value + pendingAppCount.value;
    } catch (e) {
      isErrorAdj.value = true;
    } finally {
      isLoadingAdj.value = false;
    }
  }

  Future<void> downloadApk({bool resume = false}) async {
    if (isDownloading.value) return;

    try {
      isDownloading.value = true;
      cancelToken = CancelToken(); // 🔥 reset selalu

      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/latest.apk';
      currentFilePath = filePath;

      File file = File(filePath);
      int existingLength = 0;

      if (resume && await file.exists()) {
        existingLength = await file.length();
      }

      await dio.download(
        'http://103.156.15.61/update_apk/latest.apk',
        filePath,
        cancelToken: cancelToken,
        options: Options(
          headers:
              existingLength > 0 ? {"Range": "bytes=$existingLength-"} : {},
        ),
        deleteOnError: false,
        onReceiveProgress: (received, total) {
          int fullReceived = received + existingLength;
          int fullTotal = total + existingLength;

          downloadProgress.value = (fullReceived / fullTotal) * 100;
          downloadedBytes.value = fullReceived;
          totalBytes.value = fullTotal;

          calculateSpeed(fullReceived, fullTotal);
        },
      );

      isDownloading.value = false;
      isPaused = false;

      showToast('Download selesai');
      installApk(filePath);
    } catch (e) {
      isDownloading.value = false;

      if (e is DioException) {
        if (CancelToken.isCancel(e)) {
          showToast(isPaused ? 'Download dijeda' : 'Download dibatalkan');
        } else {
          showToast('Download gagal: ${e.message}');
        }
      } else {
        showToast('Error tidak dikenal: $e');
      }
    }
  }

  Future<void> installApk(String path) async {
    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      showToast('Gagal membuka installer: ${result.message}');
    }
  }

  void cancelDownload(String path) async {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel("User cancelled");

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      isDownloading.value = false;
    }
  }

  void resetToken() {
    cancelToken = CancelToken();
  }

  void pauseDownload() {
    if (!cancelToken.isCancelled) {
      isPaused = true; // 🔥 tandain pause
      cancelToken.cancel("Paused");
      isDownloading.value = false;
    }
  }

  void resumeDownload() {
    if (isDownloading.value) return;

    resetToken();
    isPaused = false;

    downloadApk(resume: true);
  }

  void calculateSpeed(int received, int total) {
    final now = DateTime.now();
    final diff = now.difference(lastTime).inMilliseconds;

    if (diff >= 1000) {
      final bytesPerSec = (received - lastBytes) / (diff / 1000);

      final remaining = total - received;
      final etaSec = bytesPerSec > 0 ? remaining / bytesPerSec : 0;

      speed.value = "${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s";
      eta.value = "${etaSec.toStringAsFixed(0)} sec";

      lastBytes = received;
      lastTime = now;
    }
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
              'http://103.156.15.61/update_apk/latest.apk',
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
          // print(compareVersion(latestVer, currVer) > 0);
          // print(latestVer);
          // print(currVer);
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
        showToast("No update available");
        // succesDialog(
        //   context: Get.context!,
        //   pageAbsen: "N",
        //   desc: "No system updates",
        //   type: DialogType.info,
        //   title: 'INFO',
        //   btnOkOnPress: () => Get.back(),
        // );
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
}
