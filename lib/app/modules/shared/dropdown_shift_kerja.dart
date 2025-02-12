import 'package:absensi/app/data/helper/format_waktu.dart';
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
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          var dataShift = snapshot.data!;
          return DropdownButtonFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Pilih Shift Absen'),
            value: value,
            onChanged: (data) {
              // absC.selectedShift.value = data!;

              if (data == "5") {
                if (FormatWaktu.formatJamMenit(jamMenit: absC.timeNow)
                    .isBefore(FormatWaktu.formatJamMenit(jamMenit: '15:00'))) {
                  absC.selectedShift.value = "";
                  dialogMsg('INFO',
                      'Tidak dapat memilih shift ini sebelum\npukul 15:00 waktu setempat.\n\nSilahkan pilih shift yang lain');
                } else {
                  absC.selectedShift.value = data!;
                  absC.jamMasuk.value = absC.timeNow;
                  absC.jamPulang.value = DateFormat("HH:mm").format(
                      DateTime.parse(absC.dateNowServer)
                          .add(const Duration(hours: 8)));
                  dialogMsg('INFO',
                      'Pastikan Shift Kerja yang dipilih\nsudah sesuai');
                }
              } else {
                for (int i = 0; i < dataShift.length; i++) {
                  if (dataShift[i].id == data) {
                    absC.selectedShift.value = data!;
                    absC.jamMasuk.value = dataShift[i].jamMasuk!;
                    absC.jamPulang.value = dataShift[i].jamPulang!;
                  }
                }
                dialogMsg(
                    'INFO', 'Pastikan Shift Kerja yang dipilih\nsudah sesuai');
              }
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
