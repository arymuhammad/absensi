import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rive/rive.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('LOGIN'),
        //   centerTitle: true,
        // ),
        body: Stack(
      children: [
        Container(
          height: Get.mediaQuery.size.height / 2,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/image/bgapp.jpg'),
                  fit: BoxFit.fill)),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Obx(
            () => ListView(
              children: [
                SizedBox(
                  width: 450,
                  height: 220,
                  child: Rive(artboard: controller.artboard.value),
                ),
                const SizedBox(height: 5),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 385,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: mainColor),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            onTap: controller.lookAround,
                            onChanged: ((value) => controller.moveEyes(value)),
                            controller: controller.username,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Username',
                                prefixIcon: const Icon(FontAwesome.user_solid)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: controller.password,
                            obscureText: controller.isPassHide.value,
                            onTap: controller.handsUpOnEyes,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Password',
                                prefixIcon: const Icon(FontAwesome.lock_solid),
                                suffixIcon: InkWell(
                                    onTap: () {
                                      controller.isPassHide.value =
                                          !controller.isPassHide.value;
                                    },
                                    child: Icon(controller.isPassHide.value
                                        ? Icons.visibility_off
                                        : Icons.visibility))),
                            onSubmitted: (v) => controller.login(),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  backgroundColor: AppColors.contentDefBtn,
                                  fixedSize: const Size(130, 50)),
                              onPressed: () {
                                controller.isChecking?.change(false);
                                controller.isHandsUp?.change(false);
                                if (controller.username.text != "" &&
                                    controller.password.text != "") {
                                  controller.login();
                                  controller.successTrigger?.fire();
                                } else {
                                  controller.failTrigger?.fire();
                                }
                              },
                              child: const Text(
                                'LOGIN',
                                style:
                                    TextStyle(color: AppColors.mainTextColor1),
                              )),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  Get.to(() => VerifikasiUpdatePassword(),
                                      transition: Transition.cupertino);
                                },
                                child: Text(
                                  'Lupas Password?',
                                  style: TextStyle(color: mainColor),
                                )),
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
                          )
                        ],
                      ),
                    ),
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
