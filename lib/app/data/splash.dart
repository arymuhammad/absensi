import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import '../modules/home/views/bottom_navbar.dart';
import '../modules/login/controllers/login_controller.dart';
import '../modules/login/views/login_view.dart';
import 'add_controller.dart';
import 'helper/app_colors.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  final AdController adC = Get.find();
  final LoginController auth = Get.find();
  bool navigated = false;

  @override
  void initState() {
    super.initState();

    // Listener untuk kombinasi flag iklan dan splash session done
    // everAll([adC.splashSessionDone, adC.hasShownAd], (_) {
    //   if (adC.splashSessionDone.value && !navigated) {
    //     navigated = true;
    //     Get.offAll(
    //       () =>
    //           auth.isAuth.value
    //               ? BottomNavBar(listDataUser: auth.logUser.value)
    //               : const LoginView(),
    //     );
    //   }
    // });

    // Listener perubahan status login, jika sudah navigasi jangan ulang
    // ever(auth.isAuth, (isLoggedIn) {
    //   if (!navigated && adC.splashSessionDone.value) {
    //     navigated = true;
    //     Get.offAll(
    //       () =>
    //           isLoggedIn
    //               ? BottomNavBar(listDataUser: auth.logUser.value)
    //               : const LoginView(),
    //     );
    //   }
    // });

    // Fallback timeout agar navigasi terjadi jika iklan gagal load atau splash gagal finish
    Future.delayed(const Duration(seconds: 7), () {
      if (!navigated) {
        navigated = true;
        // Pastikan tanda bahwa splash sudah selesai supaya listener lain tidak memicu navigasi lagi
        // adC.splashSessionDone.value = true;
        Get.offAll(
          () =>
              auth.isAuth.value
                  ? BottomNavBar(listDataUser: auth.logUser.value)
                  : const LoginView(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: Obx(() {
       return  auth.isAuth.value
            ? BottomNavBar(listDataUser: auth.logUser.value)
            : const LoginView();
      }), // Tidak dipakai
      duration: 3000,
      imageSize: 70,
      imageSrc: "assets/image/logo2.png",
      textStyle: const TextStyle(
        fontSize: 40.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      pageRouteTransition: PageRouteTransition.SlideTransition,
      backgroundColor: AppColors.itemsBackground,
    );
  }
}
