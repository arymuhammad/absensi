import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/home/views/bottom_navbar.dart';
import 'app/modules/login/controllers/login_controller.dart';
import 'app/modules/login/views/login_view.dart';
import 'splash.dart';

class RootView extends GetView<LoginController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isReady.value) {
        return const SplashView(); // ⏳ loading dulu
      }

      if (controller.isAuth.value) {
        return BottomNavBar();
      } else {
        return const LoginView();
      }
    });
  }
}
