import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/report_sales/controllers/report_sales_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

final auth = Get.put(LoginController());
final salesCtr = Get.put(ReportSalesController());

defaultSnackBar(context, message) {
  var snackBar = SnackBar(
    content: Text(message),
    // backgroundColor:
    //     status == "E" ? Colors.redAccent[700] : Colors.greenAccent[700],
    duration: const Duration(milliseconds: 2000),
  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

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
        auth.selectedMenu(0);
        Future.delayed(const Duration(milliseconds: 300));
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
        auth.selectedMenu(0);
        Future.delayed(const Duration(milliseconds: 300));
        Get.back();
        // Get.back();
        // Get.back();
        // Get.back();
      },
      barrierDismissible: false);
}

void succesDialog(context, pageAbsen, desc) {
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
      if (pageAbsen == "Y") {
        auth.selectedMenu(0);
        Future.delayed(const Duration(milliseconds: 300));
        Get.back();
      } else {
        Get.back();
        Get.back();
      }
    },
    btnOkIcon: Icons.check_circle,
    onDismissCallback: (type) {
      debugPrint('Dialog Dissmiss from callback $type');
    },
  ).show();
}

 failedDialog(context, title, desc) {
  AwesomeDialog(
    context: context,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.error,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    title: title,
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

loadingDialog(msg, String? msg2) {
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

loadingWithIcon() {
  SmartDialog.showLoading(
    backDismiss: false,
    animationType: SmartAnimationType.scale,
    builder: (_) => Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/image/selfie.png',
        height: 50,
        width: 50,
      ),
      // Lottie.asset('assets/image/loader.json', repeat: true)
      RotationTransition(
        alignment: Alignment.center,
        turns: salesCtr.ctrAnimated,
        child: Image.asset(
          'assets/image/circle_loading.png',
          height: 80,
          width: 80,
        ),
      ),
    ]),
  );
}
