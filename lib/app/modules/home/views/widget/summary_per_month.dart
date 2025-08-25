import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/summary_absen_model.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helper/const.dart';

class SummaryPerMonth extends StatelessWidget {
  SummaryPerMonth({super.key, this.userData});
  final Data? userData;
  final absenC = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
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
              InkWell(
                onTap: () => absenC.reloadSummary(userData!.id!),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColors.itemsBackground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          userData!.visit == "1"
              ? _buildVisit()
              : _buildAbsen(userData!, absenC),
        ],
      ),
    );
  }
}

Widget _buildLoadingOrValue(String? value) {
  if (value == null || value.isEmpty) {
    return SizedBox(
      width: 20,
      height: 20,
      child:
          Platform.isAndroid
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const CupertinoActivityIndicator(),
    );
  } else {
    return Text(
      value,
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    );
  }
}

_buildAbsen(Data userData, HomeController absenC) {
  return Obx(()=>FutureBuilder<SummaryAbsenModel>(
      future: absenC.futureSummary.value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(height: 8),
              Text(
                'Koneksi terputus. Mencoba ulang...',
                style: TextStyle(color: Colors.red),
              ),
              // Optional: Tombol manual reconnect jika mau
            ],
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.supervised_user_circle_rounded,
                                size: 28,
                                color: AppColors.contentColorBlue,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Present',
                                style: titleTextStyle.copyWith(
                                  fontSize: 15,
                                  color: AppColors.contentColorBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildLoadingOrValue(
                              snapshot.hasData ? data!.hadir.toString() : null,
                            ),
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
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 28,
                                color: green,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'On Time',
                                style: titleTextStyle.copyWith(
                                  fontSize: 15,
                                  color: green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildLoadingOrValue(
                              snapshot.hasData
                                  ? data!.tepatWaktu.toString()
                                  : null,
                            ),
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
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, size: 28, color: red),
                              const SizedBox(width: 5),
                              Text(
                                'Late',
                                style: titleTextStyle.copyWith(
                                  fontSize: 15,
                                  color: red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildLoadingOrValue(
                              snapshot.hasData ? data!.telat.toString() : null,
                            ),
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
                ),
              ),
            ],
          );
        } else {
          return const Text('Menunggu data...');
        }
      },
    ),
  );
}

_buildVisit() {}
