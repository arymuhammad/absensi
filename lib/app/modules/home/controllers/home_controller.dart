import 'dart:math';

import 'package:absensi/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var currentPage = 0.obs;
  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    tabController.animation!.addListener(
      () {
        final value = tabController.animation!.value.round();
        if (value != currentPage.value) {
          changePage(value);
          // print(value);
        }
      },
    );
    super.onInit();
  }

  void changePage(int newPage) {
    currentPage.value = newPage;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
