import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:absensi/app/data/model/permission_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../services/service_api.dart';

class IzinController extends GetxController {
  var isLoading = true.obs;
  late TextEditingController date1, date2, remark, note;
  var listPrm = <PermissionModel>[].obs;
  final selectedStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchC = TextEditingController();
  Timer? debounce;

  XFile? image;
  final ImagePicker picker = ImagePicker();

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

  var statusReqPrm = [
    {"pending": "Pending"},
    {"reject": "Rejected"},
    {"approved": "Approved"},
  ];
  var selectedstatusPrm = "".obs;

  @override
  void onInit() {
    super.onInit();
    date1 = TextEditingController();
    date2 = TextEditingController();
    remark = TextEditingController();
    note = TextEditingController();
  }

  @override
  void onClose() {
    date1.clear();
    date2.clear();
    remark.clear();
    note.clear();
    super.onClose();
  }

  Future<List<PermissionModel>> getPermissionList({
    required String idUser,
    required String kodeCabang,
    required String parentId,
    required String level,
    required String type,
    String? date1,
    String? date2,
    required String status,
  }) async {
    listPrm.clear();
    var data = {
      "type": type,
      "id_user": idUser,
      "level": level,
      "kode_cabang": kodeCabang,
      "parent_id": parentId,
      "init_date": (date1?.isNotEmpty ?? false) ? date1! : initDate,
      "end_date": (date2?.isNotEmpty ?? false) ? date2! : endDate,
      "accept": status,
    };
    // print(data);
    final response = await ServiceApi().permission(data);
    isLoading.value = false;
    if (response != null) listPrm.value = response;
    return listPrm;
  }

  void uploadFile() async {
    image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (image != null) {
      update();
    }
  }

  Future<void> submitPermission({
    required String id,
    required String parentId,
    required String branchCode,
    required String name,
    required String level,
    required String initDate,
    required String endDate,
    required String remarks,
  }) async {
    final Map<String, dynamic> data = {
      "type": "add",
      "id": id,
      "branch_code": branchCode,
      "name": name,
      "level": level,
      "init_date": initDate,
      "end_date": endDate,
      "remark": remarks,
      "attach": image != null ? File(image!.path) : null,
    };

    final res = await ServiceApi().permissionAdd(data);
    if (res['success'] == true) {
      showToast('Izin berhasil dibuat');
    } else {
      showToast('Izin gagal dibuat');
    }
    resetForm();
    await getPermissionList(
      idUser: id,
      kodeCabang: branchCode,
      parentId: parentId,
      level: level,
      type: "",
      status: "pending",
    );
  }

  List<PermissionModel> get filteredList {
    return listPrm.where((e) {
      /// 🔹 FILTER STATUS
      if (selectedStatus.value != 'all') {
        if ((e.status ?? 'pending') != selectedStatus.value) return false;
      }

      /// 🔹 FILTER SEARCH
      final q = searchQuery.value.toLowerCase();

      if (q.isNotEmpty) {
        final name = (e.nama ?? '').toLowerCase();
        final branch = (e.namaCabang ?? '').toLowerCase();

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
    remark.clear();
    image = null;
    Get.back();
  }

  bool get canSubmit {
    return date1.text.isNotEmpty &&
        date2.text.isNotEmpty &&
        remark.text.isNotEmpty &&
        image != null;
  }

  reject({
    required String level,
    required String kodeCabang,
    required String parentId,
    required String idPerm,
    required String idUser,
    required String date1,
    required String date2,
    required String noted,
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
      {
            "1": "note_acc_4",
            "17": "note_acc_4",
            "18": "note_acc_4",
            "39": "note_acc_4",
            "96": "note_acc_3",
            "106": "note_acc_3",
            "26": "note_acc_2",
            "19": "note_acc_1",
            "20": "note_acc_1",
            "59": "note_acc_1",
          }[level]!:
          noted,
      "type": "approve_reject",
      "uid": idPerm,
      // "id_user": idUser,
      "level": level,
      "tanggal_mulai": date1,
      "tanggal_selesai": date2,
    };
    // print(data);
    final response = await ServiceApi().permission(data);
    if (response['success'] == true) {
      await getPermissionList(
        idUser: idUser,
        kodeCabang: kodeCabang,
        parentId: parentId,
        level: level,
        type: "get_pending_req_permission",
        status: "pending",
      );
      showToast(response['message']);
    } else {
      showToast(response['message']);
    }
    note.clear();
  }

  accept({
    required String level,
    required String kodeCabang,
    required String parentId,
    required String idPerm,
    required String idUser,
    required String date1,
    required String date2,
    required String noted,
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
      {
            "1": "note_acc_4",
            "17": "note_acc_4",
            "18": "note_acc_4",
            "39": "note_acc_4",
            "96": "note_acc_3",
            "106": "note_acc_3",
            "26": "note_acc_2",
            "19": "note_acc_1",
            "20": "note_acc_1",
            "59": "note_acc_1",
          }[level]!:
          noted,
      "type": "approve_reject",
      "uid": idPerm,
      // "id_user": idUser,
      "level": level,
      "tanggal_mulai": date1,
      "tanggal_selesai": date2,
    };
    // print(data);
    final response = await ServiceApi().permission(data);
    if (response['success'] == true) {
      await getPermissionList(
        idUser: idUser,
        kodeCabang: kodeCabang,
        parentId: parentId,
        level: level,
        type: "get_pending_req_permission",
        status: "pending",
      );
      showToast(response['message']);
    } else {
      showToast(response['message']);
    }
    note.clear();
  }

  delete(
    String? id,
    String idUser,
    String parentId,
    String level,
    String kodeCabang,
  ) async {
    final response = await http.post(
      Uri.parse('${ServiceApi().baseUrl}perm'),
      body: {"type": "delete", "id": id},
    );
    if (jsonDecode(response.body)['success'] == true) {
      showToast(jsonDecode(response.body)['message']);
      await getPermissionList(
        idUser: idUser,
        kodeCabang: kodeCabang,
        parentId: parentId,
        level: level,
        type: "",
        status: "",
      );
    }
  }
}
