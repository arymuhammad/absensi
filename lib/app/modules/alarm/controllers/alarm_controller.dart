// import 'dart:async';
// import 'dart:io';
// import 'dart:math';

// import 'package:alarm/alarm.dart';
// import 'package:alarm/model/alarm_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../views/alarm_ring_view.dart';
// import '../views/edit_alarm_view.dart';

// class AlarmController extends GetxController {
  
//   var alarms = <AlarmSettings>[].obs;
//   static StreamSubscription<AlarmSettings>? subscription;
//   var loading = false.obs;
//   var creating = true.obs;
//   var initialDateTime = DateTime.now().obs;
//   var selectedDateTime = DateTime.now().obs;
//   var loopAudio = false.obs;
//   var vibrate = false.obs;
//   var volumeToggle = false.obs;
//   var volume = 1.0.obs;
//   var assetAudio = "".obs;
//   var labelAlarm = TextEditingController();


//   @override
//   void onInit() {
//     super.onInit();
//     if (Alarm.android) {
//       checkAndroidNotificationPermission();
//       checkAndroidScheduleExactAlarmPermission();
//     }
//     loadAlarms();

//     subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);


//     // creating.value = alarms ==null;
//     // creating.value = false;
//     // if (creating.value) {
//     //   selectedDateTime.value = DateTime.now().add(const Duration(minutes: 1));
//     //   selectedDateTime.value = selectedDateTime.value.copyWith(second: 0, millisecond: 0);
//     //   loopAudio.value = true;
//     //   vibrate.value = true;
//     //   volume.value = 0.8;
//     //   assetAudio.value = 'assets/sound/oppo.mp3';
//     // }
//     // else {
//     //   alarmC.selectedDateTime.value = alarmSettings!.dateTime;
//     //   alarmC.loopAudio.value = alarmSettings!.loopAudio;
//     //   alarmC.vibrate.value = alarmSettings!.vibrate;
//     //   alarmC.volume.value = alarmSettings!.volume!;
//     //   alarmC.assetAudio.value = alarmSettings!.assetAudioPath;
//     // }

//   }



//   @override
//   void onClose() {
//     // subscription?.cancel();
//     super.onClose();
//   }

//   loadAlarms() {
//       // var tempAlarm =  await SQLHelper.instance.getAlarm();
//       // if(tempAlarm.isNotEmpty){
//       //   alarms = tempAlarm.cast<AlarmSettings>();
//       // }else{
//         alarms.value = Alarm.getAlarms();
//         alarms.sort((a, b) =>  a.dateTime.isBefore(b.dateTime) ? 0 : 1);
//       // }


//   }

//   String getDay() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final difference = selectedDateTime.value.difference(today).inDays;

//     switch (difference) {
//       case 0:
//         return 'Today';
//       case 1:
//         return 'Tomorrow';
//       case 2:
//         return 'After tomorrow';
//       default:
//         return 'In $difference days';
//     }
//   }

//   Future<void> pickTime() async {
//     final res = await showTimePicker(
//       initialTime: TimeOfDay.fromDateTime(initialDateTime.value),
//       context: Get.context!,
//     );

//     if (res != null) {
//       // setState(() {
//         final now = DateTime.now();
//         selectedDateTime.value = now.copyWith(
//           hour: res.hour,
//           minute: res.minute,
//           second: 0,
//           millisecond: 0,
//           microsecond: 0,
//         );
//         if (selectedDateTime.value.isBefore(now)) {
//           selectedDateTime.value = selectedDateTime.value.add(const Duration(days: 1));
//         }
//       // });
//     }
//   }


//   Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
//     Get.to(()=>AlarmRingView(alarmSettings: alarmSettings));
//     loadAlarms();
//   }

//   Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
//     final res = await showModalBottomSheet<bool?>(
//       context: Get.context!,
//       isScrollControlled: true,
//       isDismissible: false,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       builder: (context) {
//         return FractionallySizedBox(
//           heightFactor: 0.65,
//           child: EditAlarmView(alarmSettings: settings),
//         );
//       },
//     );

//     if (res != null && res == true) loadAlarms();
//     Alarm.getAlarms();

//   }

//   Future<void> checkAndroidNotificationPermission() async {
//     final status = await Permission.notification.status;
//     if (status.isDenied) {
//       alarmPrint('Requesting notification permission...');
//       final res = await Permission.notification.request();
//       alarmPrint(
//         'Notification permission ${res.isGranted ? '' : 'not '}granted',
//       );
//     }
//   }

//   Future<void> checkAndroidExternalStoragePermission() async {
//     final status = await Permission.storage.status;
//     if (status.isDenied) {
//       alarmPrint('Requesting external storage permission...');
//       final res = await Permission.storage.request();
//       alarmPrint(
//         'External storage permission ${res.isGranted ? '' : 'not'} granted',
//       );
//     }
//   }

//   Future<void> checkAndroidScheduleExactAlarmPermission() async {
//     final status = await Permission.scheduleExactAlarm.status;
//     alarmPrint('Schedule exact alarm permission: $status.');
//     if (status.isDenied) {
//       alarmPrint('Requesting schedule exact alarm permission...');
//       final res = await Permission.scheduleExactAlarm.request();
//       alarmPrint(
//         'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
//       );
//     }
//   }


//   AlarmSettings buildAlarmSettings(alarmId) {

//     Random random = Random();

//     final id = creating.value
//         ? random.nextInt(1000)
//         : alarmId;

//     // SQLHelper.instance.insertAlarm(
//     //   {
//     //     "id":id,
//     //     "dateTime":selectedDateTime.value.toString(),
//     //     "loopAudio":loopAudio.value.toString(),
//     //     "vibrate":vibrate.value.toString(),
//     //     "volume":volume.value.toString(),
//     //     "audioPath":assetAudio.value
//     //
//     //   }
//     // );


//     final alarmSets = AlarmSettings(
//       id: id,
//       dateTime: selectedDateTime.value,
//       loopAudio: loopAudio.value,
//       vibrate: vibrate.value,
//       volume: volume.value,
//       assetAudioPath: assetAudio.value,
//       notificationTitle: '',
//       notificationBody: labelAlarm.text !="" ? labelAlarm.text: 'Jangan lupa absen ya',
//       enableNotificationOnKill: Platform.isIOS,
//         androidFullScreenIntent: true
//     );

//     return alarmSets;

//   }



//   void saveAlarm(alarmId) {
//     if (loading.value) return;

//     loading.value = true;

//     Alarm.set(alarmSettings: buildAlarmSettings(alarmId)).then((res) {
//       if (res){
//       loading.value = false;
//       assetAudio.value = "";
//       vibrate.value = false;
//       volumeToggle.value = false;
//       selectedDateTime.value = DateTime.now();
//       loopAudio.value = false;
//       initialDateTime.value = DateTime.now();
//       labelAlarm.text = "";
//       }

//     });
//     loadAlarms();
//     Alarm.getAlarms();
//     Get.back();

//   }



//   // void deleteAlarm(id) {
//   //   Alarm.delete(id).then((res) {
//   //     if (res){
//   //       loadAlarms();

//   //     }
//   //   });
//   //   Get.back();
//   // }

// }
