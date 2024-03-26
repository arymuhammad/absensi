import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/modules/cek_stok/views/cek_stok_view.dart';
import 'package:absensi/app/modules/report_sales/controllers/report_sales_controller.dart';
import 'package:absensi/app/modules/report_sales/views/report_sales_view.dart';
import 'package:absensi/app/modules/semua_absen/views/monitoring_absen_view.dart';
import 'package:absensi/app/modules/semua_absen/views/search_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class CardInfoMenu extends GetView {
  CardInfoMenu({super.key, this.userData});
  final List? userData;
  final reportC = Get.put(ReportSalesController());

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Container(
        width: Get.mediaQuery.size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userData![4]}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('${userData![0]}'),
                      const SizedBox(height: 5),
                      Text(userData![2].toString().toUpperCase()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 1,
              child: Divider(
                thickness: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Visibility(
                      visible: userData![13] =="1"
                          ? true
                          : false,
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                Get.to(
                                    () => CekStokView(kodeCabang: userData![8]),
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
                    const SizedBox(
                      width: 12,
                    ),
                    Visibility(
                      visible: userData!.elementAt(9) == "1" ||
                              userData!.elementAt(9) == "9" ||
                              userData!.elementAt(9) == "10" ||
                              userData!.elementAt(9) == "26" ||
                              userData!.elementAt(9) == "50"
                          ? true
                          : false,
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                Get.to(() => ReportSalesView(),
                                    transition: Transition.cupertino);
                                loadingWithIcon();
                                await reportC.fetchSalesReport();
                                SmartDialog.dismiss();
                              },
                              icon: Icon(
                                FontAwesome.circle_dollar_to_slot_solid,
                                color: mainColor,
                                size: 30,
                              )),
                          const Text(
                            'Laporan\nSales',
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
                      visible: userData!.elementAt(9) == "1" ||
                              userData!.elementAt(9) == "26"
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
