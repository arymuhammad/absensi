import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/helper/loading_dialog.dart';

class CsDropdownShiftKerja extends StatelessWidget {
  final String? value;
  CsDropdownShiftKerja({super.key, this.value});

  final absC = Get.find<AbsenController>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: absC.getShift(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var dataShift = snapshot.data!;
          return DropdownButtonFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Pilih Shift Absen'),
            value: value,
            onChanged: (data) {
              absC.selectedShift.value = data!;

              if (absC.selectedShift.value == "5") {
                absC.jamMasuk.value = absC.timeNow;
                absC.jamPulang.value = DateFormat("HH:mm").format(
                    DateTime.parse(absC.dateNowServer)
                        .add(const Duration(hours: 8)));
              } else {
                for (int i = 0; i < dataShift.length; i++) {
                  if (dataShift[i].id == data) {
                    absC.jamMasuk.value = dataShift[i].jamMasuk!;
                    absC.jamPulang.value = dataShift[i].jamPulang!;
                  }
                }
              }
              dialogMsg(
                  'Info', 'Pastikan Shift Kerja yang dipilih\nsudah sesuai');
            },
            items: dataShift
                .map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.namaShift.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          ' (${e.jamMasuk!} - ${e.jamPulang!})',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    )))
                .toList(),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CupertinoActivityIndicator();
      },
    );
  }
}
