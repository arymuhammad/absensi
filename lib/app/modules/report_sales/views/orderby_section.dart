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
        print(salesCtr.isSortGt.value);
        if (salesCtr.isSortGt.value == false) {
          print('desc');
          salesCtr.isSortGt.value = true;
          salesCtr.isSortQty.value = false;
          salesCtr.searchCab
              .sort((a, b) => b.salesAmount!.compareTo(a.salesAmount!));
        } else {
          print('asc');
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
        // Get.defaultDialog(
        //   barrierDismissible: false,
        //   radius: 5,
        //   title: 'Peringatan',
        //   content: Column(
        //     children: [
        //       const Text('Anda yakin ingin Logout?'),
        //       const SizedBox(
        //         height: 20,
        //       ),
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         children: [
        //           ElevatedButton(
        //               onPressed: () async {
        //                 // SharedPreferences pref =
        //                 //     await SharedPreferences.getInstance();
        //                 // await pref.remove("kode");
        //                 // await pref.setBool("is_login", false);
        //                 // loginC.isLogin.value = false;
        //                 // loginC.isLoading.value = false;

        //                 // Fluttertoast.showToast(
        //                 //     msg: "Sukses, Anda berhasil Logout.",
        //                 //     toastLength: Toast.LENGTH_SHORT,
        //                 //     gravity: ToastGravity.BOTTOM,
        //                 //     timeInSecForIosWeb: 1,
        //                 //     backgroundColor:
        //                 //         Colors.greenAccent[700],
        //                 //     textColor: Colors.white,
        //                 //     fontSize: 16.0);
        //                 // Get.back();
        //                 // Get.back();
        //                 // Get.back();
        //               },
        //               child: const Text('Ya')),
        //           ElevatedButton(
        //               onPressed: () {
        //                 // Get.back();
        //               },
        //               child: const Text('Tidak')),
        //         ],
        //       ),
        //     ],
        //   ),
        // );
      }
    },
  );
}
