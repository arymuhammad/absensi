import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/navigator_helper.dart';
import 'package:absensi/app/data/model/login_offline_model.dart';
import 'package:absensi/app/modules/pay_slip/controllers/pay_slip_controller.dart';
import 'package:absensi/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../../services/service_api.dart';
import '../../../data/model/login_model.dart';
import '../../absen/controllers/absen_controller.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  late TextEditingController email, username, password;
  var isLoading = false.obs;
  // var dataUser = Login().obs;
  var userSqlite = <LoginOffline>[].obs;
  var isAuth = false.obs;
  var selected = 0.obs;
  var logUser = Data().obs;
  var isPassHide = true.obs;
  var isReady = false.obs;
  // var animationLink = 'assets/animation/animated_login.riv';

  // StateMachineController? stateMachineController;
  late AnimationController ctrAnimated;

  @override
  void onInit() {
    super.onInit();
      _initialize();

    ctrAnimated = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    ctrAnimated.forward();
    ctrAnimated.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ctrAnimated.reset();
        ctrAnimated.forward();
      }
    });

    email = TextEditingController();
    username = TextEditingController();
    password = TextEditingController();
  }

  @override
  void onClose() {
    super.dispose();
    email.dispose();
    username.dispose();
    password.dispose();
  }

  Future<void> _initialize() async {
  // await initFCM();
  await loadSession();
}

  login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = {"username": username.text, "password": password.text};
    //get data from local storage
    // var dataOffline = await SQLHelper.instance.loginUserOffline(
    //   username.text,
    //   md5.convert(utf8.encode(password.text)).toString(),
    // );

    //checking data
    // if (dataOffline.isNotEmpty) {
    // showToast("ambil data dari sqlite");
    // FotoProfil foto = await ServiceApi().getFotoProfil({
    //   'id': dataOffline.first.id!,
    // });

    //   await pref.setString(
    //     'userDataLogin',
    //     jsonEncode(
    //       Data(
    //         id: dataOffline[0].id,
    //         nama: dataOffline[0].nama,
    //         username: dataOffline[0].username,
    //         password: dataOffline[0].password,
    //         kodeCabang: dataOffline[0].kodeCabang,
    //         namaCabang: dataOffline[0].namaCabang,
    //         nik: dataOffline[0].nik,
    //         lat: dataOffline[0].lat,
    //         long: dataOffline[0].long,
    //         // foto: foto.foto! != "" ? foto.foto! : dataOffline[0].foto,
    //         foto: dataOffline[0].foto,
    //         noTelp: dataOffline[0].noTelp,
    //         level: dataOffline[0].level,
    //         levelUser: dataOffline[0].levelUser,
    //         areaCover: dataOffline[0].areaCover,
    //         cekStok: dataOffline[0].cekStok,
    //         visit: dataOffline[0].visit,
    //         idRegion: dataOffline[0].idRegion,
    //         leaveBalance: dataOffline[0].leaveBalance,
    //         createdAt: dataOffline[0].createdAt,
    //         parentId: dataOffline[0].parentId,
    //         namaParent: dataOffline[0].namaParent,
    //       ),
    //     ),
    //   );

    //   var tempUser = pref.getString('userDataLogin');
    //   // print('user data login $tempUser');
    //   // final user = userDataLogin != "" ? Data.fromJson(jsonDecode(userDataLogin!)) : null;
    //   logUser.value = Data.fromJson(jsonDecode(tempUser!));

    //   // (tempUser != "" ? Data.fromJson(jsonDecode(tempUser!)) : null)!;
    //   isAuth.value = await pref.setBool("is_login", true);
    //   // isAuth.value = true;
    //   username.clear();
    //   password.clear();

    //   showToast("Selamat datang ${dataOffline[0].nama}");
    //   // Pastikan controller AbsenController sudah didaftarkan
    //   // if (!Get.isRegistered<AbsenController>()) {
    //   //   Get.put(AbsenController());
    //   // }
    // } else {
    try {
      var response = await ServiceApi().loginUser(data);
      // showToast("ambil data dari server");
      // dataUser.value = response;
      if (response.success == true) {
        await pref.setString(
          'userDataLogin',
          jsonEncode(
            Data(
              id: response.data!.id,
              nama: response.data!.nama,
              username: response.data!.username,
              password: response.data!.password,
              kodeCabang: response.data!.kodeCabang,
              namaCabang: response.data!.namaCabang,
              nik: response.data!.nik,
              lat: response.data!.lat,
              long: response.data!.long,
              foto: response.data!.foto,
              noTelp: response.data!.noTelp,
              level: response.data!.level,
              levelUser: response.data!.levelUser,
              areaCover: response.data!.areaCover,
              cekStok: response.data!.cekStok,
              visit: response.data!.visit,
              idRegion: response.data!.idRegion,
              leaveBalance: response.data!.leaveBalance,
              createdAt: response.data!.createdAt,
              parentId: response.data!.parentId,
              namaParent: response.data!.namaParent,
            ),
          ),
        );

        var tempUser = pref.getString('userDataLogin');
        logUser.value = Data.fromJson(jsonDecode(tempUser!));
        isAuth.value = await pref.setBool("is_login", true);
        // isAuth.value = true;

        // await SQLHelper.instance
        //     .getDataUser(response.data!.id!)
        //     .then((data) => userSqlite.value = data);

        // if (userSqlite.isEmpty) {
        //   //insert user data to sqlite
        //   await SQLHelper.instance.insertDataUser(
        //     LoginOffline(
        //       id: '${response.data!.id}',
        //       nama: '${response.data!.nama}',
        //       namaCabang: '${response.data!.namaCabang}',
        //       nik: '${response.data!.nik}',
        //       noTelp: '${response.data!.noTelp}',
        //       levelUser: '${response.data!.levelUser}',
        //       foto: '${response.data!.foto}',
        //       lat: '${response.data!.lat}',
        //       long: '${response.data!.long}',
        //       kodeCabang: '${response.data!.kodeCabang}',
        //       level: '${response.data!.level}',
        //       username: '${response.data!.username}',
        //       password: '${response.data!.password}',
        //       areaCover: '${response.data!.areaCover}',
        //       visit: '${response.data!.visit}',
        //       cekStok: '${response.data!.cekStok}',
        //       idRegion: '${response.data!.idRegion}',
        //       leaveBalance: '${response.data!.leaveBalance}',
        //       createdAt: '${response.data!.createdAt}',
        //       parentId: '${response.data!.parentId}',
        //       namaParent: '${response.data!.namaParent}',
        //     ),
        //   );
        //   //end of insert statement
        // }

        username.clear();
        password.clear();

        showToast("Selamat datang ${response.data!.nama}");

        // UPDATE TOKEN FIREBASE
        await updateFcmToken();

        // Pastikan controller AbsenController sudah didaftarkan
        // if (!Get.isRegistered<AbsenController>()) {
        //   Get.put(AbsenController());
        // }
      } else {
        showToast(response.message ?? "Terjadi kesalahan");
      }
    } catch (e) {
      showToast(e.toString()); // 🔥 semua error masuk sini
    }
    // }
  }

  loadSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    final status = pref.getBool('is_login') ?? false;
    final userDataLogin = pref.getString('userDataLogin') ?? "";

    if (status && userDataLogin.isNotEmpty) {
      logUser.value = Data.fromJson(jsonDecode(userDataLogin));
      isAuth.value = true;

      // UPDATE TOKEN FCM
      await updateFcmToken();

      if (pendingNotification != null && !notificationHandled) {
        notificationHandled = true;

        Future.delayed(const Duration(milliseconds: 300), () {
          NotificationNavigation.handleNotificationRm(pendingNotification!);
          pendingNotification = null;
        });
      }
    } else {
      isAuth.value = false;
    }

    isReady.value = true;
  }

  logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // await pref.clear();

    final userId = logUser.value.id;
    final token = await FirebaseMessaging.instance.getToken();
    // hapus relasi user-token di server
    await ServiceApi().deleteToken({"id_user": userId, "token": token});
    // await FirebaseMessaging.instance.deleteToken();

    await pref.remove("is_login");
    await pref.remove('userDataLogin');

    logUser.value = Data();

    isAuth.value = false;
    selected.value = 0;

    // Hapus semua controller yang memang ingin dihapus saja
    // if (Get.isRegistered<AbsenController>()) {
    //   final absenC = Get.find<AbsenController>();
    //   absenC.resetData(); // Reset semua nilai observable
    //   await Future.delayed(
    //     Duration(milliseconds: 100),
    //   ); // Opsional delay sebentar untuk proses reset
    // }

    Get.delete<AbsenController>(force: true); // Hapus instance controller lama
    Get.delete<PaySlipController>(force: true);

    // Get.back();
  }

  final navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  selectedMenu(index) {
    selected.value = index;
  }

  NavigatorState? currentNavigator() {
    return navigatorKeys[selected.value].currentState;
  }

  void pushInTab(Widget page) async {
    NavigatorState? nav;

    int retry = 0;

    while (nav == null && retry < 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      nav = currentNavigator();
      retry++;
    }

    if (nav != null) {
      nav.push(MaterialPageRoute(builder: (_) => page));
    } else {
      debugPrint("Navigator tetap null setelah retry");
    }
  }

  String computeUserChecksum(Data user) {
    // Gabungkan semua field yang ingin dibandingkan menjadi 1 string
    String combined =
        '${user.id ?? ""}|${user.nama ?? ""}|${user.username ?? ""}|${user.password ?? ""}|'
        '${user.kodeCabang ?? ""}|${user.namaCabang ?? ""}|${user.lat ?? ""}|${user.long ?? ""}|'
        '${user.foto ?? ""}|${user.noTelp ?? ""}|${user.level ?? ""}|${user.levelUser ?? ""}|'
        '${user.areaCover ?? ""}|${user.cekStok ?? ""}|${user.visit ?? ""}|${user.idRegion ?? ""}|'
        '${user.leaveBalance ?? ""}|${user.createdAt ?? ""}|${user.parentId ?? ""}|${user.namaParent ?? ""}';

    // Buat hash MD5 dari string gabungan ini
    return md5.convert(utf8.encode(combined)).toString();
  }

  // Future<void> initFCM() async {
  //   await FirebaseMessaging.instance.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  // }

  Future<void> updateFcmToken() async {
  try {
    if (Platform.isIOS) {
      String? apns;

      // Tunggu APNS maksimal 10 detik
      for (int i = 0; i < 10; i++) {
        apns = await FirebaseMessaging.instance.getAPNSToken();

        if (apns != null) break;

        await Future.delayed(const Duration(seconds: 1));
      }

      debugPrint("APNS TOKEN: $apns");

      if (apns == null) {
        debugPrint("APNS belum tersedia");
        return;
      }
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    debugPrint("FCM TOKEN: $token");

    await ServiceApi().saveFcmToken({
      "id_user": logUser.value.id,
      "token": token,
    });
  } catch (e) {
    debugPrint("Update FCM gagal: $e");
  }
}
}
