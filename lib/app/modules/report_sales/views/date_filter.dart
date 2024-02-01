import 'package:absensi/app/helper/app_colors.dart';
import 'package:absensi/app/helper/loading_dialog.dart';
import 'package:absensi/app/modules/report_sales/controllers/report_sales_controller.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

final salesCtr = Get.put(ReportSalesController());

dateFilter() {
  Get.bottomSheet(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    elevation: 10,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DateTimeField(
                    controller: salesCtr.dateFiltered,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0.5),
                        prefixIcon: Icon(Iconsax.calendar),
                        hintText: 'Pilih Tanggal',
                        border: OutlineInputBorder()),
                    format: DateFormat("yyyy-MM-dd"),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: ElevatedButton(
                onPressed: () async {
                  salesCtr.sales.clear();
                  salesCtr.isLoading.value = true;
                  // salesCtr.hasMore.value = true;
                  // salesCtr.start.value = 0;
                  loadingWithIcon();
                  await salesCtr.salesReportFilter();
                  SmartDialog.dismiss();
                  Future.delayed(Duration.zero, () {
                    Get.back();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contentDefBtn,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    minimumSize: Size(Get.size.width / 2, 50)),
                child: const Text(
                  'CARI',
                  style: TextStyle(fontSize: 15, color: AppColors.mainTextColor1),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
