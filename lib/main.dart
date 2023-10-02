import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/home/views/home_menu.dart';
import 'package:absensi/app/modules/home/views/splash_view.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/login/views/login_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/routes/app_pages.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
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
  

  await initializeDateFormatting('id_ID', "").then((_) => runApp(
        FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashView();
              } else {
                return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: "Absensi",
                  theme: ThemeData(
                      primarySwatch: mainColor,
                      fontFamily: 'Nunito',
                      canvasColor: backgroundColor),
                  home: Obx(() => auth.isAuth.value
                      ? HomeMenu(listDataUser: auth.logUser)
                      : const LoginView()),
                  getPages: AppPages.routes,
                );
              }
            }),
      ));
}
