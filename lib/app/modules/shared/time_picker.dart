import 'package:absensi/app/modules/detail_absen/controllers/detail_absen_controller.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CsTimePicker extends StatelessWidget {
  CsTimePicker({
    super.key,
    required this.label,
    required this.controller,
    required this.jam,
    required this.info,
  });
  final String label;
  final TextEditingController controller;
  final String jam;
  final String info;

  final detailC = Get.put(DetailAbsenController());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   label,
          //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          GestureDetector(
            onTap: () async {
              Navigator.of(Get.context!).push(
                showPicker(
                  context: Get.context!,
                  value: _time,
                  onChange: onTimeChanged,
                  is24HrFormat: true,
                ),
              );
            },
            child: TextFormField(
              enabled: false,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              controller: controller,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.access_time_filled_rounded),
                  errorStyle: const TextStyle(color: Colors.red),
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true, // 🔑 biar tinggi tetap rapih
                  contentPadding: const EdgeInsets.all(5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  labelText: label,),
            ),
          )
        ],
      ),
    );
  }

  // Widget _createTimePicker(String text, TextEditingController controller) {
  //   return ;
  // }

  Time _time = Time(hour: DateTime.now().hour, minute: DateTime.now().minute);

  void onTimeChanged(Time newTime) {
    _time = newTime;
    controller.text = _time.format(Get.context!);
  }
}
