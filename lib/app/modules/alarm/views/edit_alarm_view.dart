import 'dart:io';

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/modules/alarm/controllers/alarm_controller.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class EditAlarmView extends GetView {
  EditAlarmView({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;
  final alarmC = Get.put(AlarmController());


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  alarmC.loading.value = false;
                  alarmC.selectedDateTime.value = DateTime.now();
                  alarmC.initialDateTime.value = DateTime.now();
                  alarmC.assetAudio.value = "";
                  alarmC.vibrate.value = false;
                  alarmC.volumeToggle.value = false;
                  alarmC.loopAudio.value = false;
                  alarmC.labelAlarm.text = "";
                  Navigator.pop(context, false);
                },
                icon: Icon(
                  Platform.isIOS ? CupertinoIcons.xmark_circle_fill : Icons
                      .cancel, color: red,),
                label: Text(
                  'Cancel',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: red),
                ),
              ),
              Obx(() {
                return TextButton.icon(
                  onPressed: () {
                    if (!alarmC.creating.value && alarmC.assetAudio.isEmpty) {
                      alarmC.assetAudio.value = alarmSettings!.assetAudioPath;
                      alarmC.saveAlarm(alarmSettings?.id);
                    } else if (!alarmC.creating.value &&
                        alarmC.assetAudio.isNotEmpty) {
                      alarmC.assetAudio.value = alarmC.assetAudio.value;
                      alarmC.saveAlarm(alarmSettings?.id);
                    } else {
                      if (alarmC.assetAudio.isEmpty) {
                        // if(alarmSettings!.assetAudioPath !=""){
                        //   alarmC.assetAudio.value = alarmSettings!.assetAudioPath;
                        // }else{
                        showToast("Harap pilih sound terlebih dulu");
                        //   alarmC.loading.value = false;
                        // }

                      } else {
                        alarmC.saveAlarm(alarmSettings?.id);
                      }
                    }
                  },
                  icon: Icon(Platform.isIOS
                      ? CupertinoIcons.check_mark_circled_solid
                      : Icons.check_circle_rounded, color: mainColor,),
                  label: alarmC.loading.value
                      ? const CircularProgressIndicator()
                      : Text(
                    'Save',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blueAccent),
                  ),
                );
              }),
            ],
          ),
          Text(
            alarmC.getDay(),
            style: Theme
                .of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          ),
          RawMaterialButton(
            onPressed: alarmC.pickTime,
            fillColor: Colors.grey[200],
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Obx(() {
                if (!alarmC.creating.value) {
                  if (alarmC.selectedDateTime.value !=
                      alarmC.initialDateTime.value) {
                    alarmC.initialDateTime.value =
                        alarmC.selectedDateTime.value;
                    // alarmC.selectedDateTime.value = alarmC.selectedDateTime.value;
                  } else {
                    alarmC.selectedDateTime.value = alarmSettings!.dateTime;
                  }
                } else {
                  alarmC.selectedDateTime.value = alarmC.selectedDateTime.value;
                }
                return Text(
                  TimeOfDay.fromDateTime(alarmC.selectedDateTime.value).format(
                      context),
                  style: Theme
                      .of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: Colors.blueAccent),
                );
              }),
            ),
          ),
          const SizedBox(height: 10,),
          Obx(() {
            return !alarmC.creating.value ?  TextField(
              controller: alarmC.labelAlarm..text = alarmSettings!.notificationBody,
              decoration: InputDecoration(
                  labelText: 'Label',
                  hintText: 'Cth : Absen Masuk',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ) : TextField(
              controller: alarmC.labelAlarm,
              decoration: InputDecoration(
                  labelText: 'Label',
                  hintText: 'Cth : Absen Masuk',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              Obx(() {
                return Switch(
                  value: alarmC.loopAudio.value,
                  onChanged: (value) => alarmC.loopAudio.value = value,
                );
              }),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              Obx(() {
                return Switch(
                  value: alarmC.vibrate.value,
                  onChanged: (value) => alarmC.vibrate.value = value,
                );
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              Obx(() {
                return DropdownButton(
                  value: alarmC.assetAudio.isNotEmpty
                      ? alarmC.assetAudio.value : alarmSettings?.assetAudioPath,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'assets/sound/oppo.mp3',
                      child: Text('Oppo'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/sound/samsung.mp3',
                      child: Text('Samsung'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/sound/xiaomi.mp3',
                      child: Text('Xiaomi'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/sound/realme.mp3',
                      child: Text('Realme'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/sound/infinix.mp3',
                      child: Text('Infinix'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/sound/iphone.mp3',
                      child: Text('Iphone'),
                    ),
                  ],
                  onChanged: (value) {
                    alarmC.assetAudio.value = value!;
                  },
                );
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom volume',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              Obx(() {
                return Switch(
                    value: alarmC.volumeToggle.value,
                    onChanged: (value) {
                      alarmC.volumeToggle.value = value;
                      alarmC.volumeToggle.value
                          ? alarmC.volume.value = 0.8
                          : alarmC.volume.value = 1;
                    });
              }),
            ],
          ),
          Obx(() {
            return SizedBox(
              height: 30,
              child: alarmC.volumeToggle.value
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    alarmC.volume.value > 0.7
                        ? Icons.volume_up_rounded
                        : alarmC.volume.value > 0.1
                        ? Icons.volume_down_rounded
                        : Icons.volume_mute_rounded,
                  ),
                  Expanded(
                    child: Slider(
                      value: alarmC.volume.value,
                      onChanged: (value) {
                        alarmC.volume.value = value;
                      },
                    ),
                  ),
                ],
              )
                  : const SizedBox(),
            );
          }),
          if (!alarmC.creating.value)
            TextButton(
              onPressed: () => alarmC.deleteAlarm(alarmSettings!.id),
              child: Text(
                'Delete Alarm',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    );
  }


}