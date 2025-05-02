import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/home/views/req_app_user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../data/helper/const.dart';
import '../../../data/model/login_model.dart';
import '../../adjust_presence/views/adjust_presence_view.dart';
import '../../semua_absen/views/monitoring_absen_view.dart';

class ToolsMenu extends StatelessWidget {
  final Data? userData;
  ToolsMenu({super.key, this.userData});

  final absC = Get.find<AbsenController>();
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: Get.mediaQuery.size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Iconsax.menu_board_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    ' Tools Menu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Divider(
                thickness: 1,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                            onPressed: () {
                              adjCtrl.getReqAppUpt(
                                  '',
                                  '',
                                  userData!.level,
                                  userData!.id,
                                  adjCtrl.initDate,
                                  adjCtrl.lastDate);
                              Get.to(
                                  () => ReqAppUserView(
                                        userData: userData!,
                                      ),
                                  transition: Transition.cupertino);
                            },
                            icon: Icon(
                              // CupertinoIcons.doc_text_search,
                              Iconsax.sms_notification_outline,
                              color: mainColor,
                              size: 30,
                            )),
                        const Text(
                          'Notification',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Visibility(
                      visible: userData!.level == "1" || userData!.level == "26"
                          ? true
                          : false,
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                Get.to(() => MonitoringAbsenView(),
                                    transition: Transition.cupertino);
                                absC.searchAbsen.clear();
                                absC.userMonitor.value = "";
                              },
                              icon: Icon(
                                FontAwesome.user_tie_solid,
                                color: mainColor,
                                size: 30,
                              )),
                          const Text(
                            'Monitor\nAbsensi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Visibility(
                      visible: userData!.level == "1" ? true : false,
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                adjCtrl.getReqAppUpt(
                                    '',
                                    '',
                                    userData!.level,
                                    userData!.id,
                                    adjCtrl.initDate,
                                    adjCtrl.lastDate);
                                Get.to(
                                    () => AdjustPresenceView(data: userData!),
                                    transition: Transition.cupertino);
                                absC.searchAbsen.clear();
                                absC.userMonitor.value = "";
                              },
                              icon: Icon(
                                FontAwesome.clock_rotate_left_solid,
                                color: mainColor,
                                size: 30,
                              )),
                          const Text(
                            'Penyesuaian\nAbsensi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
