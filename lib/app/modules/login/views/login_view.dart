import 'dart:ui';

import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('LOGIN'),
        //   centerTitle: true,
        // ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 65),
              Center(
                child: ClipOval(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child: Image.asset(
                      "assets/image/selfie.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: 55),
              TextField(
                controller: controller.username,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Username',
                    prefixIcon: Icon(TernavIcons.light.profile)),
              ),
              const SizedBox(
                height: 20,
              ),
              Obx(
                () => TextField(
                  controller: controller.password,
                  obscureText: controller.isPassHide.value,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      prefixIcon: Icon(TernavIcons.bold.lock),
                      suffixIcon: InkWell(
                          onTap: () {
                            controller.isPassHide.value =
                                !controller.isPassHide.value;
                          },
                          child: Icon(controller.isPassHide.value
                              ? Icons.visibility
                              : Icons.visibility_off))),
                  onSubmitted: (v) => controller.login(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(Get.mediaQuery.size.width, 50)),
                  onPressed: () => controller.login(),
                  child: const Text('LOGIN')),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                    onPressed: () {
                      Get.to(() => VerifikasiUpdatePassword(),
                          transition: Transition.cupertino);
                    },
                    child: const Text('Lupas Password?')),
              ),
              Center(
                child: RichText(
                    text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: const TextStyle(
                            color: Colors.black, fontFamily: 'Nunito'),
                        children: [
                      TextSpan(
                          text: 'klik disini',
                          style:
                              TextStyle(color: mainColor, fontFamily: 'Nunito'),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Aksi yang dijalankan saat TextButton diklik
                              Get.toNamed('/add-pegawai');
                            })
                    ])),
              )
            ],
          ),
        ));
  }
}
