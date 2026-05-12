import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
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
  final adjC = Get.find<AdjustPresenceController>();
  final pages = [
    RequestLeaveView(),
    ReqOvertimeView(),
    ReqAppUserView(isInbox: false),
  ];

  @override
  Widget build(BuildContext context) {
    final userData = logC.logUser.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Approval'),
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient(
              context: context,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: ctrl.selectedTab.value,
                    thumbColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          'Leave',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          'Overtime',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      2: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          'Presence',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
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
                            leaveC.isLoading.value = true;
                            await leaveC.getLeaveReq(param);

                            break;
                          case 1:
                            // if (overtimeC.listOvt.isEmpty) {
                            await overtimeC.getListOvertime(
                              idUser: userData.id!,
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
