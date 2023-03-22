import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

void showToast(code, message) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor:
          code == "failed" ? Colors.redAccent[700] : Colors.greenAccent[700],
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT);
}

void dialogMsg(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    onConfirm: ()=> Get.back(),
  );
}

void dialogMsgAbsen(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    onConfirm: () {
      Get.back();
      Get.back();
      Get.back();
    },
  );
}
