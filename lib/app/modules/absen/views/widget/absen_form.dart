// import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/helper/time_service.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/dropdown_cabang.dart';
import '../../../shared/dropdown_shift_kerja.dart';
import '../../controllers/absen_controller.dart';

/// =======================================================
/// UI BUILDER
/// =======================================================
Widget buildAbsen({required Data? data, required AbsenController controller,}) {
  return Obx(() {
    if (controller.isCheckingAbsen.value) {
      return const Center(child: CircularProgressIndicator());
    }

    /// 🔴 WAJIB CHECKOUT KEMARIN
    if (controller.mustCheckoutYesterday.value) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   controller.stsAbsenSelected.value = "Check Out";
      // });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Absen pulang kemarin masih kosong.\nSilahkan Check Out terlebih dahulu",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          CsDropdownCabang(
            hintText: data!.namaCabang,
            dataUser: data,
            value:
                controller.selectedCabang.value.isEmpty
                    ? null
                    : controller.selectedCabang.value,
          ),
        ],
      );
    }

    /// ===================================================
    /// 🟢 NORMAL ABSEN HARI INI
    /// ===================================================
    return Column(
      children: [
        /// STATUS ABSEN
        Obx(
          () => SizedBox(
            height: 40,
            child: DropdownButtonFormField<String>(
              key: const ValueKey('sts_absen'),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.all(5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                label: const Text('Select one'),
              ),
              value:
                  controller.stsAbsenSelected.value.isEmpty
                      ? null
                      : controller.stsAbsenSelected.value,
              items:
                  controller.stsAbsen
                      .map(
                        (e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.stsAbsenSelected.value = val;
                  
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 5),

        CsDropdownCabang(
          hintText: data!.namaCabang,
          dataUser: data,
          value:
              controller.selectedCabang.value.isEmpty
                  ? null
                  : controller.selectedCabang.value,
        ),

        const SizedBox(height: 5),

        /// SHIFT KERJA (NO NETWORK TIME)
        Obx(
          () => Visibility(
            visible: controller.stsAbsenSelected.value != "Check Out",
            child: CsDropdownShiftKerja(
              page: 'absen',
              value:
                  controller.selectedShift.value.isEmpty
                      ? null
                      : controller.selectedShift.value,
              onChanged: (val) async {
                if (val == "5") {
                  final DateTime? now = await getServerTimeLocal();
                  final nowTime = FormatWaktu.formatJamMenit(
                    jamMenit:
                        "${now!.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
                  );

                  if (nowTime.isAfter(
                        FormatWaktu.formatJamMenit(jamMenit: '08:59'),
                      ) &&
                      nowTime.isBefore(
                        FormatWaktu.formatJamMenit(jamMenit: '15:00'),
                      )) {
                    controller.selectedShift.value = "";
                    dialogMsg(
                      'INFO',
                      'Cannot select this shift before\n15:00 local time.',
                    );
                    return;
                  }

                  controller.selectedShift.value = val!;
                } else {
                  for (final s in controller.shiftKerja) {
                    if (s.id == val) {
                      controller.selectedShift.value = val!;
                      controller.jamMasuk.value = s.jamMasuk!;
                      controller.jamPulang.value = s.jamPulang!;
                      break;
                    }
                  }
                }

                dialogMsg(
                  'INFO',
                  'Make sure the work shift selected is appropriate',
                );
              },
            ),
          ),
        ),
      ],
    );
  });
}
