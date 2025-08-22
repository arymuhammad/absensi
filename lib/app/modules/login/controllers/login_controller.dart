import 'dart:convert';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_offline_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../../data/model/foto_profil_model.dart';
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

  // var animationLink = 'assets/animation/animated_login.riv';

  // StateMachineController? stateMachineController;
  late AnimationController ctrAnimated;

  @override
  void onInit() async {
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

    super.onInit();
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

  login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = {"username": username.text, "password": password.text};
    //get data from local storage
    var dataOffline = await SQLHelper.instance.loginUserOffline(
      username.text,
      md5.convert(utf8.encode(password.text)).toString(),
    );

    //checking data
    if (dataOffline.isNotEmpty) {
      // showToast("ambil data dari sqlite");
      FotoProfil foto = await ServiceApi().getFotoProfil({
        'id': dataOffline.first.id!,
      });

      await pref.setString(
        'userDataLogin',
        jsonEncode(
          Data(
            id: dataOffline[0].id,
            nama: dataOffline[0].nama,
            username: dataOffline[0].username,
            password: dataOffline[0].password,
            kodeCabang: dataOffline[0].kodeCabang,
            namaCabang: dataOffline[0].namaCabang,
            nik: dataOffline[0].nik,
            lat: dataOffline[0].lat,
            long: dataOffline[0].long,
            foto: foto.foto! != "" ? foto.foto! : dataOffline[0].foto,
            noTelp: dataOffline[0].noTelp,
            level: dataOffline[0].level,
            levelUser: dataOffline[0].levelUser,
            areaCover: dataOffline[0].areaCover,
            cekStok: dataOffline[0].cekStok,
            visit: dataOffline[0].visit,
            idRegion: dataOffline[0].idRegion,
            leaveBalance: dataOffline[0].leaveBalance,
            createdAt: dataOffline[0].createdAt,
            parentId: dataOffline[0].parentId,
            namaParent: dataOffline[0].namaParent,
          ),
        ),
      );

      var tempUser = pref.getString('userDataLogin');
      // print('user data login $tempUser');
      // final user = userDataLogin != "" ? Data.fromJson(jsonDecode(userDataLogin!)) : null;
      logUser.value = Data.fromJson(jsonDecode(tempUser!));

      // (tempUser != "" ? Data.fromJson(jsonDecode(tempUser!)) : null)!;
      isAuth.value = await pref.setBool("is_login", true);
      username.clear();
      password.clear();

      showToast("Selamat datang ${dataOffline[0].nama}");
      // Pastikan controller AbsenController sudah didaftarkan
      // if (!Get.isRegistered<AbsenController>()) {
      //   Get.put(AbsenController());
      // }
    } else {
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

        await SQLHelper.instance
            .getDataUser(response.data!.id!)
            .then((data) => userSqlite.value = data);

        if (userSqlite.isEmpty) {
          //insert user data to sqlite
          await SQLHelper.instance.insertDataUser(
            LoginOffline(
              id: '${response.data!.id}',
              nama: '${response.data!.nama}',
              namaCabang: '${response.data!.namaCabang}',
              nik: '${response.data!.nik}',
              noTelp: '${response.data!.noTelp}',
              levelUser: '${response.data!.levelUser}',
              foto: '${response.data!.foto}',
              lat: '${response.data!.lat}',
              long: '${response.data!.long}',
              kodeCabang: '${response.data!.kodeCabang}',
              level: '${response.data!.level}',
              username: '${response.data!.username}',
              password: '${response.data!.password}',
              areaCover: '${response.data!.areaCover}',
              visit: '${response.data!.visit}',
              cekStok: '${response.data!.cekStok}',
              idRegion: '${response.data!.idRegion}',
              leaveBalance: '${response.data!.leaveBalance}',
              createdAt: '${response.data!.createdAt}',
              parentId: '${response.data!.parentId}',
              namaParent: '${response.data!.namaParent}',
            ),
          );
          //end of insert statement
        }

        username.clear();
        password.clear();

        showToast("Selamat datang ${response.data!.nama}");
        // Pastikan controller AbsenController sudah didaftarkan
        // if (!Get.isRegistered<AbsenController>()) {
        //   Get.put(AbsenController());
        // }
      } else {
        showToast("User tidak ditemukan\nHarap periksa username dan password");
      }
    }
  }

  logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // await pref.setBool("is_login", false);
    // await pref.remove('userDataLogin');
    // await pref.remove('userLoc');
    await pref.clear();

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
    // Get.reset();
    Get.back();

    showToast("Logout Berhasil");
  }

  selectedMenu(index) {
    selected.value = index;
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
}
