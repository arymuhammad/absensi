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
      barrierDismissible: false
  );
}

void dialogMsgCncl(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    confirmTextColor: Colors.white,
    textCancel: 'Tutup',
    onCancel: () => Get.back(),
      barrierDismissible: false
  );
}

void dialogMsgAbsen(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    confirmTextColor: Colors.white,
    onConfirm: () {
      Get.back();
      Get.back();
      Get.back();
      Get.back();
    },
      barrierDismissible: false
  );
}

void loadingDialog(msg, String? msg2) {
  Get.defaultDialog(
      title: '',
      content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children:  [
         const CircularProgressIndicator(),
         const SizedBox(
            height:10,
          ),
          Text(msg),
          Text(msg2!),
        ],
      )),
      barrierDismissible: false);
}
