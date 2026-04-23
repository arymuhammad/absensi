import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OvertimeController extends GetxController {
  late TextEditingController date1, date2, clockIn, clockOut, remark;

  void onInit() {
    super.onInit();
    date1 = TextEditingController();
    date2 = TextEditingController();
    clockIn = TextEditingController();
    clockOut = TextEditingController();
    remark = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    date1.clear();
    date2.clear();
    clockIn.clear();
    clockOut.clear();
    remark.clear();
    super.onClose();
  }
}
