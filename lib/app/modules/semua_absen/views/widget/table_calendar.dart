import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class WidgetTblCalendar extends StatelessWidget {
  WidgetTblCalendar({super.key, this.userData});

  final absenC = Get.find<AbsenController>();
  final Data? userData;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TableCalendar(
        locale: 'id_ID',
        calendarFormat: absenC.calendarFormat.value,
        onFormatChanged: (format) {
          absenC.calendarFormat.value = format;
          // print(format);
        },
        rangeSelectionMode: absenC.rangeSelectionMode.value,
        rangeStartDay: absenC.rangeStart.value,
        rangeEndDay: absenC.rangeEnd.value,
        headerStyle: HeaderStyle(
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(10),
            color: AppColors.contentColorOrange,
          ),
          formatButtonShowsNext: false,
        ),
        calendarStyle: const CalendarStyle(
          // Mengurangi margin sel; default biasanya sekitar EdgeInsets.all(6-8)
          cellMargin: EdgeInsets.all(
            2,
          ), // buat jarak antar tanggal lebih sempit
          // Jika ingin atur padding dalam cell:
          // cellPadding: EdgeInsets.all(4),
          tablePadding: EdgeInsets.all(1),
          weekendTextStyle: TextStyle(color: Colors.red),
          // opsional: atur ukuran teks supaya lebih ringkas
          todayDecoration: BoxDecoration(
            color: AppColors.itemsBackground,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        firstDay: DateTime.utc(2018, 1, 1),
        lastDay: DateTime.utc(2150, 12, 31),
        focusedDay: absenC.selectedDate.value ?? DateTime.now(),
        onRangeSelected: (start, end, focusedDay) async {
          absenC.rangeStart.value = start;
          absenC.rangeEnd.value = end;
          absenC.rangeSelectionMode.value = RangeSelectionMode.toggledOn;

          if (start != null && end != null) {
            // Saat range selesai dipilih, panggil API untuk fetch data antara start dan end
            if (absenC.searchAbsen.isEmpty) loadingDialog("Searching data", "");

            await absenC.getAllAbsen(
              userData!.id!,
              DateFormat('yyyy-MM-dd').format(start),
              DateFormat('yyyy-MM-dd').format(end),
            );

            if (absenC.searchAbsen.isEmpty) Get.back();
            // Optional: update tglStream ke end / start sesuai logika Anda
            absenC.tglStream.value = end;
            absenC.rangeSelectionMode.value = RangeSelectionMode.toggledOff;
       
          } else {
            absenC.rangeSelectionMode.value = RangeSelectionMode.toggledOff;
           
          }
        },
        selectedDayPredicate: (day) {
          return absenC.selectedDate.value != null &&
              isSameDay(absenC.selectedDate.value!, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          // Reset range selection saat user pilih tanggal tunggal
          absenC.rangeSelectionMode.value = RangeSelectionMode.toggledOff;
          absenC.rangeStart.value = null;
          absenC.rangeEnd.value = null;

          if (absenC.selectedDate.value != null &&
              isSameDay(absenC.selectedDate.value!, selectedDay)) {
            absenC.selectedDate.value =
                null; // reset pilihan ke semua data tampil
          } else {
            absenC.selectedDate.value = selectedDay;
          }

          if (absenC.tglStream.value.month != selectedDay.month ||
              absenC.tglStream.value.year != selectedDay.year) {
            loadingDialog("Searching data", "");
            await absenC.getAllAbsen(
              userData!.id!,
              DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  DateTime(selectedDay.year, selectedDay.month, 1).toString(),
                ),
              ),
              DateFormat('yyyy-MM-dd').format(
                DateTime.parse(
                  DateTime(
                    selectedDay.year,
                    selectedDay.month + 1,
                    0,
                  ).toString(),
                ),
              ),
            );
            Get.back();
          } else {
            // loadingDialog("Searching data", "");
            await absenC.getAllAbsen(
              userData!.id!,
              absenC.initDate1,
              absenC.initDate2,
            );
            // Get.back();
          }
        },
      ),
    );
  }
}
