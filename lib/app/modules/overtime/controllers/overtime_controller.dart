import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/overtime_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OvertimeController extends GetxController {
  var isLoading = true.obs;
  late TextEditingController date1, date2, clockIn, clockOut, remark;
  var listOvt = <OvertimeModel>[].obs;
  final selectedStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchC = TextEditingController();
  Timer? debounce;

  var initDate = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
    ),
  );
  var endDate = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString(),
    ),
  );

  var statusReqOvr = [
    {"pending": "Pending"},
    {"reject": "Rejected"},
    {"approved": "Approved"},
  ];
  var selectedstatusOvr = "".obs;

  RxBool isFabExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    date1 = TextEditingController();
    date2 = TextEditingController();
    clockIn = TextEditingController();
    clockOut = TextEditingController();
    remark = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    date1.clear();
    date2.clear();
    clockIn.clear();
    clockOut.clear();
    remark.clear();
    super.onClose();
  }

  Future<List<OvertimeModel>> getListOvertime({
    required String idUser,
    required String branchCode,
    required String level,
    required String type,
    String? date1,
    String? date2,
    required String status,
  }) async {
    final data = {
      "type": type,
      "user_id": idUser,
      "branch_code": branchCode,
      "level": level,
      "init_date": (date1?.isNotEmpty ?? false) ? date1! : initDate,
      "end_date": (date2?.isNotEmpty ?? false) ? date2! : endDate,
      "status": status,
    };

    debugPrint('======================================');
    debugPrint('[OVERTIME] RELOAD');
    debugPrint('[OVERTIME] PARAM : $data');

    try {
      isLoading.value = true;

      final response = await ServiceApi().overtime(data);

      debugPrint('[OVERTIME] RESPONSE TYPE : ${response.runtimeType}');

      if (response is List<OvertimeModel>) {
        debugPrint('[OVERTIME] RESPONSE LIST : ${response.length}');

        listOvt.assignAll(response);
      } else if (response is Map<String, dynamic>) {
        debugPrint('[OVERTIME] RESPONSE MAP : $response');

        // API berhasil tetapi tidak ada data
        if (response['success'] == true && response['data'] == null) {
          listOvt.clear();
        }
      } else {
        debugPrint('[OVERTIME] RESPONSE TIDAK VALID : $response');

        listOvt.clear();
      }

      debugPrint('[OVERTIME] LIST AFTER RELOAD : ${listOvt.length}');

      return listOvt.toList();
    } catch (e, stackTrace) {
      debugPrint('[OVERTIME] RELOAD ERROR : $e');
      debugPrint('[OVERTIME] STACK : $stackTrace');

      return listOvt.toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportOvertimeCsv() async {
    if (listOvt.isEmpty) {
      Get.snackbar('Export', 'Tidak ada data overtime untuk diexport');
      return;
    }

    final rows = <List<String>>[];

    // Header
    rows.add([
      'No',
      'Store',
      'Nama',
      'Tanggal',
      'Jam Mulai',
      'Jam Selesai',
      'Di Ajukan Pada',
      'Status',
    ]);

    // Data
    for (int i = 0; i < listOvt.length; i++) {
      final item = listOvt[i];

      rows.add([
        '${i + 1}',
        item.branchName ?? '',
        item.name ?? '',
        item.initDate ?? '',
        item.start ?? '',
        item.end ?? '',
        item.createdAt ?? '',
        item.status ?? '',
      ]);
    }

    // Convert ke CSV
    final csv = rows
        .map((row) {
          return row
              .map((value) {
                final text = value
                    .replaceAll('"', '""')
                    .replaceAll('\n', ' ')
                    .replaceAll('\r', ' ');

                return '"$text"';
              })
              .join(',');
        })
        .join('\r\n');

    // Folder Download Android
    final directory = Directory('/storage/emulated/0/Download');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final fileName = 'overtime_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = File('${directory.path}/$fileName');

    // BOM supaya Excel membaca UTF-8 dengan benar
    await file.writeAsString('\uFEFF$csv', encoding: utf8);

    Get.snackbar('Export Berhasil', 'File tersimpan di Download/$fileName');
  }

  Future<void> submitOvertime({
    required String id,
    required String branchCode,
    required String name,
    required String level,
    required String photo,
    required String initDate,
    required String endDate,
    required String start,
    required String end,
    required String remarks,
  }) async {
    final data = {
      "type": "add",
      "id": id,
      "branch_code": branchCode,
      "name": name,
      "level": level,
      "photo": photo,
      "init_date": initDate,
      "end_date": endDate,
      "start": start,
      "end": end,
      "remark": remarks,
    };
    final res = await ServiceApi().overtime(data);
    if (res['success'] == true) {
      showToast('Data berhasil dibuat');
    } else {
      showToast('Data gagal dibuat');
    }
    resetForm();
    await getListOvertime(
      idUser: id,
      branchCode: branchCode,
      level: level,
      type: "get_by_id",
      status: "",
    );
  }

  List<OvertimeModel> get filteredList {
    return listOvt.where((e) {
      /// 🔹 FILTER STATUS
      if (selectedStatus.value != 'all') {
        if ((e.status ?? 'pending') != selectedStatus.value) return false;
      }

      /// 🔹 FILTER SEARCH
      final q = searchQuery.value.toLowerCase();

      if (q.isNotEmpty) {
        final name = (e.name ?? '').toLowerCase();
        final branch = (e.branchName ?? '').toLowerCase();

        if (!name.contains(q) && !branch.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void resetForm() {
    date1.clear();
    date2.clear();
    clockIn.clear();
    clockOut.clear();
    remark.clear();
    Get.back();
  }

  bool get canSubmit {
    return date1.text.isNotEmpty &&
        date2.text.isNotEmpty &&
        clockIn.text.isNotEmpty &&
        clockOut.text.isNotEmpty &&
        remark.text.isNotEmpty;
  }

  reject({
    required String level,
    required String branchCode,
    required String idOvt,
    required String idUser,
    required String idUsrOvt,
  }) async {
    var data = {
      {
            "1": "acc_4",
            "17": "acc_4",
            "18": "acc_4",
            "39": "acc_4",
            "96": "acc_3",
            "106": "acc_3",
            "26": "acc_2",
            "19": "acc_1",
            "20": "acc_1",
            "59": "acc_1",
          }[level]!:
          "reject",
      "type": "reject",
      "id": idOvt,
      "id_user": idUsrOvt,
      "approval_id": idUser,
      "level": level,
    };
    // print(data);
    final response = await ServiceApi().overtime(data);
    if (response['success'] == true) {
      await getListOvertime(
        idUser: idUser,
        branchCode: branchCode,
        level: level,
        type: "",
        status: "pending",
        date1: date1.text,
        date2: date2.text,
      );
      showToast(response['message']);
    } else {
      showToast(response['message']);
    }
  }

  accept({
    required String level,
    required String branchCode,
    required String idOvt,
    required String idUser,
    required String idUsrOvt,
  }) async {
    var data = {
      {
            "1": "acc_4",
            "17": "acc_4",
            "18": "acc_4",
            "39": "acc_4",
            "96": "acc_3",
            "106": "acc_3",
            "26": "acc_2",
            "19": "acc_1",
            "20": "acc_1",
            "59": "acc_1",
          }[level]!:
          "approved",
      "type": "accept",
      "id": idOvt,
      "id_user": idUsrOvt,
      "approval_id": idUser,
      "level": level,
    };
    // print(data);
    final response = await ServiceApi().overtime(data);
    if (response['success'] == true) {
      await getListOvertime(
        idUser: idUser,
        branchCode: branchCode,
        level: level,
        type: "",
        status: "pending",
        date1: date1.text,
        date2: date2.text,
      );
      showToast(response['message']);
    } else {
      showToast(response['message']);
    }
  }
}
