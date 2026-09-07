import 'package:flutter/material.dart';

import '../../../../data/helper/const.dart';
import '../../../../data/model/req_leave_model.dart';

class StepConfig {
  //=======================================
  // GET NOTE TITLE
  //=======================================

  List<String> getNodeTitles(ReqLeaveModel leave) {
    if (leave.parentId == "3") {
      final skipStore =
          leave.levelId == "19" ||
          leave.levelId == "20" ||
          leave.levelId == "59";

      if (skipStore) {
        return ['Apply', 'Area Manager', 'Ops', 'HR'];
      }

      return ['Apply', 'Store Manager', 'Area Manager', 'Ops', 'HR'];
    }

    if (leave.parentId == "2") {
      return [
        'Apply',
        (leave.levelId == "29" ||
                leave.levelId == "80" ||
                leave.levelId == "60")
            ? 'General Manager'
            : 'Operational Manager',
        'HR',
      ];
    }

    if (leave.parentId == "4") {
      return [
        'Apply',
        leave.levelId != '43' ? 'IT Manager' : 'General Manager',
        'HR',
      ];
    }

    if (leave.parentId == "5") {
      return [
        'Apply',
        leave.levelId != '77' ? 'EDITORIAL Manager' : 'General Manager',
        'HR',
      ];
    }

    if (leave.parentId == "8") {
      return [
        'Apply',
        leave.levelId != '18' ? 'HR Manager' : 'General Manager',
        'HR',
      ];
    }

    if (leave.parentId == "9") {
      return [
        'Apply',
        leave.levelId != '41' ? 'Brand Manager' : 'General Manager',
        'HR',
      ];
    }

    return ['Apply', 'Store Manager', 'Area Manager', 'HR'];
  }

  //===================================================
  // GET APPROVAL VALUE
  //===================================================

  String? getApprovalValue(ReqLeaveModel leave, int index) {
    if (leave.parentId == "3") {
      final skipStore =
          leave.levelId == "19" ||
          leave.levelId == "20" ||
          leave.levelId == "59";

      if (skipStore) {
        switch (index) {
          case 1:
            return leave.acc2;
          case 2:
            return leave.acc3;
          case 3:
            return leave.acc4;
          default:
            return null;
        }
      } else {
        switch (index) {
          case 1:
            return leave.acc1;
          case 2:
            return leave.acc2;
          case 3:
            return leave.acc3;
          case 4:
            return leave.acc4;
          default:
            return null;
        }
      }
    }

    // 🔥 INI YANG DIPERBAIKI
    // selain parentId 3 → hanya pakai acc2 & acc4
    switch (index) {
      case 1:
        return leave.acc2; // atasan
      case 2:
        return leave.acc4; // HR
      default:
        return null;
    }
  }

  //=========================================
  // GET STEP STATUS
  //=========================================

  String getStepStatus(ReqLeaveModel leave) {
    bool isEmpty(String? val) => val == null || val.isEmpty;

    // 🔴 reject tetap global
    if (leave.acc1 == 'reject' ||
        leave.acc2 == 'reject' ||
        leave.acc3 == 'reject' ||
        leave.acc4 == 'reject') {
      return "rejected";
    }

    // ======================
    // 🔥 KHUSUS PARENT 3
    // ======================
    if (leave.parentId == "3") {
      final skipStore =
          leave.levelId == "19" ||
          leave.levelId == "20" ||
          leave.levelId == "59";

      if (skipStore) {
        // acc2 → acc3 → acc4
        if (isEmpty(leave.acc2) || isEmpty(leave.acc3) || isEmpty(leave.acc4)) {
          return "pending";
        }
      } else {
        // acc1 → acc2 → acc3 → acc4
        if (isEmpty(leave.acc1) ||
            isEmpty(leave.acc2) ||
            isEmpty(leave.acc3) ||
            isEmpty(leave.acc4)) {
          return "pending";
        }
      }

      return "approved";
    }

    // ======================
    // 🔥 SEMUA PARENT LAIN
    // ======================
    // Apply → Atasan → HR
    // 👉 acc2 & acc4 doang
    if (isEmpty(leave.acc2) || isEmpty(leave.acc4)) {
      return "pending";
    }

    return "approved";
  }

  //==================================================
  // GET STEP COLOR
  //==================================================

  Color getStepColor(ReqLeaveModel leave, int index) {
    final val = getApprovalValue(leave, index);

    if (index == 0) return Colors.green;

    bool previousApproved = true;

    for (int i = 1; i < index; i++) {
      final prevVal = getApprovalValue(leave, i);
      if (prevVal == null || prevVal == 'reject') {
        previousApproved = false;
        break;
      }
    }

    if (val == 'reject') return red!;
    if (!previousApproved || val == null) {
      return Colors.grey;
    }

    return Colors.green;
  }

  //=================================================
  // BUILD STEP ICON
  //================================================

  Widget buildStepIcon(ReqLeaveModel leave, int index) {
    if (index == 0) {
      return const Icon(Icons.check, color: Colors.white, size: 18);
    }

    final val = getApprovalValue(leave, index);

    // ❌ kalau step ini reject
    if (val == 'reject') {
      return const Icon(Icons.close, color: Colors.white, size: 18);
    }

    // 🔥 CEK: apakah semua step sebelumnya sudah approved?
    bool previousApproved = true;

    for (int i = 1; i < index; i++) {
      final prevVal = getApprovalValue(leave, i);

      if (prevVal == null || prevVal == 'reject') {
        previousApproved = false;
        break;
      }
    }

    // ⏳ kalau belum waktunya (step sebelumnya belum selesai)
    if (!previousApproved) {
      return const Icon(Icons.hourglass_empty, color: Colors.grey);
    }

    // ⏳ kalau step ini belum di-acc
    if (val == null) {
      return const Icon(Icons.hourglass_empty, color: Colors.grey);
    }

    // ✅ baru boleh hijau
    return const Icon(Icons.check, color: Colors.white, size: 18);
  }

  //=======================================
  // GET CURRENT STEP
  //=======================================

  int getCurrentStep(ReqLeaveModel leave) {
    if (leave.parentId == "3") {
      final skipStore =
          leave.levelId == "19" ||
          leave.levelId == "20" ||
          leave.levelId == "59";

      if (skipStore) {
        if (leave.acc2 == null) return 0;
        if (leave.acc3 == null) return 1;
        if (leave.acc4 == null) return 2;
        return 3;
      } else {
        if (leave.acc1 == null) return 0;
        if (leave.acc2 == null) return 1;
        if (leave.acc3 == null) return 2;
        if (leave.acc4 == null) return 3;
        return 4;
      }
    }

    // 🔥 FIX NON PARENT 3
    if (leave.acc2 == null) return 0;
    if (leave.acc4 == null) return 1;
    return 2;
  }
}
