import 'dart:convert';

import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/login_offline_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../../controllers/absen_controller.dart';
import '../../../services/service_api.dart';
import '../../../data/model/login_model.dart';

class LoginController extends GetxController {
  late TextEditingController email, username, password;
  var isLoading = false.obs;
  var dataUser = Login().obs;
  var userSqlite = <LoginOffline>[].obs;
  var isAuth = false.obs;
  var selected = 0.obs;
  var logUser = [].obs;
  var isPassHide = true.obs;

  var animationLink = 'assets/animation/animated_login.riv';
  SMITrigger? failTrigger, successTrigger;
  SMIBool? isHandsUp, isChecking;
  SMINumber? lookNum;
  StateMachineController? stateMachineController;
  var artboard = Artboard().obs;

  @override
  void onInit() async {
    rootBundle.load(animationLink).then((value) {
      final file = RiveFile.import(value);
      final art = file.mainArtboard;
      stateMachineController =
          StateMachineController.fromArtboard(art, "Login Machine");

      if (stateMachineController != null) {
        art.addController(stateMachineController!);

        for (var element in stateMachineController!.inputs) {
          if (element.name == "isChecking") {
            isChecking = element as SMIBool;
          } else if (element.name == "isHandsUp") {
            isHandsUp = element as SMIBool;
          } else if (element.name == "trigSuccess") {
            successTrigger = element as SMITrigger;
          } else if (element.name == "trigFail") {
            failTrigger = element as SMITrigger;
          } else if (element.name == "numLook") {
            lookNum = element as SMINumber;
          }
        }
      }
      artboard.value = art;
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

  void lookAround() {
    isChecking?.change(true);
    isHandsUp?.change(false);
    lookNum?.change(0);
  }

  void moveEyes(value) {
    lookNum?.change(value.length.toDouble());
  }

  void handsUpOnEyes() {
    isHandsUp?.change(true);
    isChecking?.change(false);
  }

  login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = {"username": username.text, "password": password.text};
    //get data from local storage
    var dataOffline = await SQLHelper.instance.loginUserOffline(
        username.text, md5.convert(utf8.encode(password.text)).toString());
    //checking data
    if (dataOffline.isNotEmpty) {

      await pref.setStringList('userDataLogin', <String>[
        '${dataOffline[0].id}',
        '${dataOffline[0].nama}',
        '${dataOffline[0].namaCabang}',
        '${dataOffline[0].noTelp}',
        '${dataOffline[0].levelUser}',
        '${dataOffline[0].foto}',
        '${dataOffline[0].lat}',
        '${dataOffline[0].long}',
        '${dataOffline[0].kodeCabang}',
        '${dataOffline[0].level}',
        '${dataOffline[0].username}',
        '${dataOffline[0].areaCover}',
        '${dataOffline[0].visit}',
        '${dataOffline[0].cekStok}',
        '${dataOffline[0].password}'
      ]);
      List<String>? tempUser = pref.getStringList('userDataLogin');
      logUser.value = tempUser!;
      isAuth.value = await pref.setBool("is_login", true);
      username.clear();
      password.clear();
      showToast("Selamat datang kembali ${dataOffline[0].nama}");
    } else {

      var response = await ServiceApi().loginUser(data);

      dataUser.value = response;
      if (dataUser.value.success! == true) {
        successTrigger?.fire();
        await pref.setStringList('userDataLogin', <String>[
          '${dataUser.value.data!.id}',
          '${dataUser.value.data!.nama}',
          '${dataUser.value.data!.namaCabang}',
          '${dataUser.value.data!.noTelp}',
          '${dataUser.value.data!.levelUser}',
          '${dataUser.value.data!.foto}',
          '${dataUser.value.data!.lat}',
          '${dataUser.value.data!.long}',
          '${dataUser.value.data!.kodeCabang}',
          '${dataUser.value.data!.level}',
          '${dataUser.value.data!.username}',
          '${dataUser.value.data!.areaCover}',
          '${dataUser.value.data!.visit}',
          '${dataUser.value.data!.cekStok}',
          '${dataUser.value.data!.password}'
        ]);

        List<String>? tempUser = pref.getStringList('userDataLogin');
        logUser.value = tempUser!;
        isAuth.value = await pref.setBool("is_login", true);

        await SQLHelper.instance
            .getDataUser(dataUser.value.data!.id!)
            .then((data) => userSqlite.value = data);

        if (userSqlite.isEmpty) {
          //insert user data to sqlite
          await SQLHelper.instance.insertDataUser(LoginOffline(
              id: '${dataUser.value.data!.id}',
              nama: '${dataUser.value.data!.nama}',
              namaCabang: '${dataUser.value.data!.namaCabang}',
              noTelp: '${dataUser.value.data!.noTelp}',
              levelUser: '${dataUser.value.data!.levelUser}',
              foto: '${dataUser.value.data!.foto}',
              lat: '${dataUser.value.data!.lat}',
              long: '${dataUser.value.data!.long}',
              kodeCabang: '${dataUser.value.data!.kodeCabang}',
              level: '${dataUser.value.data!.level}',
              username: '${dataUser.value.data!.username}',
              password: '${dataUser.value.data!.password}',
              areaCover: '${dataUser.value.data!.areaCover}',
              visit: '${dataUser.value.data!.visit}',
              cekStok: '${dataUser.value.data!.cekStok}'));
          //end of insert statement
        }

        username.clear();
        password.clear();
        showToast("Selamat datang kembali ${dataUser.value.data!.nama}");
        Get.back();
      } else {
        failTrigger?.fire();
        showToast("User tidak ditemukan\nHarap periksa username dan password");
      }
    }
  }

  logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.setBool("is_login", false);
    await pref.remove('userDataLogin');
    await pref.remove('userLoc');

    logUser.clear();

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
