import 'dart:io';

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/modules/home/views/bottom_navbar.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/login/views/login_view.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:workmanager/workmanager.dart';

import 'app/data/helper/loading_dialog.dart';
import 'app/routes/app_pages.dart';

const fetchBackground = "fetchBackground";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await initializeDateFormatting('id_ID', "");
  await Alarm.init();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getBool('is_login') ?? false;
  List<String> userDataLogin = prefs.getStringList('userDataLogin') ?? [""];
  final auth = Get.put(LoginController());

  if (auth.isAuth.value == false) {
    auth.isAuth.value = status;
  }
  if (auth.logUser.isEmpty) {
    auth.logUser.value = userDataLogin;
  }


  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: "URBAN&CO SPOT",
    theme: ThemeData(
        useMaterial3: false,
        primarySwatch: mainColor,
        primaryColor: Colors.white,
        fontFamily: 'Nunito',
        canvasColor: backgroundColor),
    home: SplashScreenView(
      navigateRoute: Obx(() => auth.isAuth.value
          ? BottomNavBar(listDataUser: auth.logUser)
          : const LoginView()),
      duration: 2700,
      imageSize: 140,
      imageSrc: "assets/image/logo_splash.png",
      // text: 'E-Cashier', textType: TextType.TyperAnimatedText,
      textStyle: const TextStyle(
        fontSize: 40.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      pageRouteTransition: PageRouteTransition.SlideTransition,
      backgroundColor: Colors.blue,
    ),
    getPages: AppPages.routes,
    navigatorObservers: [FlutterSmartDialog.observer],
    builder: FlutterSmartDialog.init(),
  ));
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await initializeDateFormatting('id_ID', "");
    var dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userDataLogin = prefs.getStringList('userDataLogin') ?? [""];

    switch (task) {
      case 'masuk':
        // Code to run in background

        var tempDataAbs = await SQLHelper.instance.getAllAbsenToday(dateNow);
        for (var i in tempDataAbs) {
          var data = {
            "status": "add",
            "id": i.idUser,
            "tanggal_masuk": i.tanggalMasuk,
            "kode_cabang": i.kodeCabang,
            "nama": i.nama,
            "id_shift": i.idShift,
            "jam_masuk": i.jamMasuk,
            "jam_pulang": i.jamPulang,
            "jam_absen_masuk": i.jamAbsenMasuk,
            "foto_masuk": File(i.fotoMasuk.toString()),
            "lat_masuk": i.latMasuk,
            "long_masuk": i.longMasuk,
            "device_info": i.devInfo
          };
          await ServiceApi().submitAbsen(data);
        }

        break;
      case 'pulang':
        var tempDataAbs = await SQLHelper.instance.getAllAbsenToday(dateNow);
        for (var i in tempDataAbs) {
          var data = {
            "status": "update",
            "id": i.idUser,
            "tanggal_masuk": i.tanggalMasuk,
            "tanggal_pulang": i.tanggalPulang,
            "nama": i.nama,
            "jam_absen_pulang": i.jamAbsenPulang,
            "foto_pulang": File(i.fotoPulang!),
            "lat_pulang": i.latPulang,
            "long_pulang": i.longPulang,
            "device_info2": i.devInfo2
          };
          await ServiceApi().submitAbsen(data);
        }

        break;
      case 'masukVisit':
        var tempDataVisit = await SQLHelper.instance
            .getVisitToday(userDataLogin[0], dateNow, '', 0);

        for (var i in tempDataVisit) {
          var data = {
            "status": "add",
            "id": i.id!,
            "nama": i.nama!,
            "tgl_visit": i.tglVisit!,
            "visit_in": i.visitIn!,
            "jam_in": i.jamIn!,
            "foto_in": File(i.fotoIn!.toString()),
            "lat_in": i.latIn!,
            "long_in": i.longIn!,
            "device_info": i.deviceInfo!,
            "is_rnd": i.isRnd!
          };
          await ServiceApi().submitVisit(data);
        }

        break;
      case 'pulangVisit':
        var tempDataVisit = await SQLHelper.instance
            .getVisitToday(userDataLogin[0], dateNow, '', 0);
        for (var i in tempDataVisit) {
          var data = {
            "status": "update",
            "id": i.id,
            "nama": i.nama,
            "tgl_visit": i.tglVisit,
            "visit_out": i.visitOut,
            "visit_in": i.visitIn,
            "jam_out": i.jamOut,
            "foto_out": File(i.fotoOut.toString()),
            "lat_out": i.latOut,
            "long_out": i.longOut,
            "device_info2": i.deviceInfo2
          };
          await ServiceApi().submitVisit(data);
        }

        break;
      default:
        showToast("Unknown task executed");
    }
    return Future.value(true);
  });
}
