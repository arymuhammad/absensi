import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/approval/main_tab.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/izin/controllers/izin_controller.dart';
import 'package:absensi/app/modules/izin/views/izin_view.dart';
import 'package:absensi/app/modules/leave/views/leave_view.dart';
import 'package:absensi/app/modules/overtime/views/overtime_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../adjust_presence/views/adjust_presence_view.dart';
import '../../leave/controllers/leave_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../overtime/controllers/overtime_controller.dart';
import '../../pay_slip/controllers/pay_slip_controller.dart';
import '../../pay_slip/views/pay_slip_view.dart';
import '../../semua_absen/views/monitoring_absen_view.dart';
import 'req_app_user_view.dart';

class MainMenu extends StatelessWidget {
  MainMenu({super.key});

  final absC = Get.find<AbsenController>();
  final adjCtrl = Get.find<AdjustPresenceController>();
  final leaveC = Get.find<LeaveController>();
  final homeC = Get.find<HomeController>();
  final payC = Get.put(PaySlipController());
  final ovrC = Get.put(OvertimeController());
  final prmC = Get.put(IzinController());
  final logC = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final userData = logC.logUser.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Main Menu',
                style: titleTextStyle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final userData = logC.logUser.value;
                  if ((userData.parentId == "3" &&
                          (userData.level == "19" ||
                              userData.level == "20" ||
                              userData.level == "59" ||
                              userData.level == "26")) ||
                      (userData.parentId == "4" &&
                          (userData.level == "1" || userData.level == "43")) ||
                      (userData.parentId == "5" && userData.level == "77") ||
                      (userData.parentId == "7" && userData.level == "23") ||
                      (userData.parentId == "8" && userData.level == "18") ||
                      (userData.parentId == "9" && userData.level == "41") ||
                      (userData.parentId == "2" && userData.level == "10") ||
                      (userData.parentId == "1") ||
                      (userData.level == "96") ||
                      (userData.level == "106")) {
                    homeC.getPendingAdj(
                      idUser: userData.id!,
                      idCabang: userData.kodeCabang!,
                      level: userData.level!,
                    );

                    homeC.getPendingApproval(
                      idUser: userData.id!,
                      kodeCabang: userData.kodeCabang!,
                      level: userData.level!,
                      parentId: userData.parentId!,
                    );

                    homeC.getPendingOvr(
                      idUser: userData.id!,
                      kodeCabang: userData.kodeCabang!,
                      level: userData.level!,
                      parentId: userData.parentId!,
                    );

                    homeC.getPendingPrm(
                      idUser: userData.id!,
                      kodeCabang: userData.kodeCabang!,
                      level: userData.level!,
                      parentId: userData.parentId!,
                    );
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),

          // const SizedBox(height: 5),
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 2.0,
            children: [
              // Approval
              // Visibility(
              //   visible:
              if ((userData.parentId == "3" &&
                      (userData.level == "19" ||
                          userData.level == "20" ||
                          userData.level == "59" ||
                          userData.level == "26")) ||
                  (userData.parentId == "4" &&
                      (userData.level == "1" || userData.level == "43")) ||
                  (userData.parentId == "5" && userData.level == "77") ||
                  (userData.parentId == "7" && userData.level == "23") ||
                  (userData.parentId == "8" && userData.level == "17") ||
                  (userData.parentId == "8" && userData.level == "18") ||
                  (userData.parentId == "9" && userData.level == "41") ||
                  (userData.parentId == "2" && userData.level == "10") ||
                  (userData.parentId == "1") ||
                  (userData.level == "96") ||
                  (userData.level == "106"))
                // child:
                DashboardMenuCard(
                  title: 'Approval',
                  icon: Icons.assignment_outlined,
                  badge: homeC.totalNotif,
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    final userData = logC.logUser.value;
                    // clear list overtime first
                    ovrC.listOvt.clear();

                    // 🔥 reset sebelum masuk
                    homeC.selectedTab.value = 0;
                    homeC.isTabLoading.value = false;

                    leaveC.listLeaveReq.clear();
                    var param = {
                      "type": "get_pending_req_leave",
                      "kode_cabang": userData.kodeCabang!,
                      "id_user": userData.id!,
                      "level": userData.level!,
                      "parent_id": userData.parentId!,
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

              // ),
              DashboardMenuCard(
                title: 'Cuti        ',
                icon: Icons.edit_calendar_rounded,
                color: const Color.fromARGB(255, 2, 159, 59),
                badge: 0.obs,
                onTap: () {
                  final userData = logC.logUser.value;
                  leaveC.isLoading.value = true;
                  leaveC.getLeaveReq({"type": "", "id_user": userData.id!});
                  //  loadingDialog('Mengecek sisa saldo cuti kamu', '');
                  // leaveC.leaveBalanceCheck(userData!);
                  // Get.back();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LeaveView()),
                  );
                },
              ),

              if (userData.kodeCabang != "HO000")
                // child:
                DashboardMenuCard(
                  title: 'Izin',
                  icon: Icons.health_and_safety_rounded,
                  color: const Color.fromARGB(255, 208, 9, 181),
                  badge: 0.obs,
                  onTap: () {
                    final userData = logC.logUser.value;
                    // LOGIC OVERTIME LAMA

                    prmC.getPermissionList(
                      idUser: userData.id!,
                      kodeCabang: userData.kodeCabang!,
                      parentId: userData.parentId!,
                      level: userData.level!,
                      type: "",
                      status: "",
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => IzinView()),
                    );
                  },
                ),

              // Visibility(
              //   visible:
              if (userData.kodeCabang != "HO000")
                // child:
                DashboardMenuCard(
                  title: 'Overtime',
                  icon: Icons.more_time_sharp,
                  color: const Color(0xFFF59E0B),
                  badge: 0.obs,
                  onTap: () {
                    final userData = logC.logUser.value;
                    // Get.to(
                    //   () => PaySlipView(userData: userData!),
                    //   transition: Transition.cupertino,
                    // );
                    ovrC.listOvt.clear();
                    ovrC.isLoading.value = true;
                    ovrC.getListOvertime(
                      idUser: userData.id!,
                      branchCode: userData.kodeCabang!,
                      level: userData.level!,
                      type: "get_by_id",
                      status: "",
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OvertimeView()),
                    );
                  },
                ),
              // ),

              // Visibility(
              //   visible:
              if (userData.parentId == "3" || userData.parentId == "4")
                // child:
                DashboardMenuCard(
                  title: 'Inbox  ',
                  icon: Icons.all_inbox_rounded,
                  color: const Color.fromARGB(255, 59, 132, 221),
                  badge: 0.obs,
                  onTap: () {
                    final userData = logC.logUser.value;
                    // Get.to(() {
                    adjCtrl.getReqAppUpt(
                      '',
                      'inbox',
                      userData.level,
                      userData.id,
                      userData.kodeCabang,
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

              // ),
              DashboardMenuCard(
                title: 'Slip Gaji',
                icon: Icons.receipt_long,
                color: const Color.fromARGB(255, 174, 196, 5),
                badge: 0.obs,
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

              // Visibility(

              //   visible:
              if (userData.level == "1" ||
                  userData.level == "26" ||
                  userData.level == "19" ||
                  userData.level == "20")
                // child:
                DashboardMenuCard(
                  title: 'Monitoring',
                  icon: Icons.monitor,
                  color: const Color(0xFFEC4899),
                  badge: 0.obs,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MonitoringAbsenView()),
                    );
                    absC.searchAbsen.clear();
                    absC.userMonitor.value = "";
                  },
                ),

              // ),
              // Visibility(
              //   visible:
              if (userData.level == "1")
                // child:
                DashboardMenuCard(
                  title: 'Adjust',
                  icon: Icons.access_time_filled_outlined,
                  color: const Color(0xFF14B8A6),
                  badge: 0.obs,
                  onTap: () {
                    final userData = logC.logUser.value;
                    adjCtrl.getReqAppUpt(
                      '',
                      '',
                      userData.level,
                      userData.id,
                      userData.kodeCabang,
                      adjCtrl.initDate,
                      adjCtrl.lastDate,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdjustPresenceView()),
                    );
                    absC.searchAbsen.clear();
                    absC.userMonitor.value = "";
                  },
                ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final RxInt? badge;

  const DashboardMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      // color: color.withOpacity(.9),
                      borderRadius: BorderRadius.circular(11),
                      gradient: AppColors.mainGradient(
                        context: context,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),

                    child: Icon(icon, color: Colors.white, size: 18),
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (badge!.value > 0)
            Positioned(
              top: -6,
              right: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.circular(20),
                  //  gradient: AppColors.mainGradient(
                  //         context: context,
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //       ),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
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
