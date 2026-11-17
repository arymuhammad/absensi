import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/approval/widget/req_perm_view.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/izin/controllers/izin_controller.dart';
import 'package:absensi/app/modules/leave/controllers/leave_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/helper/app_colors.dart';
import '../../data/helper/loading_platform.dart';
import '../home/views/req_app_user_view.dart';
import '../login/controllers/login_controller.dart';
import '../overtime/controllers/overtime_controller.dart';
import 'widget/req_presence_excep_view.dart';
import 'widget/request_leave_view.dart';
import 'widget/req_overtime_view.dart';

class MainTab extends StatelessWidget {
  MainTab({super.key});
  final logC = Get.find<LoginController>();
  final leaveC = Get.find<LeaveController>();
  final ctrl = Get.find<HomeController>();
  final overtimeC = Get.find<OvertimeController>();
  final permC = Get.find<IzinController>();
  final adjC = Get.find<AdjustPresenceController>();
  final pages = [
    RequestLeaveView(),
    ReqOvertimeView(),
    ReqAppUserView(isInbox: false),
    ReqPermView(),
  ];

  @override
  Widget build(BuildContext context) {
    final userData = logC.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Approval'),
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isDark
                    ? 'assets/image/bg-hd-drk.png'
                    : 'assets/image/bg-hd.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1E293B).withOpacity(0.78)
                            : Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: ctrl.selectedTab.value,
                    thumbColor:  isDark
              ? CupertinoColors.systemGrey.withOpacity(0.50)
              : Colors.white.withOpacity(0.82),
                    backgroundColor: Colors.transparent,
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Text(
                          'Leave',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Text(
                          'Overtime',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      2: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Text(
                          'Presence',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      3: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Text(
                          'Permission',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (val) async {
                      // print(val);
                      if (val == null) return;
                      ctrl.selectedTab.value = val;
                      ctrl.search.value = '';
                      ctrl.isTabLoading.value = true;
                      await Future.delayed(Duration.zero);

                      try {
                        switch (val) {
                          case 0:
                            var param = {
                              "type": "get_pending_req_leave",
                              "kode_cabang": userData.kodeCabang!,
                              "id_user": userData.id!,
                              "level": userData.level!,
                              "parent_id": userData.parentId!,
                            };
                            // print(param);
                            leaveC.isLoading.value = true;
                            await leaveC.getLeaveReq(param);

                            break;
                          case 1:
                            // if (overtimeC.listOvt.isEmpty) {
                            await overtimeC.getListOvertime(
                              idUser: userData.id!,
                              branchCode: userData.kodeCabang!,
                              level: userData.level!,
                              type: "",
                              status: "pending",
                            );
                            // }
                            break;
                          case 2:
                            await adjC.getReqAppUpt(
                              '',
                              'approval',
                              userData.level,
                              userData.id,
                              userData.kodeCabang,
                              adjC.initDate,
                              adjC.lastDate,
                            );
                            break;
                          case 3:
                            permC.isLoading.value = true;
                            await permC.getPermissionList(
                              type: "get_pending_req_permission",
                              idUser: userData.id!,
                              kodeCabang: userData.kodeCabang!,
                              parentId: userData.parentId!,
                              level: userData.level!,
                              status: "",
                              date1: permC.initDate,
                              date2: permC.endDate,
                            );

                            break;
                        }
                      } finally {
                        ctrl.isTabLoading.value = false;
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSearchTextField(
                backgroundColor:
                    isDark
                        ? const Color(0xFF1E293B).withOpacity(0.78)
                        : Colors.white.withOpacity(0.82),
                placeholder: 'Search...',
                onChanged: (val) {
                  ctrl.search.value = val;
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                if (ctrl.isTabLoading.value) {
                  return Center(child: platFormDevice());
                }

                switch (ctrl.selectedTab.value) {
                  case 0:
                    return RequestLeaveView();
                  case 1:
                    return ReqOvertimeView();
                  case 2:
                    return ReqPresenceExcepView();
                  case 3:
                    return ReqPermView();
                  default:
                    return const SizedBox();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
