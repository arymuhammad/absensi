import 'package:absensi/app/modules/home/views/home_menu.dart';
import 'package:absensi/app/modules/home/views/home_view.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/login/views/login_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/controllers/page_index_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // // await GetStorage.init();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // final pageC = Get.put(PageIndexController(), permanent: true);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getBool('is_login') ?? false;
  List<String> userDataLogin = prefs.getStringList('userDataLogin') ?? [""];
  final auth = Get.put(LoginController());
  // final box = GetStorage();
  // print(userDataLogin);
  if (auth.isAuth.value == false) {
    auth.isAuth.value = status;
  }
  if (auth.logUser.isEmpty) {
    auth.logUser.value = userDataLogin;
  }

  print('ini data user di main =  ${auth.logUser}');
  //  else {
  //   print(auth.isAuth.value);
  // }
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      home: Obx(() => auth.isAuth.value
          ? HomeMenu(listDataUser: auth.logUser)
          : const LoginView()),
      getPages: AppPages.routes,
    ),
  );
}
