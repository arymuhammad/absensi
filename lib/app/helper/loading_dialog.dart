import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

final auth = Get.put(LoginController());

void showToast(message) {
  Fluttertoast.showToast(
      msg: message,
      // backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webBgColor: ' #979B999',
      timeInSecForIosWeb: 2,
      webPosition: 'center');
}

dialogMsg(code, msg) {
  Get.defaultDialog(
      title: code,
      middleText: msg,
      confirmTextColor: Colors.white,
      textConfirm: 'Tutup',
      onConfirm: () => Get.back(),
      barrierDismissible: false);
}

void dialogMsgScsUpd(code, msg) {
  Get.defaultDialog(
      title: code,
      middleText: msg,
      confirmTextColor: Colors.white,
      textConfirm: 'Tutup',
      onConfirm: () {
        Get.back();
        Get.back();
      },
      barrierDismissible: false);
}

void dialogMsgCncl(code, msg) {
  Get.defaultDialog(
      title: code,
      middleText: msg,
      confirmTextColor: Colors.white,
      textCancel: 'Tutup',
      onCancel: () {
        Get.back();
        Get.back();
      },
      barrierDismissible: false);
}

void dialogMsgAbsen(code, msg) {
  Get.defaultDialog(
      title: code,
      middleText: msg,
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Get.to(() => HomeView());
        Get.back();
        Get.back();
        Get.back();
        Get.back();
      },
      barrierDismissible: false);
}

void succesDialog(context, desc) {
  AwesomeDialog(
    context: context,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.success,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    title: 'Succes',
    desc: desc,
    btnOkOnPress: () {
      Get.back();
      Get.back();
    },
    btnOkIcon: Icons.check_circle,
    onDismissCallback: (type) {
      debugPrint('Dialog Dissmiss from callback $type');
    },
  ).show();
}

void failedDialog(context, desc) {
  AwesomeDialog(
    context: context,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.error,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    title: 'Error',
    desc: desc,
    btnOkOnPress: () {},
    btnOkIcon: Icons.cancel,
    btnOkText: 'Tutup',
    btnOkColor: Colors.redAccent[700],
    onDismissCallback: (type) {
      debugPrint('Dialog Dissmiss from callback $type');
    },
  ).show();
}

void promptDialog(context, desc) {
  AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          // onDismissCallback: (type) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text('Dismissed by $type'),
          //     ),
          //   );
          // },
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'INFO',
          desc: desc,
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            auth.logout();
          },
          btnCancelColor: Colors.redAccent[700],
          btnCancelIcon: Icons.cancel,
          btnOkColor: Colors.blueAccent[700],
          btnOkIcon: Icons.check_circle_rounded)
      .show();
}

void loadingDialog(msg, String? msg2) {
  Get.defaultDialog(
      title: '',
      onWillPop: () async {
        return false;
      },
      content: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 10,
          ),
          Text(msg),
          Text(msg2!),
        ],
      )),
      barrierDismissible: false);
}
