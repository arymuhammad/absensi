import 'dart:convert';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';

// import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'app/modules/home/views/bottom_navbar.dart';
import 'app/modules/login/views/login_view.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting('id_ID', "");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getBool('is_login') ?? false;
  var userDataLogin = prefs.getString('userDataLogin') ?? "";

  final auth = Get.put(LoginController());

  if (auth.isAuth.value == false) {
    auth.isAuth.value = status;
  }
  if (auth.logUser.value.id == null) {
    auth.logUser.value =
        userDataLogin != "" ? Data.fromJson(jsonDecode(userDataLogin)) : Data();
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: dotenv.env['APP_NAME'].toString(),
      theme: ThemeData(
        useMaterial3: false,
        // primarySwatch: mainColor,
        // primaryColor: Colors.white,
        canvasColor: AppColors.pageBackground,
        fontFamily: 'Nunito',
      ),
      home: SplashScreenView(
        navigateRoute:
        // LeaveView(userData: auth.logUser.value),
        Obx(
          () =>
              auth.isAuth.value
                  ? BottomNavBar(listDataUser: auth.logUser.value)
                  : const LoginView(),
        ),
        duration: 2700,
        imageSize: 70,
        imageSrc: "assets/image/logo2.png",
        // text: 'E-Cashier', textType: TextType.TyperAnimatedText,
        textStyle: const TextStyle(
          fontSize: 40.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        pageRouteTransition: PageRouteTransition.SlideTransition,
        backgroundColor: AppColors.itemsBackground,
      ),
      localizationsDelegates: const [MonthYearPickerLocalizations.delegate],
      getPages: AppPages.routes,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    ),
  );
}
