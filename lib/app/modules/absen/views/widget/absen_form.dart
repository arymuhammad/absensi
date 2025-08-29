import 'dart:io';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/dropdown_cabang.dart';
import '../../../shared/dropdown_shift_kerja.dart';

final absC = Get.find<AbsenController>();

Future<bool> cekAbsenBefore9AM(Data? data) async {
  //absen
  var previous = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      absC.dateNowServer.isNotEmpty ? absC.dateNowServer : absC.dateNow,
    ).add(const Duration(days: -1)),
  );
  // Get the current time
  DateTime now = DateTime.now();
  TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

  // Set the target time to 7:00 AM
  TimeOfDay targetTime = const TimeOfDay(hour: 09, minute: 01);

  // Convert TimeOfDay to DateTime for proper comparison
  DateTime currentDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    currentTime.hour,
    currentTime.minute,
  );
  DateTime targetDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    targetTime.hour,
    targetTime.minute,
  );

  // Compare the current time with the target time
  bool isBefore9AM = currentDateTime.isBefore(targetDateTime);
  // print(isBefore9AM);

  // if (isBefore9AM) {

  if (isBefore9AM) {
    await absC.cekDataAbsen("pulang", data!.id!, previous);
    return absC.cekAbsen.value.total == "1" &&
        absC.cekAbsen.value.idShift != "0";
  }
  return false;
}

Widget buildAbsen({required Data? data}) {
  return FutureBuilder<bool>(
    future: cekAbsenBefore9AM(data),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // tampilkan loading saat sedang cek async
        return Center(
          child:
              Platform.isAndroid
                  ? const CircularProgressIndicator()
                  : const CupertinoActivityIndicator(),
        );
      } else if (snapshot.hasData) {
        bool snapData = snapshot.data!;
        if (snapData) {
          // print('snappppp ${snapData}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            absC.stsAbsenSelected.value = "Check Out";
          });
          // kondisi ketika absen pulang kosong ditemukan
          return const Center(
            child: Text(
              "Absen pulang kemarin masih kosong. Silahkan Check out terlebih dahulu sebelum Check in",
            ),
          );
        } else {
          return Column(
            children: [
              Obx(
                () => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Select one'),
                  ),
                  value:
                      absC.stsAbsenSelected.isEmpty
                          ? null
                          : absC.stsAbsenSelected.value,
                  items:
                      absC.stsAbsen
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
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
                            ).isAfter(
                              FormatWaktu.formatJamMenit(jamMenit: '08:59'),
                            ) &&
                            FormatWaktu.formatJamMenit(
                              jamMenit:
                                  absC.timeNow.isNotEmpty
                                      ? absC.timeNow
                                      : absC.timeNowOpt,
                            ).isBefore(
                              FormatWaktu.formatJamMenit(jamMenit: '15:00'),
                            )) {
                          absC.selectedShift.value = "";
                          dialogMsg(
                            'INFO',
                            'Cannot select this shift before 15:00 local time.\n\nPlease select another shift',
                          );
                        } else {
                          absC.selectedShift.value = val!;
                          absC.jamMasuk.value =
                              absC.timeNow.isNotEmpty
                                  ? absC.timeNow
                                  : absC.timeNowOpt;
                          absC.jamPulang.value = DateFormat("HH:mm").format(
                            DateTime.parse(
                              absC.dateNowServer,
                            ).add(const Duration(hours: 8)),
                          );
                          dialogMsg(
                            'INFO',
                            'Make sure the work shift selected is appropriate',
                          );
                        }
                      } else {
                        for (int i = 0; i < absC.shiftKerja.length; i++) {
                          if (absC.shiftKerja[i].id == val) {
                            absC.selectedShift.value = val!;
                            absC.jamMasuk.value = absC.shiftKerja[i].jamMasuk!;
                            absC.jamPulang.value =
                                absC.shiftKerja[i].jamPulang!;
                          }
                        }
                        dialogMsg(
                          'INFO',
                          'Make sure the work shift selected is appropriate',
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        }
      } else {
        // jika terjadi error pada future
        return const Center(child: Text("There is an error"));
      }
    },
  );
}
