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
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xml/xml.dart' as xml;
import '../../../data/model/login_model.dart';
import '../views/dialog_absen.dart';
import '../../../services/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/absen_model.dart';
import '../../../data/model/cabang_model.dart';
import '../../../data/model/cek_absen_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:device_info_null_safety/device_info_null_safety.dart';
// import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class AbsenController extends GetxController {
  var isLoading = true.obs;
  var ascending = true.obs;
  var lokasi = "".obs;
  // var devInfoWeb = "".obs;
  var devInfo = "".obs;
  var cekAbsen = CekAbsen().obs;
  var cekVisit =
      CekVisit(total: '', tglVisit: '', kodeStore: '', namaStore: '').obs;
  var stsAbsen = ['', 'Masuk', 'Pulang'];
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
  var supportedAbi = "";
  var statsCon = "".obs;
  RxList<Absen> searchAbsen = RxList<Absen>([]);
  RxList<Visit> searchVisit = RxList<Visit>([]);
  late final TextEditingController date1, date2, store, userCab, rndLoc;
  final TextEditingController filterAbsen = TextEditingController();
  final TextEditingController filterVisit = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  // MatchFacesImage? mfImage1;
  // MatchFacesImage? mfImage2;
  // var faceDatas = DataWajah().obs;

  // var status = "nil";
  // var similarityStatus = "".obs;
  // var livenessStatus = "nil";
  // var uiImage1 = Image.asset('assets/images/portrait.png');
  // var uiImage2 = Image.asset('assets/images/portrait.png');
  // var faceSdk = FaceSDK.instance;

  // set status(String val) => _status = val;
  // set similarityStatus(String val) => _similarityStatus = val;

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
  late StreamSubscription _sub;
  var remainingSec = 30.obs;
  var timerStat = false.obs;
  File? capturedImage;
  var barcodeScanRes = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    // if (!await initialize()) return;
    // status = "Ready";
    timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
    Timer.periodic(const Duration(seconds: 1), (Timer t) async => timeNetwork(await FlutterNativeTimezone.getLocalTimezone()));

    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin =
        Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
    idUser.value = dataUserLogin.id!;
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramLimitVisit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tanggal_masuk": dateNow
    };

    var paramSingleVisit = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tgl_visit": dateNow
    };

    date1 = TextEditingController();
    date2 = TextEditingController();
    store = TextEditingController();
    userCab = TextEditingController();
    rndLoc = TextEditingController();
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

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      currVer = packageInfo.version;
    });

    if (Platform.isAndroid) {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.61/update apk/updateLog.xml'));

      if (readDoc.statusCode == 200) {
        //parsing readDoc
        final document = xml.XmlDocument.parse(readDoc.body);
        final cLog = document.findElements('items').first;
        latestVer = cLog.findElements('versi').first.innerText;
        if (int.parse(latestVer.replaceAll('.', '')) >
            int.parse(currVer.replaceAll('.', ''))) {
          checkForUpdates("onInit");
        }
      }

      final DeviceInfoNullSafety deviceInfoNullSafety = DeviceInfoNullSafety();
      Map<String, dynamic> abiInfo = await deviceInfoNullSafety.abiInfo;
      var abi = abiInfo.entries.toList();
      supportedAbi = abi[1].value;
    }

    _startDateStream(paramSingle, paramLimit, paramSingleVisit, paramLimitVisit,
        dataUserLogin);
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

  void _startDateStream(paramSingle, paramLimit, paramSingleVisit,
      paramLimitVisit, Data dataUserLogin) {
    // Buat Stream yang mengeluarkan tanggal setiap detik
    final dateStream =
        Stream.periodic(const Duration(seconds: 5), (_) => DateTime.now());
    // Perbarui nilai tanggal di _dateStream setiap kali Stream mengeluarkan nilai baru
    _sub = dateStream.listen((date) async {
      _dateStream.value = date;
      tglStream.value = date;

      if (dataUserLogin.visit == "0") {
        // start cek absen

        var tempDataAbs = await SQLHelper.instance.getAllAbsenToday(dateNow);

        await cekDataAbsen(
            "masuk",
            idUser.value,
            DateFormat('yyyy-MM-dd').format(DateTime.parse(
                dateNowServer.isNotEmpty ? dateNowServer : dateNow)));

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
                "device_info": i.devInfo!
              };
              // submit data absensi ke server
              // log(data.toString());
              await ServiceApi().submitAbsen(data, true);
            }
            _sub.cancel();
          } else {
            _sub.cancel();
          }

          getAbsenToday(paramSingle);
          getLimitAbsen(paramLimit);
        } else {
          await cekDataAbsen(
              "pulang",
              idUser.value,
              DateFormat('yyyy-MM-dd').format(DateTime.parse(
                  dateNowServer.isNotEmpty ? dateNowServer : dateNow)));
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
                  "device_info2": i.devInfo2!
                };
                await ServiceApi().submitAbsen(data, true);
                _sub.cancel();
              }
            } else {
              _sub.cancel();
            }
          } else {
            _sub.cancel();
          }
          getAbsenToday(paramSingle);
          getLimitAbsen(paramLimit);
        }
        // urut.value++;
        // end cek absen
      } else {
        // cek visit

        var tempDataVisit = await SQLHelper.instance
            .getVisitToday(idUser.value, dateNow, '', 0);

        // if (tempDataVisit.isNotEmpty) {

        await cekDataVisit(
            tempDataVisit.isNotEmpty && tempDataVisit.length == 1
                ? "masuk"
                : "masukv2",
            idUser.value,
            DateFormat('yyyy-MM-dd').format(DateTime.parse(
                dateNowServer.isNotEmpty ? dateNowServer : dateNow)),
            tempDataVisit.isNotEmpty && tempDataVisit.length == 1
                ? tempDataVisit.first.visitIn!
                : '');

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
                "is_rnd": i.isRnd!
              };
              // log(data.toString());
              await ServiceApi().submitVisit(data, true);
            }
            _sub.cancel();
          } else {
            // timerStat.value = false;
            // startTimer(0);
            _sub.cancel();
          }
          getVisitToday(paramSingleVisit);
          getLimitVisit(paramLimitVisit);
        } else {
          await cekDataVisit(
              tempDataVisit.length == 1 ? "pulang" : "pulangv2",
              idUser.value,
              DateFormat('yyyy-MM-dd').format(DateTime.parse(
                  dateNowServer.isNotEmpty ? dateNowServer : dateNow)),
              tempDataVisit.length == 1 ? tempDataVisit.first.visitIn! : '');

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
                  "device_info2": i.deviceInfo2!
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
      }
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
              long: e.long)))
          .toList();
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
      // DateTime.parse(response['dateTime']).timeZoneName;
      // timeNow = DateFormat('HH:mm').format(DateTime.now()).toString();
      // print(DateTime.parse(response['dateTime']).timeZoneName);
      dateNowServer = response['dateTime'];
    } on HandshakeException catch (_) {}
  }

  getLoc(Data? dataUser) async {
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
      // timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
      dialogAbsenView(dataUser!, position.latitude, position.longitude);
    }
  }

  scanQrLoc(Data? dataUser) async {
    // String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes.value = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);
      // print(barcodeScanRes);
      if (barcodeScanRes.value == "-1") {
        // cekStokC.cariArtikel.clear();
      } else {
        // if (barcodeScanRes.contains(dataUser!.lat.toString()) &&
        //     barcodeScanRes.contains(dataUser.long.toString())) {
        if (barcodeScanRes.value.isAlphabetOnly) {
          showToast("QR tidak dikenal");
        } else {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              double.parse(barcodeScanRes.value.split(' ')[0]),
              double.parse(barcodeScanRes.value.split(' ')[1]));
          lokasi.value =
              '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
          // timeNetwork(await FlutterNativeTimezone.getLocalTimezone());
          dialogAbsenView(
              dataUser!,
              double.parse(barcodeScanRes.value.split(' ')[0]),
              double.parse(barcodeScanRes.value.split(' ')[1]));
        }
        // }
      }
    } on PlatformException {
      barcodeScanRes.value = 'Failed to get platform version.';
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
        pw.Text('Tanggal',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Cabang',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Nama',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Shift',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Masuk',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Foto',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Status Masuk',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Keluar',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Foto',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
        pw.Text('Status Keluar',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font)),
      ],
    ));

    for (var data in searchAbsen) {
      pw.MemoryImage? imageMasuk;
      if (data.fotoMasuk! != "") {
        final img1 = await http
            .get(
              Uri.parse('${ServiceApi().baseUrl}${data.fotoMasuk!}'),
            )
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

      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(
          color: PdfColors.grey200,
        ),
        children: [
          pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(data.tanggalMasuk!)),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                  ))),
          pw.Text(data.namaCabang!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Text(data.nama!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Text(data.namaShift!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          pw.Text(data.jamAbsenMasuk!,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font)),
          data.fotoMasuk! != ""
              ? pw.Container(
                  width: 30,
                  height: 30,
                  child: pw.Center(child: pw.Image(imageMasuk!)),
                )
              : pw.Container(
                  width: 30,
                  height: 30,
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
      // var img = base64.encode(File(image!.path).readAsBytesSync());
      // log(image!.path, name: 'PATH');
      update();
    } else {
      return;
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

    if (tempDataAbs.isNotEmpty) {
      if (response.isNotEmpty && response[0].jamAbsenPulang != "") {
        dataAbsen.value = response;
      } else if (response.isNotEmpty &&
          response[0].jamAbsenMasuk != tempDataAbs[0].jamAbsenMasuk!) {
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
    isLoading.value = true;
    var tempSingleAbs = await SQLHelper.instance
        .getLimitDataAbsen(idUser.value, initDate1, initDate2);

    if (tempSingleAbs.isNotEmpty) {
      if (response.isEmpty ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tanggalMasuk!).isBefore(
                  DateTime.parse(tempSingleAbs.first.tanggalMasuk!)) ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tanggalMasuk!).isAtSameMomentAs(
                  DateTime.parse(tempSingleAbs.first.tanggalMasuk!)) &&
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
          .get(Uri.parse('http://103.156.15.61/update apk/updateLog.xml'))
          .timeout(const Duration(seconds: 20));
      final response = await http
          .head(Uri.parse(supportedAbi == 'arm64-v8a'
              ? 'http://103.156.15.61/update apk/absensiApp.arm64v8a.apk'
              : 'http://103.156.15.61/update apk/absensiApp.apk'))
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
        if (int.parse(latestVer.replaceAll('.', '')) <=
            int.parse(currVer.replaceAll('.', ''))) {
          if (status != "onInit") {
            Get.back(closeOverlays: true);
            succesDialog(Get.context!, "N", "Tidak ada pembaruan sistem",
                DialogType.info, 'INFO');
          }
        } else {
          dialogUpdateApp();
        }
      } else {
        succesDialog(Get.context!, "N", "Tidak ada pembaruan sistem",
            DialogType.info, 'INFO');
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
    } on TimeoutException catch (_) {
      Get.back(closeOverlays: true);
      showToast("Waktu untuk koneksi ke server telah habis");
    }
  }

  getVisitToday(Map<String, dynamic> paramSingleVisit) async {
    final response = await ServiceApi().getVisit(paramSingleVisit);
    var tempDataVisit =
        await SQLHelper.instance.getVisitToday(idUser.value, dateNow, '', 1);

    if (tempDataVisit.isNotEmpty) {
      if (response.isNotEmpty &&
          response.first.jamOut != "" &&
          response.first.visitIn! == tempDataVisit.first.visitIn!) {
        dataVisit.value = response;
      } else {
        dataVisit.value = tempDataVisit;
      }
    } else {
      isLoading.value = false;
      dataVisit.value = response;
    }

    return dataVisit;
  }

  getLimitVisit(Map<String, dynamic> paramLimitVisit) async {
    final response = await ServiceApi().getLimitVisit(paramLimitVisit);
    dataLimitVisit.clear();

    var tempLimitVisit =
        await SQLHelper.instance.getVisitToday(idUser.value, dateNow, '', 0);

    if (tempLimitVisit.isNotEmpty) {
      if (response.isEmpty ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tglVisit!)
                  .isBefore(DateTime.parse(tempLimitVisit.first.tglVisit!)) ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tglVisit!).isAtSameMomentAs(
                  DateTime.parse(tempLimitVisit.first.tglVisit!)) &&
              response.first.jamOut! == "" &&
              tempLimitVisit.first.jamOut! != "" ||
          response.isNotEmpty &&
              DateTime.parse(response.first.tglVisit!).isAtSameMomentAs(
                  DateTime.parse(tempLimitVisit.first.tglVisit!)) &&
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
    var dataUserLogin =
        Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
    idUser.value = dataUserLogin.id!;
    var paramLimit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramLimitVisit = {
      "mode": "limit",
      "id_user": dataUserLogin.id!,
      "tanggal1": initDate1,
      "tanggal2": initDate2
    };

    var paramSingle = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tanggal_masuk": dateNow
    };

    var paramSingleVisit = {
      "mode": "single",
      "id_user": dataUserLogin.id,
      "tgl_visit": dateNow
    };

    return _startDateStream(paramSingle, paramLimit, paramSingleVisit,
        paramLimitVisit, dataUserLogin);
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
      String device) async {
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
      "device_info": device
    };
    await ServiceApi().sendDataToXmor(data);
  }
}
