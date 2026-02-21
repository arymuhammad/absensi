import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'time_service.dart';

class GreetingHelper {
  static Future<String> getGreeting() async {
    final serverTime = await getServerTimeLocal();
    if (serverTime == null) return 'Halo, ';

    final hour = serverTime.hour;

    if (hour >= 4 && hour < 11) {
      return 'Selamat pagi, ';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang, ';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore, ';
    } else {
      return 'Selamat malam, ';
    }
  }

  static Future<Widget> getIcon() async {
    final serverTime = await getServerTimeLocal();
     if (serverTime == null) return Lottie.asset('assets/animation/pagi.json');

    final hour = serverTime.hour;

    if (hour >= 5 && hour < 11) {
      return Lottie.asset('assets/animation/pagi.json');
    } else if (hour >= 11 && hour < 15) {
      return Lottie.asset('assets/animation/siang.json');
    } else if (hour >= 15 && hour < 18) {
      return Lottie.asset('assets/animation/sore.json');
    } else {
      return Lottie.asset('assets/animation/malam.json');
    }
  }
}
