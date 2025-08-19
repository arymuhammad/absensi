import 'package:absensi/app/data/model/notif_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/leave/views/leave_view.dart';
import 'package:absensi/app/modules/leave/views/request_leave_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helper/const.dart';
import '../../../data/model/login_model.dart';
import '../../adjust_presence/views/adjust_presence_view.dart';
import '../../leave/controllers/leave_controller.dart';
import '../../semua_absen/views/monitoring_absen_view.dart';
import 'req_app_user_view.dart';

class MainMenu extends StatelessWidget {
  final Data? userData;
  MainMenu({super.key, this.userData});

  final absC = Get.find<AbsenController>();
  final adjCtrl = Get.find<AdjustPresenceController>();
  final leaveC = Get.find<LeaveController>();
  final homeC = Get.find<HomeController>();
  // final logC = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: Get.mediaQuery.size.width,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Main Menu', style: titleTextStyle.copyWith(fontSize: 15)),
            const Divider(thickness: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Visibility(
                    visible:
                        ((userData!.parentId == "3" &&
                                    (userData!.level == "19" ||
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
                                (userData!.parentId == "1"))
                            ? true
                            : false,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                // var key = "";
                                // if (userData!.level == "19" ||
                                //     userData!.level == "26") {
                                //   key = "kode_cabang";
                                // }
                                var param = {
                                  "type": "get_pending_req_leave",
                                  "kode_cabang": userData!.kodeCabang!,
                                  "id_user": userData!.id!,
                                  "level": userData!.level!,
                                  "parent_id": userData!.parentId!,
                                };
                                // print(param);
                                leaveC.isLoading.value = true;
                                leaveC.getLeaveReq(param);
                                Get.to(
                                  () => RequestLeaveView(userData: userData!),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: StreamBuilder<NotifModel>(
                                  stream: homeC.getPendingApproval(
                                    idUser: userData!.id!,
                                    kodeCabang: userData!.kodeCabang!,
                                    level: userData!.level!,
                                    parentId: userData!.parentId!,
                                  ),
                                  builder: (context, snapshot) {
                                    return Stack(
                                      // alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Image.asset(
                                          'assets/image/req-leave.png',
                                          // width: 40,
                                          // height: 40,
                                        ),
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting)
                                          const Positioned(
                                            top: -2,
                                            right: -2,
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        else if (snapshot.hasError)
                                          const Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                          )
                                        else if (snapshot.hasData &&
                                            snapshot.data!.totalRequest! > 0)
                                          Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Badge(
                                              isLabelVisible: true,
                                              label: Text(
                                                snapshot.data!.totalRequest!
                                                    .toString(),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Text(
                              'Approval\n',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() {
                            leaveC.isLoading.value = true;
                            leaveC.getLeaveReq({
                              "type": "",
                              "id_user": userData!.id!,
                            });
                            return LeaveView(userData: userData!);
                          }, transition: Transition.cupertino);
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Image.asset(
                            'assets/image/leave.png',
                            // height: 40,
                            // width: 40,
                          ),
                        ),
                      ),

                      const Text(
                        'Leave\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),

                  const SizedBox(width: 18),
                  Visibility(
                    visible:
                        userData!.parentId == "3" || userData!.parentId == "4"
                            ? true
                            : false,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Get.to(() {
                                  adjCtrl.getReqAppUpt(
                                    '',
                                    '',
                                    userData!.level,
                                    userData!.id,
                                    adjCtrl.initDate,
                                    adjCtrl.lastDate,
                                  );
                                  return ReqAppUserView(userData: userData!);
                                }, transition: Transition.cupertino);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: StreamBuilder<NotifModel>(
                                  stream: adjCtrl.getAdjusmentData(
                                    idUser: userData!.id!,
                                    // level: userData!.level!,
                                  ),
                                  builder: (context, snapshot) {
                                    return Stack(
                                      // alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Image.asset(
                                          'assets/image/notif.png',
                                          // height: 40,
                                          // width: 40,
                                        ),
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting)
                                          const Positioned(
                                            top: -2,
                                            right: -2,
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        else if (snapshot.hasError)
                                          const Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                          )
                                        else if (snapshot.hasData &&
                                            snapshot.data!.totalNotif! > 0)
                                          Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Badge(
                                              isLabelVisible: true,
                                              label: Text(
                                                snapshot.data!.totalNotif!
                                                    .toString(),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),

                            const Text(
                              'Notification\n',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),

                  Visibility(
                    visible:
                        userData!.level == "1" || userData!.level == "26"
                            ? true
                            : false,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                Get.to(
                                  () =>
                                      MonitoringAbsenView(userData: userData!),
                                  transition: Transition.cupertino,
                                );
                                absC.searchAbsen.clear();
                                absC.userMonitor.value = "";
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Image.asset(
                                  'assets/image/monitoring.png',
                                  // height: 40,
                                  // width: 40,
                                ),
                              ),
                            ),
                            const Text(
                              'Monitoring\n',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: userData!.level == "1" ? true : false,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            adjCtrl.getReqAppUpt(
                              '',
                              '',
                              userData!.level,
                              userData!.id,
                              adjCtrl.initDate,
                              adjCtrl.lastDate,
                            );
                            Get.to(
                              () => AdjustPresenceView(data: userData!),
                              transition: Transition.cupertino,
                            );
                            absC.searchAbsen.clear();
                            absC.userMonitor.value = "";
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              'assets/image/adjust.png',
                              // width: 40,
                              // height: 40,
                            ),
                          ),
                        ),
                        const Text(
                          'Adjust\n',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
