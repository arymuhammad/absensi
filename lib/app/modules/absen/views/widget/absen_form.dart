import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/dropdown_cabang.dart';
import '../../../shared/dropdown_shift_kerja.dart';

final absC = Get.find<AbsenController>();
Widget buildAbsen({required Data? data}) {
  return Column(
    children: [
      Obx(()=> DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            label: Text('Select one'),
          ),
          value:
              absC.stsAbsenSelected.isEmpty ? null : absC.stsAbsenSelected.value,
          items:
              absC.stsAbsen
                  .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                  .toList(),
          onChanged: (val) {
            if (val != null) {
              absC.stsAbsenSelected.value = val;
            // print(absC.stsAbsenSelected.value);
            }
          },
        ),
      ),
      const SizedBox(height: 5),
      // Obx(
      //   () => Visibility(
      //     visible: absC.stsAbsenSelected.value != "Check Out",
      //     child: 
          CsDropdownCabang(
            hintText: data!.namaCabang,
            dataUser: data,
            value:
                absC.selectedCabang.value == ""
                    ? null
                    : absC.selectedCabang.value,
          ),
      //   ),
      // ),
      const SizedBox(height: 5),
      Obx(
        () => Visibility(
          visible: absC.stsAbsenSelected.value != "Check Out",
          child: CsDropdownShiftKerja(
            page: 'absen',
            value:
                absC.selectedShift.value == ""
                    ? null
                    : absC.selectedShift.value,
            onChanged: (val) {
              if (val == "5") {
                if (FormatWaktu.formatJamMenit(
                      jamMenit:
                          absC.timeNow.isNotEmpty
                              ? absC.timeNow
                              : absC.timeNowOpt,
                    ).isAfter(FormatWaktu.formatJamMenit(jamMenit: '08:59')) &&
                    FormatWaktu.formatJamMenit(
                      jamMenit:
                          absC.timeNow.isNotEmpty
                              ? absC.timeNow
                              : absC.timeNowOpt,
                    ).isBefore(FormatWaktu.formatJamMenit(jamMenit: '15:00'))) {
                  absC.selectedShift.value = "";
                  dialogMsg(
                    'INFO',
                    'Tidak dapat memilih shift ini sebelum\npukul 15:00 waktu setempat.\n\nSilahkan pilih shift yang lain',
                  );
                } else {
                  absC.selectedShift.value = val!;
                  absC.jamMasuk.value =
                      absC.timeNow.isNotEmpty ? absC.timeNow : absC.timeNowOpt;
                  absC.jamPulang.value = DateFormat("HH:mm").format(
                    DateTime.parse(
                      absC.dateNowServer,
                    ).add(const Duration(hours: 8)),
                  );
                  dialogMsg(
                    'INFO',
                    'Pastikan Shift Kerja yang dipilih\nsudah sesuai',
                  );
                }
              } else {
                for (int i = 0; i < absC.shiftKerja.length; i++) {
                  if (absC.shiftKerja[i].id == val) {
                    absC.selectedShift.value = val!;
                    absC.jamMasuk.value = absC.shiftKerja[i].jamMasuk!;
                    absC.jamPulang.value = absC.shiftKerja[i].jamPulang!;
                  }
                }
                dialogMsg(
                  'INFO',
                  'Pastikan Shift Kerja yang dipilih\nsudah sesuai',
                );
              }
            },
          ),
        ),
      ),
    ],
  );
}
