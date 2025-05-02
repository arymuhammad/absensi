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

class LoginController extends GetxController 
    with GetTickerProviderStateMixin{
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
        username.text, md5.convert(utf8.encode(password.text)).toString());

    //checking data
    if (dataOffline.isNotEmpty) {
          FotoProfil foto =
          await ServiceApi().getFotoProfil({'id': dataOffline.first.id!});

      await pref.setString(
          'userDataLogin',
          jsonEncode(Data(
              id: dataOffline[0].id,
              nama: dataOffline[0].nama,
              username: dataOffline[0].username,
              password: dataOffline[0].password,
              kodeCabang: dataOffline[0].kodeCabang,
              namaCabang: dataOffline[0].namaCabang,
              lat: dataOffline[0].lat,
              long: dataOffline[0].long,
              foto: foto.foto! != "" ? foto.foto! : dataOffline[0].foto,
              noTelp: dataOffline[0].noTelp,
              level: dataOffline[0].level,
              levelUser: dataOffline[0].levelUser,
              areaCover: dataOffline[0].areaCover,
              cekStok: dataOffline[0].cekStok,
              visit: dataOffline[0].visit)));

      var tempUser = pref.getString('userDataLogin');
      // print('user data login $tempUser');
      // final user = userDataLogin != "" ? Data.fromJson(jsonDecode(userDataLogin!)) : null;
      logUser.value = Data.fromJson(jsonDecode(tempUser!));

      // (tempUser != "" ? Data.fromJson(jsonDecode(tempUser!)) : null)!;
      isAuth.value = await pref.setBool("is_login", true);
      username.clear();
      password.clear();

      showToast("Selamat datang ${dataOffline[0].nama}");
    } else {
      var response = await ServiceApi().loginUser(data);

      // dataUser.value = response;
      if (response.success == true) {
        

        await pref.setString(
            'userDataLogin',
            jsonEncode(Data(
                id: response.data!.id,
                nama: response.data!.nama,
                username: response.data!.username,
                password: response.data!.password,
                kodeCabang: response.data!.kodeCabang,
                namaCabang: response.data!.namaCabang,
                lat: response.data!.lat,
                long: response.data!.long,
                foto: response.data!.foto,
                noTelp: response.data!.noTelp,
                level: response.data!.level,
                levelUser: response.data!.levelUser,
                areaCover: response.data!.areaCover,
                cekStok: response.data!.cekStok,
                visit: response.data!.visit)));

        var tempUser = pref.getString('userDataLogin');
        logUser.value = Data.fromJson(jsonDecode(tempUser!));
        isAuth.value = await pref.setBool("is_login", true);

        await SQLHelper.instance
            .getDataUser(response.data!.id!)
            .then((data) => userSqlite.value = data);

        if (userSqlite.isEmpty) {
          //insert user data to sqlite
          await SQLHelper.instance.insertDataUser(LoginOffline(
              id: '${response.data!.id}',
              nama: '${response.data!.nama}',
              namaCabang: '${response.data!.namaCabang}',
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
              cekStok: '${response.data!.cekStok}'));
          //end of insert statement
        }

        username.clear();
        password.clear();

        showToast("Selamat datang ${response.data!.nama}");
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
    Get.delete<AbsenController>(force: true);
    Get.back();

    showToast("Logout Berhasil");
  }

  selectedMenu(index) {
    selected.value = index;
  }
}
