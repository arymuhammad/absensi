import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/model/cek_visit_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/data/model/visit_model.dart';
import 'package:absensi/app/modules/home/views/dialog_update_app.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:xml/xml.dart' as xml;
import '../modules/absen/views/dialog_absen.dart';
import '../services/service_api.dart';
import '../data/helper/loading_dialog.dart';
import '../data/model/absen_model.dart';
import '../data/model/cabang_model.dart';
import '../data/model/cek_absen_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class AbsenController extends GetxController {
  var isLoading = true.obs;
  var ascending = true.obs;
  var lokasi = "".obs;
  // var devInfoWeb = "".obs;
  var devInfo = "".obs;
  var cekAbsen = CekAbsen().obs;
  var cekVisit =
      CekVisit(total: '', tglVisit: '', kodeStore: '', namaStore: '').obs;
  var optVisit = ['', 'Research and Development', 'Store Visit'];
  var optVisitSelected = "".obs;
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
  late final TextEditingController  date1, date2, store, userCab, rndLoc;
  final TextEditingController filterAbsen = TextEditingController();
  final TextEditingController filterVisit = TextEditingController();
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

  @override
  void onInit() async {
    super.onInit();

    timeNetwork(await FlutterNativeTimezone.getLocalTimezone());

    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = pref.getStringList('userDataLogin');
    idUser.value = dataUserLogin![0];
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin[0],
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramLimitVisit = {
      "mode": "limit",
      "id_user": dataUserLogin[0],
      "tanggal1": initDate1,
      "tanggal2": initDate2
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


    date1 = TextEditingController();
    date2 = TextEditingController();
    store = TextEditingController();
    userCab = TextEditingController();
    rndLoc = TextEditingController();
    searchAbsen.value = dataAllAbsen;
    searchVisit.value = dataAllVisit;
    getAbsenToday(paramSingle);
    getLimitAbsen(paramLimit);
    getVisitToday(paramSingleVisit);
    getLimitVisit(paramLimitVisit);
    getCabang();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      currVer = packageInfo.version;
    });

    if (Platform.isAndroid) {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.60/update apk/updateLog.xml'));

      if (readDoc.statusCode == 200) {
        //parsing readDoc
        final document = xml.XmlDocument.parse(readDoc.body);
        final cLog = document.findElements('items').first;
        latestVer = cLog.findElements('versi').first.innerText;
        if (int.parse(latestVer.replaceAll('.', '')) > int.parse(currVer.replaceAll('.', ''))) {
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
    filterVisit.dispose();
    date1.dispose();
    date2.dispose();
    _dateStream.close();
  }

  Future<List<Cabang>> getCabang() async {
    var tempCabang = await SQLHelper.instance.getCabang();
    if (tempCabang.isNotEmpty) {
      return cabang.value = tempCabang;
    } else {
      final response = await ServiceApi().getCabang({});
      cabang.value = response;
      cabang
          .map((e) async => await SQLHelper.instance.insertCabang(Cabang(
          kodeCabang: e.kodeCabang,
          brandCabang: e.brandCabang,
          namaCabang: e.namaCabang,
          lat: e.lat,
          long: e.long))).toList();
      return cabang;
    }
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

  exportPdf() async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final List<pw.TableRow> rows = await _loadData();

    doc.addPage(pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          pageFormat: PdfPageFormat.a4.landscape,
        ),
        build: (context) => [
              pw.Center(
                child: pw.Table(
                  border: pw.TableBorder.all(),
                  children: rows,
                ),
              )
            ]));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<List<pw.TableRow>> _loadData() async {
    List<pw.TableRow> rows = [];
    final font = await PdfGoogleFonts.nunitoRegular();

    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.blue700),
      children: [
        pw.Text('TANGGAL',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('CABANG',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('NAMA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('SHIFT',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('MASUK',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('FOTO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('STATUS MASUK',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('KELUAR',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('FOTO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('STATUS KELUAR',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
      ],
    ));

    for (var data in searchAbsen) {
      var img1 = await http
          .get(
            Uri.parse('${ServiceApi().baseUrl}${data.fotoMasuk!}'),
          )
          .then((value) => value.bodyBytes);
      // print(img1.statusCode);
      pw.MemoryImage imageMasuk = pw.MemoryImage(img1);
      // // print('${img1.bodyBytes}');
      pw.MemoryImage? imageKeluar;
      if (data.fotoPulang! != "") {
        final img2 = await http.get(
          Uri.parse('${ServiceApi().baseUrl}${data.fotoPulang!}'),
        );

        imageKeluar = pw.MemoryImage(img2.bodyBytes);
      }

      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Text(
              DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(data.tanggalMasuk!)),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font)),
          pw.Text(data.namaCabang!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Text(data.nama!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Text(data.namaShift!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Text(data.jamAbsenMasuk!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Container(
            width: 30,
            height: 30,
            child: pw.Center(child: pw.Image(imageMasuk)),
          ),
          pw.Text(
              DateFormat("HH:mm")
                      .parse(data.jamAbsenMasuk!)
                      .isBefore(DateFormat("HH:mm").parse(data.jamMasuk!))
                  ? "Awal Waktu"
                  : "Telat",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font)),
          pw.Text(data.jamAbsenPulang!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          data.fotoPulang! != ""
              ? pw.Container(
                  width: 30,
                  height: 30,
                  child: pw.Center(child: pw.Image(imageKeluar!)),
                )
              : pw.Container(
                  width: 30,
                  height: 30,
                ),
          pw.Text(
              data.jamAbsenPulang! == ""
                  ? "Belum Absen"
                  : DateFormat("HH:mm")
                          .parse(data.jamAbsenPulang!)
                          .isBefore(DateFormat("HH:mm").parse(data.jamPulang!))
                      ? "Pulang Cepat"
                      : "Lembur",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font)),
        ],
      ));
    }

    return rows;
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
    var tempShift = await SQLHelper.instance.getShift();
    if (tempShift.isNotEmpty) {
      return shiftKerja.value = tempShift;
    } else {
      final response = await ServiceApi().getShift();
      shiftKerja.value = response;
      shiftKerja
          .map((e) async => await SQLHelper.instance.insertShift(ShiftKerja(
              id: e.id,
              namaShift: e.namaShift,
              jamMasuk: e.jamMasuk,
              jamPulang: e.jamPulang)))
          .toList();

      return shiftKerja;
    }
  }

  getAbsenToday(paramAbsen) async {
    final response = await ServiceApi().getAbsen(paramAbsen);

    var tempDataAbs =
    await SQLHelper.instance.getAbsenToday(idUser.value, dateNow);
    dataAbsen.value = tempDataAbs;

    if(tempDataAbs.isNotEmpty){
      if (response.isNotEmpty && response[0].jamAbsenPulang != "") {
        dataAbsen.value = response;
        // print('online');
      } else if(response.isNotEmpty && response[0].jamAbsenMasuk != tempDataAbs[0].jamAbsenMasuk!)  {
        dataAbsen.value = response;
        // print('offline');
      }else{
        dataAbsen.value = tempDataAbs;
      }
    }else{
      // print('online II');
      dataAbsen.value = response;
    }

    return dataAbsen;
  }

  Future<List<Absen>> getLimitAbsen(paramLimitAbsen) async {
    final response = await ServiceApi().getAbsen(paramLimitAbsen);
    dataLimitAbsen.clear();
    isLoading.value = true;
    var tempSingleAbs = await SQLHelper.instance
        .getLimitDataAbsen(idUser.value, initDate1, initDate2);

    if(tempSingleAbs.isNotEmpty){
      if (response.isEmpty || response.isNotEmpty && DateTime.parse(response.first.tanggalMasuk!).isBefore(
          DateTime.parse(tempSingleAbs.first.tanggalMasuk!)) || response.isNotEmpty && DateTime.parse(response.first.tanggalMasuk!).isAtSameMomentAs(
          DateTime.parse(tempSingleAbs.first.tanggalMasuk!)) && response.first.jamAbsenPulang! =="") {

        isLoading.value = false;
        dataLimitAbsen.value = tempSingleAbs;
        dataLimitAbsen.addAll(response);

      } else {

          isLoading.value = false;
          dataLimitAbsen.value = response;
      }
    } else {
      isLoading.value = false;
      dataLimitAbsen.value = response;
    }
    return dataLimitAbsen;
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
      loadingDialog("Memeriksa pembaruan...", "");
    }

    try {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.60/update apk/updateLog.xml')).timeout(const Duration(seconds: 20));

      final response = await http
          .head(Uri.parse('http://103.156.15.60/update apk/absensiApp.apk'))
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

          updateList
              .add({'name': name, 'desc': desc, 'icon': icon, 'color': color});
        }
        //end loop item on readDoc
        if (int.parse(latestVer.replaceAll('.', '')) <= int.parse(currVer.replaceAll('.', ''))) {
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
    } on TimeoutException catch(_){
      Get.back(closeOverlays: true);
      showToast("Waktu untuk koneksi ke server telah habis");
    }
  }

  // errorHandle(Error error) {
  //   Get.back(closeOverlays: true);
  //   Get.defaultDialog(
  //     title: 'Error',
  //     middleText:
  //         'Kesalahan saat mengunduh pembaruan sistem\nHarap periksa koneksi internet anda',
  //     textCancel: 'Refresh',
  //     onCancel: () => Get.back(closeOverlays: true),
  //     // onConfirm: () {
  //     //   checkForUpdates();
  //     //   Get.back(closeOverlays: true);
  //     // },
  //   );
  //   showToast('Failed to make OTA update. Details: ${error.stackTrace} .');
  // }

  getVisitToday(Map<String, dynamic> paramSingleVisit) async {
    final response = await ServiceApi().getVisit(paramSingleVisit);
    var tempDataVisit =
    await SQLHelper.instance.getVisitToday(idUser.value, dateNow,'', 1);

    if(tempDataVisit.isNotEmpty){
      if (response.isNotEmpty && response.first.jamOut != "" && response.first.visitIn! == tempDataVisit.first.visitIn! ) {
        dataVisit.value = response;
      }else{
        dataVisit.value = tempDataVisit;
      }
    }else{
      dataVisit.value = response;
    }

    return dataVisit;

  }

  getLimitVisit(Map<String, dynamic> paramLimitVisit) async {

    final response = await ServiceApi().getLimitVisit(paramLimitVisit);
    dataLimitVisit.clear();

    var tempLimitVisit = await SQLHelper.instance
        .getLimitDataVisit(idUser.value, initDate1, initDate2);

    if(tempLimitVisit.isNotEmpty){
      if (response.isEmpty
          || response.isNotEmpty && DateTime.parse(response.first.tglVisit!).isBefore(
          DateTime.parse(tempLimitVisit.first.tglVisit!))
          || response.isNotEmpty && DateTime.parse(response.first.tglVisit!).isAtSameMomentAs(
          DateTime.parse(tempLimitVisit.first.tglVisit!)) && response.first.jamOut! ==""
          || response.isNotEmpty && response.first.visitIn! != tempLimitVisit.first.visitIn!) {

        isLoading.value = false;
        dataLimitVisit.value = tempLimitVisit;
        dataLimitVisit.addAll(response);

      }else{

        isLoading.value = false;
        dataLimitVisit.value = response;

      }
    } else {
      isLoading.value = false;
      dataLimitVisit.value = response;
    }
    return dataLimitVisit;
  }
}
