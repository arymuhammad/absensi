import 'package:flutter/material.dart';

import 'package:get/get.dart';

class SplashView extends GetView {
  const SplashView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.white,
            // appBar: AppBar(
            //   title: const Text('SplashView'),
            //   centerTitle: true,
            // ),
            body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: Get.width * 0.5,
                width: Get.width * 0.5,
                child: Image.asset('assets/image/logo_splash.webp')),
            const SizedBox(height:8),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        )),));
  }
}
