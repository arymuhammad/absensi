import 'dart:async';

import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/db_result.dart';
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
    required String level,
    required String type,
    String? date1,
    String? date2,
    required String status,
  }) async {
    listOvt.clear();
    var data = {
      "type": type,
      "user_id": idUser,
      "level": level,
      "init_date": (date1?.isNotEmpty ?? false) ? date1! : initDate,
      "end_date": (date2?.isNotEmpty ?? false) ? date2! : endDate,
      "status": status,
    };
    // print(data);
    final response = await ServiceApi().overtime(data);
    isLoading.value = false;
    if (response != null) listOvt.value = response;
    return listOvt;
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
    await getListOvertime(idUser: id, level: level, type: "get_by_id", status: "");
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
    required String idOvt,
    required String idUser,
    required String date1,
    required String date2,
  }) async {
    var data = {
      {
            "1": "acc_4",
            "17": "acc_4",
            "18": "acc_4",
            "39": "acc_4",
            "96": "acc_3",
            "26": "acc_2",
            "19": "acc_1",
            "20": "acc_1",
          }[level]!:
          "reject",
      "type": "reject",
      "level": level,
      "id_user": idOvt,
      "init_date": date1,
      "end_date": date2,
    };
    // print(data);
    final response = await ServiceApi().overtime(data);
    if (response['success'] == true) {
      await getListOvertime(
        idUser: idUser,
        level: level,
        type: "",
        status: "pending",
      );
      showToast(response['message']);
    } else {
      showToast(response['message']);
    }
  }

  accept({
    required String level,
    required String idOvt,
    required String idUser,
    required String date1,
    required String date2,
  }) async {
    var data = {
      {
            "1": "acc_4",
            "17": "acc_4",
            "18": "acc_4",
            "39": "acc_4",
            "96": "acc_3",
            "26": "acc_2",
            "19": "acc_1",
            "20": "acc_1",
          }[level]!:
          "approve",
      "type": "accept",
      "level": level,
      "id_user": idOvt,
      "init_date": date1,
      "end_date": date2,
    };
    // print(data);
    final response = await ServiceApi().overtime(data);
    if (response['success'] == true) {
      await getListOvertime(
        idUser: idUser,
        level: level,
        type: "",
        status: "pending",
      );
      showToast(response['message']);
    } else {
      showToast(response['message']);
    }
  }
}
