import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/helper/app_colors.dart';
import 'root_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => const RootView()); // 🔥 pindah ke root
    });

    return Scaffold(
      backgroundColor: AppColors.itemsBackground,
      body:  Center(
        child: Image.asset('assets/image/logo2.png')
        ),
      
    );
  }
}