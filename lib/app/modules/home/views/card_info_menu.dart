import 'package:absensi/app/helper/const.dart';
import 'package:absensi/app/helper/loading_dialog.dart';
import 'package:absensi/app/modules/cek_stok/views/cek_stok_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class CardInfoMenu extends GetView {
  const CardInfoMenu({super.key, this.userData});
  final List? userData;

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
              child: Row(
                children: [
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.to(() => CekStokView(kodeCabang: userData![8]),
                                transition: Transition.cupertino);
                          },
                          icon: Icon(
                            // CupertinoIcons.doc_text_search,
                            FontAwesome.box_open,
                            color: mainColor,
                            size: 30,
                          )),
                      const Text(
                        'Cek Stok',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            showToast('Dalam tahap pengembangan');
                            // Get.to(() => ReportSalesView(),
                            //     transition: Transition.cupertino);
                          },
                          icon: Icon(
                            FontAwesome.circle_dollar_to_slot,
                            color: mainColor,
                            size: 30,
                          )),
                      const Text(
                        'Laporan Sales',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
