import 'dart:io';
// import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/semua_absen/views/widget/form_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/helper/time_service.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/dropdown_cabang.dart';
import '../../../shared/dropdown_shift_kerja.dart';

// /// =======================================================
// /// CACHE STATE (DATE-AWARE)
// /// =======================================================
// // bool _absenChecked = false;
// // Future<bool>? _cekAbsenFuture;
// // String? _lastCheckedDate;

// /// =======================================================
// /// CEK ABSEN SEBELUM JAM 09:01 (PAKAI TimeService)
// /// =======================================================
// Future<bool> cekAbsenBefore9AM(Data? data) async {
//   final now = TimeService.nowLocal();
//   // final today = DateFormat('yyyy-MM-dd').format(now);

//   final previous = DateFormat('yyyy-MM-dd').format(
//     DateTime.parse(
//       absenC.dateNowServer.isNotEmpty ? absenC.dateNowServer : absenC.dateNow,
//     ).subtract(const Duration(days: 1)),
//   );

//   final currentDateTime = DateTime(
//     now.year,
//     now.month,
//     now.day,
//     now.hour,
//     now.minute,
//   );

//   final targetDateTime = DateTime(now.year, now.month, now.day, 15, 1);

//   final isBefore9AM = currentDateTime.isBefore(targetDateTime);

//   if (isBefore9AM) {
//     await absenC.cekDataAbsen("pulang", data!.id!, previous);

//     final mustCheckout =
//         absenC.cekAbsen.value.total == "1" &&
//         absenC.cekAbsen.value.idShift != "0";

//     /// 🔐 SINGLE SOURCE OF TRUTH
//     absenC.mustCheckoutYesterday.value = mustCheckout;
//     return mustCheckout;
//   }

//   absenC.mustCheckoutYesterday.value = false;
//   return false;
// }

/// =======================================================
/// UI BUILDER
/// =======================================================
Widget buildAbsen({required Data? data}) {
  // final today = DateFormat('yyyy-MM-dd').format(TimeService.nowLocal());

  /// 🔄 RESET JIKA TANGGAL BERGANTI
  // if (_lastCheckedDate != today) {
  //   _lastCheckedDate = today;
  //   _absenChecked = false;
  //   _cekAbsenFuture = null;

  //   absenC.mustCheckoutYesterday.value = false;
  //   absenC.stsAbsenSelected.value = "";
  // }

  // if (!_absenChecked) {
  //   _cekAbsenFuture = cekAbsenBefore9AM(data);
  //   _absenChecked = true;
  // }

  return Obx(() {
    if (absenC.isCheckingAbsen.value) {
      return const Center(child: CircularProgressIndicator());
    }

    /// 🔴 WAJIB CHECKOUT KEMARIN
    if (absenC.mustCheckoutYesterday.value) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   absenC.stsAbsenSelected.value = "Check Out";
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
                absenC.selectedCabang.value.isEmpty
                    ? null
                    : absenC.selectedCabang.value,
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
                  absenC.stsAbsenSelected.value.isEmpty
                      ? null
                      : absenC.stsAbsenSelected.value,
              items:
                  absenC.stsAbsen
                      .map(
                        (e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  absenC.stsAbsenSelected.value = val;
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
              absenC.selectedCabang.value.isEmpty
                  ? null
                  : absenC.selectedCabang.value,
        ),

        const SizedBox(height: 5),

        /// SHIFT KERJA (NO NETWORK TIME)
        Obx(
          () => Visibility(
            visible: absenC.stsAbsenSelected.value != "Check Out",
            child: CsDropdownShiftKerja(
              page: 'absen',
              value:
                  absenC.selectedShift.value.isEmpty
                      ? null
                      : absenC.selectedShift.value,
              onChanged: (val) async{
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
                    absenC.selectedShift.value = "";
                    dialogMsg(
                      'INFO',
                      'Cannot select this shift before\n15:00 local time.',
                    );
                    return;
                  }

                  absenC.selectedShift.value = val!;
                } else {
                  for (final s in absenC.shiftKerja) {
                    if (s.id == val) {
                      absenC.selectedShift.value = val!;
                      absenC.jamMasuk.value = s.jamMasuk!;
                      absenC.jamPulang.value = s.jamPulang!;
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
