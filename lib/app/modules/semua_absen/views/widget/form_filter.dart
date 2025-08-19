import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../../../data/helper/app_colors.dart';

final absenC = Get.find<AbsenController>();

void formFilter(idUser) {
  Get.bottomSheet(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    elevation: 10,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    SizedBox(
      height: 185,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cari Data Absensi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DateTimeField(
                    controller: absenC.date1,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0.5),
                      prefixIcon: Icon(Iconsax.calendar_edit_outline),
                      hintText: 'Tanggal Awal',
                      border: OutlineInputBorder(),
                    ),
                    format: DateFormat("yyyy-MM-dd"),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DateTimeField(
                    controller: absenC.date2,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0.5),
                      prefixIcon: Icon(Iconsax.calendar_edit_outline),
                      hintText: 'Tanggal Akhir',
                      border: OutlineInputBorder(),
                    ),
                    format: DateFormat("yyyy-MM-dd"),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
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
                  // await absenC.getFilteredAbsen(idUser);
                  absenC.date1.clear();
                  absenC.date2.clear();
                  //  Restart.restartApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contentDefBtn,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: Size(Get.size.width / 2, 50),
                ),
                child: const Text(
                  'CARI',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.mainTextColor1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
