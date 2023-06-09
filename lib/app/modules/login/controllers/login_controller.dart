import 'package:absensi/app/helper/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Repo/service_api.dart';
import '../../../controllers/absen_controller.dart';
import '../../../model/login_model.dart';

class LoginController extends GetxController {
  late TextEditingController email;
  late TextEditingController username;
  late TextEditingController password;

  // FirebaseAuth auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  var dataUser = Login().obs;
  var isAuth = false.obs;
  var selected = 0.obs;
  var logUser = [].obs;
  var isPassHide = true.obs;
  // var currUser =[];
  // final absen = Get.put(AbsenController());

  @override
  void onInit() async {
    // await GetStorage.init();
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
    loadingDialog('Loading...', "");
    var response = await ServiceApi().loginUser(data);
    Get.back();
    dataUser.value = response;
    if (dataUser.value.success! == true) {
      // Get.offAllNamed(Routes.HOME);

      // final box = GetStorage();
      // box.write('login', true);
      // print(box.read('login'));
      // isAuth.value = box.read('login');
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
        '${dataUser.value.data!.username}'
      ]);
      //  pref.getStringList('userDataLogin');
      List<String>? tempUser = pref.getStringList('userDataLogin');
      logUser.value = tempUser!;
      isAuth.value = await pref.setBool("is_login", true);
      // print(isAuth.value);
      // update();

      // currUser.add(pref.getStringList('userDataLogin'));
      // print('${dataUser.value.data!}');
      // print('login');
      // print(pref.getStringList('userDataLogin'));
      username.clear();
      password.clear();
      showToast("Anda Berhasil Login");
      Get.back();
    } else {
      showToast("User tidak ditemukan\nHarap periksa username dan password");
    }
  }

  logout() async {
    // // await GetStorage.init();
    // final box = GetStorage();
    // box.erase();
    // isAuth.value = false;
    // print(isAuth.value);
    // print(box.read('login'));
    SharedPreferences pref = await SharedPreferences.getInstance();
    // await pref.remove("kode_event");
    await pref.setBool("is_login", false);
    await pref.remove('userDataLogin');
    // print(pref.getStringList('userDataLogin'));
    logUser.clear();
    // absen.dataAllAbsen.clear();
    // absen.dataLimitAbsen.clear();

    isAuth.value = false;
    selected.value = 0;
    Get.delete<AbsenController>(force: true);
    Get.back();
    // Get.offAllNamed(Routes.LOGIN);
    showToast("Logout Berhasil");
  }
}
