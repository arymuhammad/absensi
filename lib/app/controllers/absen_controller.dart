import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/model/cek_visit_model.dart';
import 'package:absensi/app/model/user_model.dart';
import 'package:absensi/app/model/visit_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/app/model/shift_kerja_model.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:percent_indicator/percent_indicator.dart';
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
  var userPostLat = 0.0.obs;
  var userPostLong = 0.0.obs;
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
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        devInfo.value = '${androidInfo.brand} ${androidInfo.model}';
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        devInfo.value = '${iosInfo.name} ${iosInfo.model}';
      }
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

      if (dataUser![9] == "26" || dataUser[9] == "28" || dataUser[9] == "10") {
        msg.value = "Pilih lokasi kunjungan Anda";
        AwesomeDialog(
                context: Get.context!,
                dialogType: DialogType.info,
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                headerAnimationLoop: false,
                animType: AnimType.bottomSlide,
                title: 'INFO',
                desc: msg.value,
                body: Column(
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
                            value: selectedCabangVisit.value == ""
                                ? null
                                : selectedCabangVisit.value,
                            onChanged: (data) {
                              selectedCabangVisit.value = data!;

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
                  ],
                ),
                btnCancelOnPress: () {
                  selectedCabangVisit.value = "";
                  auth.selectedMenu(0);
                },
                btnOkOnPress: () async {
                  await cekDataVisit(
                      "masuk",
                      dataUser[0],
                      dateNow,
                      selectedCabangVisit.isNotEmpty
                          ? selectedCabangVisit.value
                          : dataUser[8]);
                  if (cekVisit.value.total == "0") {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    double distance = Geolocator.distanceBetween(
                        double.parse(lat.isNotEmpty ? lat.value : dataUser[6]),
                        double.parse(
                            long.isNotEmpty ? long.value : dataUser[7]),
                        position.latitude.toDouble(),
                        position.longitude.toDouble());
                    await pref.setStringList('userLoc', <String>[
                      lat.isNotEmpty ? lat.value : dataUser[6],
                      long.isNotEmpty ? long.value : dataUser[7]
                    ]);

                    distanceStore.value = distance;
                    // CEK POSISI USER SAAT HENDAK ABSEN
                    if (distanceStore.value > num.parse(dataUser[11])) {
                      //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                      Get.back();
                      dialogMsgCncl('Terjadi Kesalahan',
                          'Anda berada diluar area absen\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                      selectedCabangVisit.value = "";
                      lat.value = "";
                      long.value = "";
                    } else {
                      await uploadFotoAbsen();
                      Get.back();
                      if (image != null) {
                        var data = {
                          "status": "add",
                          "id": dataUser[0],
                          "nama": dataUser[1],
                          "tgl_visit": DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(dateNowServer)),
                          "visit_in": selectedCabangVisit.isNotEmpty
                              ? selectedCabangVisit.value
                              : dataUser[8],
                          "jam_in": timeNow.toString(),
                          "foto_in": File(image!.path.toString()),
                          "lat_in": position.latitude.toString(),
                          "long_in": position.longitude.toString(),
                          "device_info": devInfo.value
                        };

                        loadingDialog("Sedang mengirim data...", "");
                        await ServiceApi().submitVisit(data);
                        await Future.delayed(const Duration(milliseconds: 600));
                        Get.back();
                        succesDialog(Get.context, "Y", "Anda berhasil Absen");
                      }
                      var paramVisitToday = {
                        "mode": "single",
                        "id_user": dataUser[0],
                        "tgl_visit": DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(dateNowServer))
                      };

                      var paramLimitVisit = {
                        "mode": "limit",
                        "id_user": dataUser[0],
                        // "tanggal1": initDate1,
                        // "tanggal2": initDate2
                      };
                      getVisitToday(paramVisitToday);
                      getLimitVisit(paramLimitVisit);
                      selectedCabangVisit.value = "";
                      lat.value = "";
                      long.value = "";
                    }
                  } else {
                    await cekDataVisit(
                        "pulang",
                        dataUser[0],
                        dateNow,
                        selectedCabangVisit.isNotEmpty
                            ? selectedCabangVisit.value
                            : dataUser[8]);
                    if (cekVisit.value.total == "1") {
                      // print(cekVisit.value.total);
                      // print(cekVisit.value.visitStore);
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      double distance = Geolocator.distanceBetween(
                          double.parse(
                              lat.isNotEmpty ? lat.value : dataUser[6]),
                          double.parse(
                              long.isNotEmpty ? long.value : dataUser[7]),
                          position.latitude.toDouble(),
                          position.longitude.toDouble());
                      await pref.setStringList('userLoc', <String>[
                        lat.isNotEmpty ? lat.value : dataUser[6],
                        long.isNotEmpty ? long.value : dataUser[7]
                      ]);

                      distanceStore.value = distance;
                      // CEK POSISI USER SAAT HENDAK ABSEN
                      if (distanceStore.value > num.parse(dataUser[11])) {
                        //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                        Get.back();
                        dialogMsgCncl('Terjadi Kesalahan',
                            'Anda berada diluar area absen\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                        selectedCabangVisit.value = "";
                        lat.value = "";
                        long.value = "";
                      } else {
                        await uploadFotoAbsen();
                        Get.back();
                        if (image != null) {
                          var data = {
                            "status": "update",
                            "id": dataUser[0],
                            "nama": dataUser[1],
                            "tgl_visit": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(dateNowServer)),
                            "visit_out": selectedCabangVisit.isNotEmpty
                                ? selectedCabangVisit.value
                                : dataUser[8],
                            "visit_in": cekVisit.value.kodeStore,
                            "jam_out": timeNow.toString(),
                            "foto_out": File(image!.path.toString()),
                            "lat_out": position.latitude.toString(),
                            "long_out": position.longitude.toString(),
                            "device_info2": devInfo.value
                          };
                          // print(data);
                          loadingDialog("Sedang mengirim data...", "");
                          await ServiceApi().submitVisit(data);
                          selectedCabangVisit.value = "";
                          lat.value = "";
                          long.value = "";
                          await Future.delayed(
                              const Duration(milliseconds: 600));
                          Get.back();
                          succesDialog(Get.context, "Y", "Anda berhasil Absen");
                        }
                        var paramVisitToday = {
                          "mode": "single",
                          "id_user": dataUser[0],
                          "tgl_visit": DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(dateNowServer))
                        };

                        var paramLimitVisit = {
                          "mode": "limit",
                          "id_user": dataUser[0]
                        };
                        getVisitToday(paramVisitToday);
                        getLimitVisit(paramLimitVisit);
                      }
                    } else {
                      showToast(
                          "sudah keluar dari kunjungan ke ${selectedCabangVisit.isNotEmpty ? selectedCabangVisit.value : dataUser[8]}");
                    }
                  }
                },
                btnCancelText: 'Batal',
                btnCancelColor: Colors.redAccent[700],
                btnCancelIcon: Icons.cancel,
                btnOkText: 'Foto',
                btnOkColor: Colors.blueAccent[700],
                btnOkIcon: Icons.camera_front_outlined)
            .show();
      } else {
        // print(dateNowServer);
        var previous = DateFormat('yyyy-MM-dd').format(
            DateTime.parse(dateNowServer.isNotEmpty ? dateNowServer : dateNow)
                .add(const Duration(days: -1)));
        // Get the current time
        DateTime now = DateTime.now();
        TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

        // Set the target time to 8:00 AM
        TimeOfDay targetTime = const TimeOfDay(hour: 6, minute: 0);

        // Convert TimeOfDay to DateTime for proper comparison
        DateTime currentDateTime = DateTime(
            now.year, now.month, now.day, currentTime.hour, currentTime.minute);
        DateTime targetDateTime = DateTime(
            now.year, now.month, now.day, targetTime.hour, targetTime.minute);

        // Compare the current time with the target time
        bool isBefore6AM = currentDateTime.isBefore(targetDateTime);
        // print(isBefore6AM);

        if (isBefore6AM) {
          await cekDataAbsen("pulang", dataUser[0], previous);
          if (cekAbsen.value.total == "0") {
            // CEK ABSEN PULANG DITANGGAL H+1
            AwesomeDialog(
                    context: Get.context!,
                    dialogType: DialogType.info,
                    dismissOnTouchOutside: false,
                    dismissOnBackKeyPress: false,
                    headerAnimationLoop: false,
                    animType: AnimType.bottomSlide,
                    title: 'INFO',
                    desc: "Absen pulang hari ini?",
                    body: Column(children: [
                      Text(
                          'Absen pulang hari ini?\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi'),
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
                    ]),
                    btnCancelOnPress: () {
                      selectedCabang.value = "";
                      lat.value = "";
                      long.value = "";
                      auth.selectedMenu(0);
                      showToast("Absen pulang dibatalkan");
                    },
                    btnOkOnPress: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      double distance = Geolocator.distanceBetween(
                          double.parse(
                              lat.isNotEmpty ? lat.value : dataUser[6]),
                          double.parse(
                              long.isNotEmpty ? long.value : dataUser[7]),
                          position.latitude.toDouble(),
                          position.longitude.toDouble());
                      await pref.setStringList('userLoc', <String>[
                        lat.isNotEmpty ? lat.value : dataUser[6],
                        long.isNotEmpty ? long.value : dataUser[7]
                      ]);

                      distanceStore.value = distance;
                      // CEK POSISI USER SAAT HENDAK ABSEN
                      if (distanceStore.value > num.parse(dataUser[11])) {
                        //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                        Get.back();
                        dialogMsgCncl('Terjadi Kesalahan',
                            'Anda berada diluar area absen\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                        selectedCabang.value = "";
                        lat.value = "";
                        long.value = "";
                      } else {
                        await uploadFotoAbsen();

                        Get.back();
                        loadingDialog("Sedang mengirim data...", "");

                        if (image != null) {
                          var data = {
                            "status": "update",
                            "id": dataUser[0],
                            "tanggal_masuk": previous,
                            "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(dateNowServer)),
                            "nama": dataUser[1],
                            "jam_absen_pulang": timeNow.toString(),
                            "foto_pulang": File(image!.path.toString()),
                            "lat_pulang": position.latitude.toString(),
                            "long_pulang": position.longitude.toString(),
                            "device_info2": devInfo.value
                          };
                          // print(data);
                          await ServiceApi().submitAbsen(data);

                          var paramAbsenToday = {
                            "mode": "single",
                            "id_user": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(dateNowServer))
                          };

                          var paramLimitAbsen = {
                            "mode": "limit",
                            "id_user": dataUser[0],
                            "tanggal1": initDate1,
                            "tanggal2": initDate2
                          };
                          getAbsenToday(paramAbsenToday);
                          getLimitAbsen(paramLimitAbsen);
                          selectedCabang.value = "";
                          lat.value = "";
                          long.value = "";
                          await Future.delayed(
                              const Duration(milliseconds: 400));
                          Get.back();
                          succesDialog(Get.context, "Y", "Anda berhasil Absen");
                        } else {
                          Get.back();
                          failedDialog(Get.context, "Peringatan",
                              "Absen Pulang dibatalkan");
                        }
                      }
                    },
                    btnCancelText: 'Batalkan',
                    btnCancelColor: Colors.redAccent[700],
                    btnCancelIcon: Icons.cancel,
                    btnOkText: 'Foto',
                    btnOkColor: Colors.blueAccent[700],
                    btnOkIcon: Icons.camera_front)
                .show();
          } else {
            succesDialog(
                Get.context, "Y", "Anda sudah absen pulang sebelum nya.");
          }
          // JIKA TIDAK ADA ABSEN PULANG MENGGANTUNG, LANJUT KE TAHAP SELANJUTNYA
        } else {
          // JIKA POSISI DALAM JANGKAUAN/AREA ABSEN, PROSES ABSEN BERLANJUT
          await cekDataAbsen(
              "masuk",
              dataUser[0],
              DateFormat('yyyy-MM-dd').format(DateTime.parse(
                  dateNowServer.isNotEmpty ? dateNowServer : dateNow)));

          // CEK ABSEN MASUK TODAY, JIKA HASIL 0 ABSEN MASUK
          if (cekAbsen.value.total == "0") {
            msg.value = "Absen masuk hari ini?";
            AwesomeDialog(
                    context: Get.context!,
                    dialogType: DialogType.info,
                    dismissOnTouchOutside: false,
                    dismissOnBackKeyPress: false,
                    headerAnimationLoop: false,
                    animType: AnimType.bottomSlide,
                    title: 'INFO',
                    desc: msg.value,
                    body: Column(
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
                                    jamPulang.value = DateFormat("HH:mm")
                                        .format(DateTime.parse(dateNowServer)
                                            .add(const Duration(hours: 8)));
                                  } else {
                                    for (int i = 0; i < dataShift.length; i++) {
                                      if (dataShift[i].id == data) {
                                        jamMasuk.value = dataShift[i].jamMasuk!;
                                        jamPulang.value =
                                            dataShift[i].jamPulang!;
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
                    btnCancelOnPress: () {
                      selectedShift.value = "";
                      selectedCabang.value = "";
                      lat.value = "";
                      long.value = "";
                      auth.selectedMenu(0);
                    },
                    btnOkOnPress: () async {
                      if (selectedShift.isEmpty) {
                        showToast("Harap pilih Shift Absen");
                      } else {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        double distance = Geolocator.distanceBetween(
                            double.parse(
                                lat.isNotEmpty ? lat.value : dataUser[6]),
                            double.parse(
                                long.isNotEmpty ? long.value : dataUser[7]),
                            position.latitude.toDouble(),
                            position.longitude.toDouble());
                        await pref.setStringList('userLoc', <String>[
                          lat.isNotEmpty ? lat.value : dataUser[6],
                          long.isNotEmpty ? long.value : dataUser[7]
                        ]);

                        distanceStore.value = distance;
                        // CEK POSISI USER SAAT HENDAK ABSEN
                        if (distanceStore.value > num.parse(dataUser[11])) {
                          //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                          Get.back();
                          dialogMsgCncl('Terjadi Kesalahan',
                              'Anda berada diluar area absen\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');
                          selectedShift.value = "";
                          selectedCabang.value = "";
                          lat.value = "";
                          long.value = "";
                        } else {
                          await uploadFotoAbsen();
                          Get.back();
                          if (image != null) {
                            var data = {
                              "status": "add",
                              "id": dataUser[0],
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(dateNowServer)),
                              "kode_cabang": selectedCabang.isNotEmpty
                                  ? selectedCabang.value
                                  : dataUser[8],
                              "nama": dataUser[1],
                              "id_shift": selectedShift.value,
                              "jam_masuk": jamMasuk.value,
                              "jam_pulang": jamPulang.value,
                              "jam_absen_masuk": timeNow.toString(),
                              "foto_masuk": File(image!.path.toString()),
                              "lat_masuk": position.latitude.toString(),
                              "long_masuk": position.longitude.toString(),
                              "device_info": devInfo.value
                            };

                            loadingDialog("Sedang mengirim data...", "");
                            await ServiceApi().submitAbsen(data);
                            await Future.delayed(
                                const Duration(milliseconds: 600));
                            Get.back();
                            succesDialog(
                                Get.context, "Y", "Anda berhasil Absen");
                          }
                          var paramAbsenToday = {
                            "mode": "single",
                            "id_user": dataUser[0],
                            "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(dateNowServer))
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
                          lat.value = "";
                          long.value = "";
                        }
                      }
                    },
                    btnCancelText: 'Batal',
                    btnCancelColor: Colors.redAccent[700],
                    btnCancelIcon: Icons.cancel,
                    btnOkText: 'Foto',
                    btnOkColor: Colors.blueAccent[700],
                    btnOkIcon: Icons.camera_front_outlined)
                .show();
          } else {
            // PROSES ABSEN PULANG
            await cekDataAbsen("pulang", dataUser[0],
                DateFormat('yyyy-MM-dd').format(DateTime.parse(dateNowServer)));
            if (cekAbsen.value.total == "0") {
              msg.value =
                  "Pilih lokasi absen pulang\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi";

              AwesomeDialog(
                      context: Get.context!,
                      dialogType: DialogType.info,
                      dismissOnTouchOutside: false,
                      dismissOnBackKeyPress: false,
                      headerAnimationLoop: false,
                      animType: AnimType.bottomSlide,
                      title: 'INFO',
                      desc: msg.value,
                      body: Column(children: [
                        Center(child: Text(msg.value)),
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
                      ]),
                      btnCancelOnPress: () {
                        selectedCabang.value = "";
                        lat.value = "";
                        long.value = "";
                        auth.selectedMenu(0);
                      },
                      btnOkOnPress: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        double distance = Geolocator.distanceBetween(
                            double.parse(
                                lat.isNotEmpty ? lat.value : dataUser[6]),
                            double.parse(
                                long.isNotEmpty ? long.value : dataUser[7]),
                            position.latitude.toDouble(),
                            position.longitude.toDouble());
                        await pref.setStringList('userLoc', <String>[
                          lat.isNotEmpty ? lat.value : dataUser[6],
                          long.isNotEmpty ? long.value : dataUser[7]
                        ]);

                        distanceStore.value = distance;
                        // CEK POSISI USER SAAT HENDAK ABSEN
                        if (distanceStore.value > num.parse(dataUser[11])) {
                          //POSISI USER BERADA DILUAR JANGKAUAN/AREA ABSEN
                          Get.back();
                          dialogMsgCncl('Terjadi Kesalahan',
                              'Anda berada diluar area absen\nJarak anda ${distanceStore.value.toStringAsFixed(2)} m dari titik lokasi');

                          selectedCabang.value = "";
                          lat.value = "";
                          long.value = "";
                        } else {
                          await uploadFotoAbsen();

                          Get.back();
                          loadingDialog("Sedang mengirim data...", "");

                          if (image != null) {
                            var data = {
                              "status": "update",
                              "id": dataUser[0],
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(dateNowServer)),
                              "tanggal_pulang": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(dateNowServer)),
                              "nama": dataUser[1],
                              "jam_absen_pulang": timeNow.toString(),
                              "foto_pulang": File(image!.path.toString()),
                              "lat_pulang": position.latitude.toString(),
                              "long_pulang": position.longitude.toString(),
                              "device_info2": devInfo.value
                            };
                            await ServiceApi().submitAbsen(data);

                            var paramAbsenToday = {
                              "mode": "single",
                              "id_user": dataUser[0],
                              "tanggal_masuk": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(dateNowServer))
                            };

                            var paramLimitAbsen = {
                              "mode": "limit",
                              "id_user": dataUser[0],
                              "tanggal1": initDate1,
                              "tanggal2": initDate2
                            };
                            getAbsenToday(paramAbsenToday);
                            getLimitAbsen(paramLimitAbsen);
                            selectedCabang.value = "";
                            lat.value = "";
                            long.value = "";
                            await Future.delayed(
                                const Duration(milliseconds: 400));
                            Get.back();
                            succesDialog(
                                Get.context, "Y", "Anda berhasil Absen");
                          } else {
                            Get.back();
                            failedDialog(Get.context, "Peringatan",
                                "Absen Pulang dibatalkan");
                          }
                        }
                      },
                      btnCancelText: 'Batalkan',
                      btnCancelColor: Colors.redAccent[700],
                      btnCancelIcon: Icons.cancel,
                      btnOkText: 'Foto',
                      btnOkColor: Colors.blueAccent[700],
                      btnOkIcon: Icons.camera_front)
                  .show();
            } else {
              succesDialog(
                  Get.context, "Y", "Anda sudah Absen Pulang hari ini.");
            }
          }
        }
      }
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
    // print(dateAbsen);
    // print('$dateNow date');
    final response = await ServiceApi().cekDataAbsen(data);
    cekAbsen.value = response;
    // print(cekAbsen.value.tanggalMasuk!);
    // print(dateNow);
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
    // print(data);
    // print('$dateNow date');
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
      // Get.back();
      // loadingDialog("Memindai posisi Anda...", "");
      var loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              // textCancel: 'Batal',
              // onCancel: () => Get.back(),
              textConfirm: 'Unduh Pembaruan',
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
