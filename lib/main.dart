import 'dart:convert';
import 'dart:ui';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/notif_helper.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/data/helper/error_logger.dart';
import 'app/data/helper/navigator_helper.dart';
import 'app/data/model/login_model.dart';
import 'app/data/theme_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/service_api.dart';
import 'firebase_options.dart';
import 'root_view.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final pref = await SharedPreferences.getInstance();
  final currentUserId = Data.fromJson(
    jsonDecode(pref.getString('userDataLogin')!),
  );

  final targetUserId = message.data['target_user_id'];

  if (targetUserId != currentUserId.id) {
    // debugPrint('SKIP NOTIFICATION');
    return;
  }

  await NotificationHelper.init();

  NotificationHelper.show(
    title: message.data['title'] ?? '',
    // body: message.data['body'] ?? '',
    name: message.data['nama'] ?? '',
    msg: message.data['msg'] ?? '',
    data: message.data,
  );
  // debugPrint("Background Message: ${message.messageId}");
}

RemoteMessage? pendingNotification;
bool notificationHandled = false;
Map<String, dynamic>? pendingLaunchPayload;
bool launchPayloadHandled = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // <-- transparan
      statusBarIconBrightness: Brightness.light, // icon putih
      statusBarBrightness: Brightness.dark, // iOS
      // systemNavigationBarColor: Color(0xFF1B2541),
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    Future.microtask(() {
      ErrorLogger.save('''
        TYPE: FLUTTER_FRAMEWORK

        TIME:
        ${DateTime.now()}

        EXCEPTION:
        ${details.exceptionAsString()}

        LIBRARY:
        ${details.library}

        CONTEXT:
        ${details.context}

        STACK:
        ${details.stack}
        ''', '');
    });

    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Future.microtask(() {
      ErrorLogger.save('''
        TYPE: PLATFORM_ERROR

        TIME:
        ${DateTime.now()}

        ERROR:
        $error

        STACK:
        $stack
        ''', '');
    });

    return true;
  };

  ErrorWidget.builder = (details) {
    Future.microtask(() {
      ErrorLogger.save('''
        TYPE: ERROR_WIDGET

        TIME:
        ${DateTime.now()}

        EXCEPTION:
        ${details.exceptionAsString()}

        LIBRARY:
        ${details.library}

        CONTEXT:
        ${details.context}

        STACK:
        ${details.stack}
        ''', '');
    });

    return Material(
      color: Colors.red,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            details.exceptionAsString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper.init(); // init notif on bg
  pendingLaunchPayload = await NotificationHelper.getLaunchPayload();
  // debugPrint("NOTIF_DEBUG: MAIN PAYLOAD = $pendingLaunchPayload");

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    pendingNotification = initialMessage;
  }

  Get.put(LoginController());
  Get.put(HomeController());
  final themeC = Get.put(ThemeController());

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    try {
      final loginC = Get.find<LoginController>();

      if (loginC.logUser.value.id != null) {
        await ServiceApi().saveFcmToken({
          "id_user": loginC.logUser.value.id,
          "token": newToken,
        });
      }
    } catch (_) {}
  });

  FirebaseMessaging.onMessage.listen((message) async {
    final targetUserId = message.data['target_user_id'];

    final loginC = Get.find<LoginController>();

    final currentUserId = loginC.logUser.value.id.toString();

    if (targetUserId != currentUserId) {
      // debugPrint("SKIP NOTIFICATION");
      return;
    }

    await NotificationHelper.show(
      title: message.data['title'] ?? '',
      name: message.data['nama'] ?? '',
      msg: message.data['msg'] ?? '',
      data: message.data,
    );

    // NotificationHelper.showNotifOpenedApp(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // debugPrint("FCM OPENED");
    NotificationNavigation.handleNotificationRm(message);
  });
  await initializeDateFormatting('id_ID', "");

  runApp(
    Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: dotenv.env['APP_NAME'].toString(),

        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: false,
          canvasColor: AppColors.pageBackground,
          fontFamily: 'Nunito',
        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: false,
          canvasColor: const Color(0xFF121212),
          fontFamily: 'Nunito',
        ),
        themeMode: themeC.themeMode.value,
        home: const RootView(),
        localizationsDelegates: const [MonthYearPickerLocalizations.delegate],
        getPages: AppPages.routes,
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
      ),
    ),
  );
}
