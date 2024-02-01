import 'package:absensi/app/helper/app_colors.dart';
import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
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
              const SizedBox(height: 35),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 355,
                    child: Column(
                      children: [
                        Text(
                          'LOGIN',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: mainColor),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.username,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
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
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                backgroundColor: AppColors.contentDefBtn,
                                fixedSize: Size(Get.mediaQuery.size.width, 50)),
                            onPressed: () => controller.login(),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(color: AppColors.mainTextColor1),
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
      ],
    ));
  }
}
