import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/approval/main_tab.dart';
import 'package:absensi/app/modules/izin/controllers/izin_controller.dart';
import 'package:absensi/app/modules/izin/views/izin_view.dart';
import 'package:absensi/app/modules/leave/views/leave_view.dart';
import 'package:absensi/app/modules/overtime/controllers/overtime_controller.dart';
import 'package:absensi/app/modules/overtime/views/overtime_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/home/controllers/home_controller.dart';
import '../../modules/home/views/req_app_user_view.dart';
import '../../modules/leave/controllers/leave_controller.dart';
import '../../modules/login/controllers/login_controller.dart';

class AppNavigator {
  static final homeKey = GlobalKey<NavigatorState>();
  static final historyKey = GlobalKey<NavigatorState>();
  static final settingKey = GlobalKey<NavigatorState>();
  static final profileKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState>? getKey(int index) {
    switch (index) {
      case 0:
        return homeKey;
      case 1:
        return historyKey;
      case 3:
        return settingKey;
      case 4:
        return profileKey;
      default:
        return null;
    }
  }
}

class NotificationNavigation {
  static Future<void> openApproval() async {
    // debugPrint("HOME KEY = ${AppNavigator.homeKey.currentState}");
    final loginC = Get.find<LoginController>();

    loginC.selected.value = 0;

    if (AppNavigator.homeKey.currentState != null) {
      AppNavigator.homeKey.currentState?.push(
        MaterialPageRoute(builder: (_) => MainTab()),
      );
    }
  }

  static Future<void> openLeave() async {
    final loginC = Get.find<LoginController>();

    loginC.selected.value = 0;

    if (AppNavigator.homeKey.currentState != null) {
      AppNavigator.homeKey.currentState?.push(
        MaterialPageRoute(builder: (_) => LeaveView()),
      );
    }
  }

  static Future<void> openOverTime() async {
    final loginC = Get.find<LoginController>();

    loginC.selected.value = 0;

    if (AppNavigator.homeKey.currentState != null) {
      AppNavigator.homeKey.currentState?.push(
        MaterialPageRoute(builder: (_) => OvertimeView()),
      );
    }
  }

  static Future<void> openInbox() async {
    final loginC = Get.find<LoginController>();

    loginC.selected.value = 0;

    if (AppNavigator.homeKey.currentState != null) {
      AppNavigator.homeKey.currentState?.push(
        MaterialPageRoute(builder: (_) => ReqAppUserView(isInbox: true)),
      );
    }
  }

  static Future<void> openIzin() async {
    final loginC = Get.find<LoginController>();

    loginC.selected.value = 0;

    if (AppNavigator.homeKey.currentState != null) {
      AppNavigator.homeKey.currentState?.push(
        MaterialPageRoute(builder: (_) => IzinView()),
      );
    }
  }

  static Future<void> handleNotificationMap(Map<String, dynamic> data) async {
    final menu = data['menu'];

    final loginC = Get.find<LoginController>();
    final homeC = Get.find<HomeController>();
    final leaveC =
        Get.isRegistered<LeaveController>()
            ? Get.find<LeaveController>()
            : Get.put(LeaveController());
    final ovrC =
        Get.isRegistered<OvertimeController>()
            ? Get.find<OvertimeController>()
            : Get.put(OvertimeController());
    final adjC =
        Get.isRegistered<AdjustPresenceController>()
            ? Get.find<AdjustPresenceController>()
            : Get.put(AdjustPresenceController());
    final permC =
        Get.isRegistered<IzinController>()
            ? Get.find<IzinController>()
            : Get.put(IzinController());

    var uData = loginC.logUser.value;

    // debugPrint("NOTIF_DEBUG: DATA = $data");

    var levelList = [
      '1',
      '17',
      '18',
      '19',
      '20',
      '26',
      '39',
      '59',
      '96',
      '106',
    ];
    // pindah ke tab Home di BottomBar
    loginC.selected.value = 0;

    if (levelList.contains(uData.level)) {
      // pindah ke tab Approval
      NotificationNavigation.openApproval();
      if (menu == 'leave') {
        homeC.selectedTab.value = 0;
        // Get Data Leave Request

        // 🔥 reset sebelum masuk
        ovrC.listOvt.clear();
        homeC.isTabLoading.value = false;
        leaveC.listLeaveReq.clear();
        var param = {
          "type": "get_pending_req_leave",
          "kode_cabang": uData.kodeCabang!,
          "id_user": uData.id!,
          "level": uData.level!,
          "parent_id": uData.parentId!,
        };
        // print(param);
        leaveC.getLeaveReq(param);
        //
        homeC.isTabLoading.value = false;
      } else if (menu == 'overtime') {
        // Get Data Overtime Request
        homeC.selectedTab.value = 1;
        await ovrC.getListOvertime(
          idUser: uData.id!,
          branchCode: uData.kodeCabang!,
          level: uData.level!,
          type: "",
          status: "pending",
        );
        homeC.isTabLoading.value = false;
        //
      } else if (menu == 'presence') {
        // Get Data Edit Absen Request
        homeC.selectedTab.value = 2;
        await adjC.getReqAppUpt(
          '',
          'approval',
          uData.level,
          uData.id,
          uData.kodeCabang,
          adjC.initDate,
          adjC.lastDate,
        );
        homeC.isTabLoading.value = false;
        //
      } else if (menu == 'permission') {
        // Get Data Izin Request
        homeC.selectedTab.value = 3;
        permC.isLoading.value = true;
        await permC.getPermissionList(
          type: "get_pending_req_permission",
          idUser: uData.id!,
          kodeCabang: uData.kodeCabang!,
          parentId: uData.parentId!,
          level: uData.level!,
          status: "",
          date1: permC.initDate,
          date2: permC.endDate,
        );
        //
        homeC.isTabLoading.value = false;
      }
    } else {
      if (menu == 'leave') {
        // Get Data Leave Request
        leaveC.isLoading.value = true;
        leaveC.getLeaveReq({"type": "", "id_user": uData.id!});
        //
        NotificationNavigation.openLeave();
      } else if (menu == 'overtime') {
        // Get Data Overtime Request
        ovrC.listOvt.clear();
        ovrC.isLoading.value = true;
        ovrC.getListOvertime(
          idUser: uData.id!,
          branchCode: uData.kodeCabang!,
          level: uData.level!,
          type: "get_by_id",
          status: "",
        );
        //
        NotificationNavigation.openOverTime();
      } else if (menu == 'presence') {
        // Get Data Edit Absen Request
        adjC.getReqAppUpt(
          '',
          'inbox',
          uData.level,
          uData.id,
          uData.kodeCabang,
          adjC.initDate,
          adjC.lastDate,
        );
        //
        NotificationNavigation.openInbox();
      } else if (menu == 'permission') {
        // Get Data Izin Request
        permC.getPermissionList(
          idUser: uData.id!,
          kodeCabang: uData.kodeCabang!,
          parentId: uData.parentId!,
          level: uData.level!,
          type: "",
          status: "",
        );
        //
        NotificationNavigation.openIzin();
      }
    }

    // debugPrint("Notification clicked: $data");
  }

  static void handleNotificationRm(RemoteMessage message) async {
    final menu = message.data['menu'];

    final loginC = Get.find<LoginController>();
    final homeC = Get.find<HomeController>();

    final leaveC =
        Get.isRegistered<LeaveController>()
            ? Get.find<LeaveController>()
            : Get.put(LeaveController());
    final ovrC =
        Get.isRegistered<OvertimeController>()
            ? Get.find<OvertimeController>()
            : Get.put(OvertimeController());
    final adjC =
        Get.isRegistered<AdjustPresenceController>()
            ? Get.find<AdjustPresenceController>()
            : Get.put(AdjustPresenceController());
    final permC =
        Get.isRegistered<IzinController>()
            ? Get.find<IzinController>()
            : Get.put(IzinController());

    var uData = loginC.logUser.value;
    var levelList = [
      '1',
      '17',
      '18',
      '19',
      '20',
      '26',
      '39',
      '59',
      '96',
      '106',
    ];
    // pindah ke tab Home di BottomBar
    loginC.selected.value = 0;

    if (levelList.contains(uData.level)) {
      // pindah ke tab Approval
      NotificationNavigation.openApproval();
      if (menu == 'leave') {
        homeC.selectedTab.value = 0;
        // Get Data Leave Request

        // 🔥 reset sebelum masuk
        ovrC.listOvt.clear();
        leaveC.listLeaveReq.clear();
        var param = {
          "type": "get_pending_req_leave",
          "kode_cabang": uData.kodeCabang!,
          "id_user": uData.id!,
          "level": uData.level!,
          "parent_id": uData.parentId!,
        };
        // print(param);
        leaveC.getLeaveReq(param);
        homeC.isTabLoading.value = false;
        //
      } else if (menu == 'overtime') {
        // Get Data Overtime Request
        homeC.selectedTab.value = 1;
        await ovrC.getListOvertime(
          idUser: uData.id!,
          branchCode: uData.kodeCabang!,
          level: uData.level!,
          type: "",
          status: "pending",
        );
        //
        homeC.isTabLoading.value = false;
      } else if (menu == 'presence') {
        // Get Data Edit Absen Request
        homeC.selectedTab.value = 2;
        await adjC.getReqAppUpt(
          '',
          'approval',
          uData.level,
          uData.id,
          uData.kodeCabang,
          adjC.initDate,
          adjC.lastDate,
        );
        //
        homeC.isTabLoading.value = false;
      } else if (menu == 'permission') {
        // Get Data Izin Request
        homeC.selectedTab.value = 3;
        permC.isLoading.value = true;
        await permC.getPermissionList(
          type: "get_pending_req_permission",
          idUser: uData.id!,
          kodeCabang: uData.kodeCabang!,
          parentId: uData.parentId!,
          level: uData.level!,
          status: "",
          date1: permC.initDate,
          date2: permC.endDate,
        );
        //
        homeC.isTabLoading.value = false;
      }
    } else {
      if (menu == 'leave') {
        // Get Data Leave Request
        leaveC.isLoading.value = true;
        leaveC.getLeaveReq({"type": "", "id_user": uData.id!});
        //
        NotificationNavigation.openLeave();
      } else if (menu == 'overtime') {
        // Get Data Overtime Request
        ovrC.listOvt.clear();
        ovrC.isLoading.value = true;
        ovrC.getListOvertime(
          idUser: uData.id!,
          branchCode: uData.kodeCabang!,
          level: uData.level!,
          type: "get_by_id",
          status: "",
        );
        //
        NotificationNavigation.openOverTime();
      } else if (menu == 'presence') {
        // Get Data Edit Absen Request
        adjC.getReqAppUpt(
          '',
          'inbox',
          uData.level,
          uData.id,
          uData.kodeCabang,
          adjC.initDate,
          adjC.lastDate,
        );
        //
        NotificationNavigation.openInbox();
      } else if (menu == 'permission') {
        // Get Data Izin Request
        permC.getPermissionList(
          idUser: uData.id!,
          kodeCabang: uData.kodeCabang!,
          parentId: uData.parentId!,
          level: uData.level!,
          type: "",
          status: "",
        );
        //
        NotificationNavigation.openIzin();
      }
    }

    // debugPrint("Notification clicked: ${message.data}");
  }
}
