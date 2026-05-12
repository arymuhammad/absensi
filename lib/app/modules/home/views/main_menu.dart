import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/approval/main_tab.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/leave/views/leave_view.dart';
import 'package:absensi/app/modules/overtime/views/overtime_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../../data/model/login_model.dart';
import '../../adjust_presence/views/adjust_presence_view.dart';
import '../../leave/controllers/leave_controller.dart';
import '../../overtime/controllers/overtime_controller.dart';
import '../../pay_slip/controllers/pay_slip_controller.dart';
import '../../pay_slip/views/pay_slip_view.dart';
import '../../semua_absen/views/monitoring_absen_view.dart';
import 'req_app_user_view.dart';

class MainMenu extends StatelessWidget {
  final Data? userData;
  MainMenu({super.key, this.userData});

  final absC = Get.find<AbsenController>();
  final adjCtrl = Get.find<AdjustPresenceController>();
  final leaveC = Get.find<LeaveController>();
  final homeC = Get.find<HomeController>();
  final payC = Get.put(PaySlipController());
  final ovrC = Get.put(OvertimeController());
  // final logC = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8.0, 0),
      child: SizedBox(
        width: Get.mediaQuery.size.width,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Main Menu', style: titleTextStyle.copyWith(fontSize: 15)),
                InkWell(
                  onTap: () {
                    homeC.getPendingAdj(
                      idUser: userData!.id!,
                      idCabang: userData!.kodeCabang!,
                      level: userData!.level!,
                    );

                    if ((userData!.parentId == "3" &&
                            (userData!.level == "19" || userData!.level == "20" || userData!.level == "59" ||
                                userData!.level == "26")) ||
                        (userData!.parentId == "4" &&
                            (userData!.level == "1" ||
                                userData!.level == "43")) ||
                        (userData!.parentId == "5" &&
                            userData!.level == "77") ||
                        (userData!.parentId == "7" &&
                            userData!.level == "23") ||
                        (userData!.parentId == "8" &&
                            userData!.level == "18") ||
                        (userData!.parentId == "9" &&
                            userData!.level == "41") ||
                        (userData!.parentId == "2" &&
                            userData!.level == "10") ||
                        (userData!.parentId == "1")) {
                      homeC.getPendingApproval(
                        idUser: userData!.id!,
                        kodeCabang: userData!.kodeCabang!,
                        level: userData!.level!,
                        parentId: userData!.parentId!,
                      );
                    }
                  },
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: AppColors.itemsBackground,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Visibility(
                    visible:
                        ((userData!.parentId == "3" &&  (userData!.level == "19" || userData!.level == "20" || userData!.level == "59" ||  userData!.level == "26")) ||
                                (userData!.parentId == "4" &&
                                    (userData!.level == "1" ||
                                        userData!.level == "43")) ||
                                (userData!.parentId == "5" &&
                                    userData!.level == "77") ||
                                (userData!.parentId == "7" &&
                                    userData!.level == "23") ||
                                (userData!.parentId == "8" &&
                                    userData!.level == "17") ||
                                (userData!.parentId == "8" &&
                                    userData!.level == "18") ||
                                (userData!.parentId == "9" &&
                                    userData!.level == "41") ||
                                (userData!.parentId == "2" &&
                                    userData!.level == "10") ||
                                (userData!.parentId == "1"))
                            ? true
                            : false,
                    child: Row(
                      children: [
                        MenuIconWithBadge(
                          asset: 'assets/image/req-leave.png',
                          label: 'Approval',
                          count: homeC.totalNotif,
                          isLoading: homeC.isLoadingPending,
                          isError: homeC.isErrorPending,
                          onTap: () {
                            // clear list overtime first
                            ovrC.listOvt.clear();

                            // 🔥 reset sebelum masuk
                            homeC.selectedTab.value = 0;
                            homeC.isTabLoading.value = false;

                            leaveC.listLeaveReq.clear();
                            var param = {
                              "type": "get_pending_req_leave",
                              "kode_cabang": userData!.kodeCabang!,
                              "id_user": userData!.id!,
                              "level": userData!.level!,
                              "parent_id": userData!.parentId!,
                            };
                            // print(param);
                            // leaveC.isLoading.value = true;
                            leaveC.getLeaveReq(param);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MainTab()),
                            );
                          },
                        ),

                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  MenuIconItem(
                    asset: 'assets/image/leave.png',
                    label: 'Leave',
                    onTap: () {
                      leaveC.isLoading.value = true;
                      leaveC.getLeaveReq({
                        "type": "",
                        "id_user": userData!.id!,
                      });
                      //  loadingDialog('Mengecek sisa saldo cuti kamu', '');
                      // leaveC.leaveBalanceCheck(userData!);
                      // Get.back();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LeaveView()),
                      );
                    },
                  ),
                  Visibility(
                    visible: userData!.kodeCabang != "HO000",
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        MenuIconItem(
                          asset: 'assets/image/izin.png',
                          label: 'Overtime',
                          onTap: () {
                            // Get.to(
                            //   () => PaySlipView(userData: userData!),
                            //   transition: Transition.cupertino,
                            // );
                            ovrC.listOvt.clear();
                            ovrC.isLoading.value = true;
                            ovrC.getListOvertime(
                              idUser: userData!.id!,
                              level: userData!.level!,
                              type: "get_by_id",
                              status: "",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OvertimeView()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible:
                        userData!.parentId == "3" || userData!.parentId == "4",
                    child: Row(
                      children: [
                        MenuIconItem(
                          asset: 'assets/image/notif.png',
                          label: 'Inbox',
                          // count: homeC.pendingAdjCount,
                          // isLoading: homeC.isLoadingAdj,
                          // isError: homeC.isErrorAdj,
                          onTap: () {
                            // Get.to(() {
                            adjCtrl.getReqAppUpt(
                              '',
                              'inbox',
                              userData!.level,
                              userData!.id,
                              userData!.kodeCabang,
                              adjCtrl.initDate,
                              adjCtrl.lastDate,
                            );
                            //   return ReqAppUserView(userData: userData!);
                            // }, transition: Transition.cupertino);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReqAppUserView(isInbox: true),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  MenuIconItem(
                    asset: 'assets/image/payslip.png',
                    label: 'Payslip',
                    onTap: () {
                      // Get.to(
                      //   () => PaySlipView(userData: userData!),
                      //   transition: Transition.cupertino,
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PaySlipView()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible:
                        userData!.level == "1" ||
                                userData!.level == "26" ||
                                userData!.level == "19" ||
                                userData!.level == "20"
                            ? true
                            : false,
                    child: Row(
                      children: [
                        MenuIconItem(
                          asset: 'assets/image/monitoring.png',
                          label: 'Monitoring',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MonitoringAbsenView(),
                              ),
                            );
                            absC.searchAbsen.clear();
                            absC.userMonitor.value = "";
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: userData!.level == "1" ? true : false,
                    child: MenuIconItem(
                      asset: 'assets/image/adjust.png',
                      label: 'Adjust',
                      onTap: () {
                        adjCtrl.getReqAppUpt(
                          '',
                          '',
                          userData!.level,
                          userData!.id,
                          userData!.kodeCabang,
                          adjCtrl.initDate,
                          adjCtrl.lastDate,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdjustPresenceView(),
                          ),
                        );
                        absC.searchAbsen.clear();
                        absC.userMonitor.value = "";
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuIconItem extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const MenuIconItem({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30, width: 30, child: Image.asset(asset)),

            const SizedBox(height: 6),

            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuIconWithBadge extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;
  final RxInt count;
  final RxBool isLoading;
  final RxBool isError;

  const MenuIconWithBadge({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
    required this.count,
    required this.isLoading,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: Obx(() {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(asset),

                    /// 🔄 LOADING
                    if (isLoading.value)
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    /// ❌ ERROR
                    else if (isError.value)
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: Icon(Icons.error, color: Colors.red, size: 14),
                      )
                    /// 🔔 BADGE
                    else if (count.value > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Badge(
                          label: Text(
                            count.value.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 6),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
