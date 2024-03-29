import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/home/views/bottom_navbar.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/login/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';


import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
  ]);
  
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

  await initializeDateFormatting('id_ID', "").then((_) => runApp(GetMaterialApp(
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
      )));
}
