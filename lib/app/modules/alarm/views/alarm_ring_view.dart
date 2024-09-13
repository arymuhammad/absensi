// import 'package:absensi/app/data/helper/const.dart';
// import 'package:alarm/alarm.dart';
// import 'package:alarm/model/alarm_settings.dart';
// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:slider_button/slider_button.dart';

// import '../../login/controllers/login_controller.dart';

// class AlarmRingView extends GetView {
//   AlarmRingView({super.key, this.alarmSettings});
//   final AlarmSettings? alarmSettings;
//   final nav = Get.put(LoginController());
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       // floatingActionButton: FloatingActionButton(onPressed: () async{
//       //   await Alarm.stop(alarmSettings!.id);
//       //   nav.selectedMenu(0);
//       // }, backgroundColor: red, child: const Text('STOP'),),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       children: [
//         Container(
//           decoration:
//           const BoxDecoration(image: DecorationImage(image: AssetImage('assets/image/bgalarm.jpg'), fit: BoxFit.fill))

//         ),
//       Center(
//         child: Text(
//           alarmSettings!.notificationBody,
//           style: const TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//       Positioned(
//           left:0,
//           top: Get.mediaQuery.size.height/1.2,
//           right: 0,
//           bottom:0 ,
//           child:
//     Center(child: SliderButton(
//     action: () async{
//     ///Do something here OnSlide
//       await Alarm.stop(alarmSettings!.id);
//       Get.back();Get.back();
//       nav.selectedMenu(0);
//     return true;
//     },
//     label: const Text(
//     "Slide to Turn off Alarm",
//     style: TextStyle(
//     color: Color(0xff4a4a4a), fontWeight: FontWeight.w500, fontSize: 17),
//     ),
//     icon: Icon(Icons.power_settings_new, color: red,))))
//       //     ElevatedButton(onPressed: () async{ await Alarm.stop(alarmSettings!.id);
//       // nav.selectedMenu(0); Get.back(); }, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), fixedSize: const Size(10, 10)), child: const Text('STOP'),))
//     ],
//     );
//   }
// }
