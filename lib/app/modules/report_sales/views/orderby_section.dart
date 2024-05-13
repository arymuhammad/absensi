import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget sortBySection() {
  return PopupMenuButton<int>(
    itemBuilder: (context) => [
      // PopupMenuItem 1
      PopupMenuItem(
        onTap: null,
        value: 1,
        // row with 2 children
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.print_rounded, color: Colors.black),
                SizedBox(
                  width: 10,
                ),
                Text("Urut per Grand Total"),
              ],
            ),
            Obx(() => Visibility(
                visible: salesCtr.isSortGt.value ? true : false,
                child: const Icon(Icons.check_rounded)))
          ],
        ),
      ),
      // PopupMenuItem 2
      PopupMenuItem(
        value: 2,
        // row with two children
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.print_rounded, color: Colors.black),
                SizedBox(
                  width: 10,
                ),
                Text("Urut per Qty"),
              ],
            ),
            Obx(() => Visibility(
                visible: salesCtr.isSortQty.value ? true : false,
                child: const Icon(Icons.check_rounded)))
          ],
        ),
      ),
    ],
    offset: const Offset(0, 1),
    // color: Colors.white,
    elevation: 2,
    // on selected we show the dialog box
    onSelected: (value) {
      // if value 1 show dialog
      if (value == 1) {

        if (salesCtr.isSortGt.value == false) {

          salesCtr.isSortGt.value = true;
          salesCtr.isSortQty.value = false;
          salesCtr.searchCab
              .sort((a, b) => b.salesAmount!.compareTo(a.salesAmount!));
        } else {

          salesCtr.isSortGt.value = false;
          salesCtr.isSortQty.value = false;
          salesCtr.searchCab
              .sort((a, b) => a.salesAmount!.compareTo(b.salesAmount!));
        }
      } else if (value == 2) {
        if (salesCtr.isSortQty.value == false) {
          salesCtr.isSortQty.value = true;
          salesCtr.isSortGt.value = false;
          salesCtr.searchCab.sort((a, b) => a.sales!.compareTo(b.sales!));
        } else {
          salesCtr.isSortQty.value = false;
          salesCtr.isSortGt.value = false;
          salesCtr.searchCab.sort((a, b) => b.sales!.compareTo(a.sales!));
        }
      } else if (value == 3) {

      }
    },
  );
}
