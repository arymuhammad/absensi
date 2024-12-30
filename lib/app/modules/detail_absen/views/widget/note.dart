import 'package:flutter/material.dart';
import 'package:get/get.dart';

TextEditingController nc = TextEditingController();
note() {
  // log(tglMasuk);
  Get.defaultDialog(
    barrierDismissible: false,
    radius: 5,
    title: 'NOTE',
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: nc,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    ),
    onConfirm: () {
      Get.back();
    },
    textConfirm: 'Simpan',
    confirmTextColor: Colors.white,
  );
}
