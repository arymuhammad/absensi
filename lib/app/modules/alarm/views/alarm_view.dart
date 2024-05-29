import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alarm_controller.dart';
import 'alarm_tile_view.dart';

class AlarmView extends GetView<AlarmController> {
  AlarmView({super.key});
  final alarmC = Get.put(AlarmController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm'),
        centerTitle: true, flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bgapp.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      ),
      body: Obx(()=> alarmC.alarms.isNotEmpty ? ListView.builder(
        // separatorBuilder: (context, i) => const Divider(),
        itemCount: alarmC.alarms.length,
          itemBuilder: (context, i) {
            return AlarmTileView(
              key: Key(alarmC.alarms[i].id.toString()),
              title: TimeOfDay(
                hour: alarmC.alarms[i].dateTime.hour,
                minute: alarmC.alarms[i].dateTime.minute,
              ).format(context),
              subtitle: alarmC.alarms[i].notificationBody,
              onPressed: () {
                alarmC.initialDateTime.value = alarmC.alarms[i].dateTime;
                alarmC.selectedDateTime.value = alarmC.alarms[i].dateTime;
                alarmC.creating.value = false;
                alarmC.navigateToAlarmScreen(alarmC.alarms[i]);
              },
              onDismissed: () {
                Alarm.stop(alarmC.alarms[i].id).then((_) => alarmC.loadAlarms());
              },
            );
          },
        ) : Center(
          child: Text(
            'No alarms set',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ), floatingActionButton: Padding(
      padding: const EdgeInsets.all(10),
      child: FloatingActionButton(
        onPressed: () {
          alarmC.initialDateTime.value = DateTime.now();
          alarmC.selectedDateTime.value = DateTime.now();
          alarmC.creating.value = true;
          alarmC.navigateToAlarmScreen(null);
        },
        child: const Icon(Icons.alarm_add_rounded, size: 33),
      ),
    ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

  }
}
