import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              // height: Get.mediaQuery.size.height / 2,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/image/bg.png'),
                      fit: BoxFit.fill)),
            ),
            // Positioned(
            //     left: 12,
            //     top: 50,
            //     right: 0,
            //     bottom: 0,
            //     child: Text(
            //       'WELCOME\nBACK',
            //       style: titleTextStyle.copyWith(
            //         fontSize: 45,
            //         color: Colors.black54,
            //       ),
            //     )),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Obx(
                () => ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    // const SizedBox(
                    //   width: 450,
                    //   height: 120,
                    //   // child: Rive(artboard: controller.artboard.value),
                    // ),
                    const SizedBox(height: 5),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(12.0, 100.0, 12.0, 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage('assets/image/selfie.png'),
                            )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              'WELCOME BACK',
                              style: titleTextStyle.copyWith(
                                fontSize: 22,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Login to your account',
                              style: subtitleTextStyle.copyWith(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 60,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 10,
                              child: TextField(
                                // onTap: controller.lookAround,
                                // onChanged: ((value) =>
                                //     controller.moveEyes(value)),
                                controller: controller.username,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'Username',
                                    prefixIcon: const Icon(
                                      Iconsax.user_octagon_bold,
                                      size: 35,
                                    )),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: 60,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 10,
                              child: TextField(
                                controller: controller.password,
                                obscureText: controller.isPassHide.value,
                                // onTap: controller.handsUpOnEyes,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Iconsax.key_bold),
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          controller.isPassHide.value =
                                              !controller.isPassHide.value;
                                        },
                                        child: Icon(controller.isPassHide.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined))),
                                onSubmitted: (v) => controller.login(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Get.to(() => VerifikasiUpdatePassword(),
                                        transition: Transition.cupertino);
                                  },
                                  child: Text(
                                    'Lupa Password?',
                                    style: titleTextStyle,
                                  )),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      backgroundColor: AppColors.contentDefBtn,
                                      fixedSize: const Size(130, 40)),
                                  onPressed: () {
                                    // controller.isChecking?.change(false);
                                    // controller.isHandsUp?.change(false);
                                    if (controller.username.text != "" &&
                                        controller.password.text != "") {
                                      // throw Exception();
                                      controller.login();
                                    } else {
                                      showToast(
                                          'Username dan Password tidak boleh kosong');
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'LOGIN',
                                        style: titleTextStyle,
                                      ),
                                      const Icon(Iconsax.arrow_right_bold)
                                    ],
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 75,
                          ),
                          Center(
                            child: RichText(
                                text: TextSpan(
                                    text: 'Belum punya akun? ',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold),
                                    children: [
                                  TextSpan(
                                      text: 'klik disini',
                                      style: TextStyle(
                                          color: mainColor,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Aksi yang dijalankan saat TextButton diklik
                                          Get.toNamed('/add-pegawai');
                                        })
                                ])),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  loadingDialog(
                                      "Menghapus data...", "Mohon menunggu");
                                  await SQLHelper.instance.truncateUser();
                                  Get.back();
                                  // var databasesPath = await getDatabasesPath();
                                  // // var dbPath = join(databasesPath, 'penjualan.db');

                                  // var status = await Permission
                                  //     .manageExternalStorage.status;
                                  // if (!status.isGranted) {
                                  //   await Permission.manageExternalStorage
                                  //       .request();
                                  // }

                                  // var status1 = await Permission.storage.status;
                                  // if (!status1.isGranted) {
                                  //   await Permission.storage.request();
                                  // }

                                  // try {
                                  //   File savedDb = File(
                                  //       "/storage/emulated/0/URBANCO SPOT/absensi.db");

                                  //   await savedDb
                                  //       .copy('$databasesPath/absensi.db');
                                  // } catch (e) {
                                  //   showToast(
                                  //       e.toString());
                                  // }

                                  // showToast('Successfully Restored Database');
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cancel_sharp,
                                      color: red,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Hapus data user',
                                      style: TextStyle(
                                          color: mainColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
