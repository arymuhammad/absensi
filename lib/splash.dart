import 'package:flutter/material.dart';

import 'app/data/helper/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.itemsBackground,
      body: Center(
        child: Image.asset(
          'assets/image/logo2.png',
        ),
      ),
    );
  }
}