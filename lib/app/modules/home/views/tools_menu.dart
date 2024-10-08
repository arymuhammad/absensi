import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/report_sales/controllers/report_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../data/helper/const.dart';
import '../../../data/model/login_model.dart';
import '../../adjust_presence/views/adjust_presence_view.dart';
import '../../cek_stok/views/cek_stok_view.dart';
import '../../semua_absen/views/monitoring_absen_view.dart';

class ToolsMenu extends StatelessWidget {
  final Data? userData;
  ToolsMenu({super.key, this.userData});

  final absC = Get.find<AbsenController>();
  final reportC = Get.put(ReportSalesController());

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
                    userData!.cekStok == "0"
                        ? const Text('Tidak ada menu yang tersedia')
                        : Container(),
                    Visibility(
                      visible: userData!.cekStok == "1" ? true : false,
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                Get.to(
                                    () => CekStokView(
                                        kodeCabang: userData!.kodeCabang),
                                    transition: Transition.cupertino);
                              },
                              icon: Icon(
                                // CupertinoIcons.doc_text_search,
                                FontAwesome.box_open_solid,
                                color: mainColor,
                                size: 30,
                              )),
                          const Text(
                            'Cek Stok\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    // const SizedBox(
                    //   width: 12,
                    // ),
                    // Visibility(
                    //   visible: userData!.level == "1" ||
                    //           userData!.level == "9" ||
                    //           userData!.level == "10" ||
                    //           userData!.level == "26" ||
                    //           userData!.level == "50"
                    //       ? true
                    //       : false,
                    //   child: Column(
                    //     children: [
                    //       IconButton(
                    //           onPressed: () async {
                    //             Get.to(() => ReportSalesView(),
                    //                 transition: Transition.cupertino);
                    //             loadingWithIcon();
                    //             await reportC.fetchSalesReport();
                    //             SmartDialog.dismiss();
                    //           },
                    //           icon: Icon(
                    //             FontAwesome.circle_dollar_to_slot_solid,
                    //             color: mainColor,
                    //             size: 30,
                    //           )),
                    //       const Text(
                    //         'Laporan\nSales',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //         textAlign: TextAlign.center,
                    //       )
                    //     ],
                    //   ),
                    // ),
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
                                Get.to(() => AdjustPresenceView(),
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
