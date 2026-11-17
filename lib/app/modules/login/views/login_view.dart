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
import 'package:icons_flutter/icons_flutter.dart';
import '../../shared/container_main_color.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // GLOBAL BACKGROUND
          Image.asset(
            isDark ? 'assets/image/bg-ctn-drk.png' : 'assets/image/bg-ctn.png',
            fit: BoxFit.cover,
          ),

          // BLUE HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Image.asset(
              isDark ? 'assets/image/bg-hd-drk.png' : 'assets/image/bg-hd.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Obx(
              () => ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/image/icon.png'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'WELCOME BACK',
                            style: titleTextStyle.copyWith(
                              fontSize: 22,
                              color: AppColors.contentColorWhite,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Login to your account',
                            style: subtitleTextStyle.copyWith(
                              fontSize: 16,
                              color: AppColors.contentColorWhite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 60,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            child: TextField(
                              controller: controller.username,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    isDark
                                        ? const Color(
                                          0xFF1E293B,
                                        ).withOpacity(0.78)
                                        : Colors.white.withOpacity(0.82),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                labelText: 'Username',
                                prefixIcon: const Icon(
                                  FontAwesome.user_circle_o,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 60,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            child: TextField(
                              controller: controller.password,
                              obscureText: controller.isPassHide.value,

                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    isDark
                                        ? const Color(
                                          0xFF1E293B,
                                        ).withOpacity(0.78)
                                        : Colors.white.withOpacity(0.82),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                labelText: 'Password',
                                prefixIcon: const Icon(
                                  Typicons.key_outline,
                                  size: 22,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    controller.isPassHide.value =
                                        !controller.isPassHide.value;
                                  },
                                  child: Icon(
                                    controller.isPassHide.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
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
                                Get.to(
                                  () => VerifikasiUpdatePassword(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.gpp_bad, color: red),
                                  Text(
                                    'Forgot Password?',
                                    style: titleTextStyle.copyWith(
                                      color: isDark ? Colors.white : mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.mainGradient(
                                  context: context,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  fixedSize: const Size(100, 30),
                                ),
                                onPressed: () {
                                  if (controller.username.text != "" &&
                                      controller.password.text != "") {
                                    controller.login();
                                  } else {
                                    showToast(
                                      'Username dan Password tidak boleh kosong',
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('LOGIN', style: titleTextStyle),
                                    const Icon(Typicons.right_small),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 75),
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Don`t have an account?\n',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.grey,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Register here',
                                  style: TextStyle(
                                    color: mainColor,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          // Aksi yang dijalankan saat TextButton diklik
                                          Get.toNamed('/add-pegawai');
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                loadingDialog(
                                  "Menghapus data...",
                                  "Mohon menunggu",
                                  isDark,
                                );
                                await SQLHelper.instance.truncateUser();
                                Get.back();
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.cancel_sharp, color: red),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Hapus data user',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : mainColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
