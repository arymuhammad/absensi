import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/summary_absen_model.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helper/const.dart';
import 'present_shimmer.dart';

class SummaryPerMonth extends StatelessWidget {
  SummaryPerMonth({super.key});
  final auth = Get.find<LoginController>();
  final homeC = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    final userData = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Summary for this Month',
                style: titleTextStyle.copyWith(fontSize: 15),
              ),
              // InkWell(
              //   onTap: () => homeC.reloadSummary(userData!.id!),
              //   child: Container(
              //     height: 30,
              //     width: 30,
              //     decoration: BoxDecoration(
              //       color: AppColors.itemsBackground,
              //       borderRadius: BorderRadius.circular(50),
              //     ),
              //     child: const Icon(Icons.refresh_rounded, color: Colors.white),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 5),
          userData.visit == "1"
              ? _buildVisit()
              : _buildAbsen(userData, homeC, isDark),
        ],
      ),
    );
  }
}

// Widget _buildLoadingOrValue(String? value) {
//   if (value == null || value.isEmpty) {
//     return SizedBox(
//       width: 20,
//       height: 20,
//       child:
//           Platform.isAndroid
//               ? const CircularProgressIndicator(strokeWidth: 2)
//               : const CupertinoActivityIndicator(),
//     );
//   } else {
//     return Text(
//       value,
//       style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//     );
//   }
// }

_buildAbsen(Data userData, HomeController homeC, bool isDark) {
   return Obx(() => genSummaryAbsen(homeC, isDark));
}

Widget genSummaryAbsen(HomeController homeC, bool isDark) {
  if (homeC.isLoadingSumm.value) {
    return Row(
      children: [presentShimmer(), presentShimmer(), presentShimmer()],
    );
  }

  if (homeC.isErrorSumm.value) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red),
        SizedBox(height: 8),
        Text(
          'Koneksi terputus. Mencoba ulang...',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  // if (homeC.summPerMonthCount.value == 0) {
  //   return const Text('Menunggu data...');
  // }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: _buildBox(
          title: 'Present',
          icon: Icons.supervised_user_circle_rounded,
          color: AppColors.contentColorBlue,
          value: homeC.hadir.value.toString(),
          isLeft: true,
          isDark: isDark
        ),
      ),
      Expanded(
        child: _buildBox(
          title: 'On Time',
          icon: Icons.check_circle_rounded,
          color: green!,
          value: homeC.tepatWaktu.value.toString(),
          isDark: isDark
        ),
      ),
      Expanded(
        child: _buildBox(
          title: 'Late',
          icon: Icons.warning_rounded,
          color: red!,
          value: homeC.telat.value.toString(),
          isRight: true,
          isDark: isDark
        ),
      ),
    ],
  );
}

Widget _buildBox({
  required String title,
  required IconData icon,
  required Color color,
  required String value,
  bool isLeft = false,
  bool isRight = false,
  required bool isDark,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: isLeft ? const Radius.circular(5) : Radius.zero,
        bottomLeft: isLeft ? const Radius.circular(5) : Radius.zero,
        topRight: isRight ? const Radius.circular(5) : Radius.zero,
        bottomRight: isRight ? const Radius.circular(5) : Radius.zero,
      ),
      color: isDark ? Get.theme.cardColor : Colors.white,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 5),
              Text(
                title,
                style: titleTextStyle.copyWith(fontSize: 15, color: color,),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(width: 5),
              const Text(
                'Day',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

_buildVisit() {}
