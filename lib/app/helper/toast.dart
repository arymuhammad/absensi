import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

void showToast(message) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor:
         Colors.grey[700],
      textColor: Colors.grey[200],
      toastLength: Toast.LENGTH_SHORT);
}

void dialogMsg(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    confirmTextColor: Colors.white,
    textConfirm: 'Tutup',
    onConfirm: () => Get.back(),
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

void loadingDialog(msg) {
  Get.defaultDialog(
      title: '',
      content: Center(
          child: Column(
        children:  [
         const CircularProgressIndicator(),
         const SizedBox(
            height: 5,
          ),
          Text(msg)
        ],
      )));
}
