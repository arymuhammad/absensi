import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/model/login_model.dart';
import '../../../detail_absen/views/detail_absen_view.dart';

class ListItemData extends StatelessWidget {
  ListItemData({super.key, required this.data, required this.userData});
  final List<Absen> data;
  final Data userData;
  final absenC = Get.find<AbsenController>();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: data.length,
      itemBuilder: (c, i) {
        var absen = data[i];
        final absenDate = DateTime.parse(absen.tanggalMasuk!);

        final isSelected =
            absenC.selectedDate.value != null &&
            isSameDay(absenDate, absenC.selectedDate.value);
        var diffHours = const Duration();
        if (data.isNotEmpty && absen.jamAbsenPulang != "") {
          if (DateTime.parse(
            absen.tanggalPulang!,
          ).isAfter(DateTime.parse(absen.tanggalMasuk!))) {
            diffHours = DateTime.parse(
                  '${absen.tanggalMasuk!} ${absen.jamAbsenPulang!}',
                )
                .add(const Duration(hours: -1))
                .difference(
                  DateTime.parse(
                    '${absen.tanggalPulang!} ${absen.jamAbsenMasuk!}',
                  ),
                );
          } else {
            diffHours = DateTime.parse(
              '${absen.tanggalMasuk!} ${absen.jamAbsenPulang!}',
            ).difference(
              DateTime.parse('${absen.tanggalPulang!} ${absen.jamAbsenMasuk!}'),
            );
          }
        } else {
          diffHours = const Duration();
        }

        var stsMasuk =
            FormatWaktu.formatJamMenit(jamMenit: absen.jamAbsenMasuk!).isBefore(
                  FormatWaktu.formatJamMenit(jamMenit: absen.jamMasuk!),
                )
                ? "Early"
                : FormatWaktu.formatJamMenit(
                  jamMenit: absen.jamAbsenMasuk!,
                ).isAtSameMomentAs(
                  FormatWaktu.formatJamMenit(jamMenit: absen.jamMasuk!),
                )
                ? "On Time"
                : "Late";
        var stsPulang =
            absen.jamAbsenPulang! == ""
                ? "Absent"
                : DateTime.parse(
                      absen.tanggalPulang!,
                    ).isAfter(DateTime.parse(absen.tanggalMasuk!)) &&
                    FormatWaktu.formatJamMenit(
                      jamMenit: absen.jamAbsenPulang!,
                    ).isAfter(
                      FormatWaktu.formatJamMenit(
                        jamMenit: absen.jamAbsenMasuk!,
                      ).add(const Duration(hours: 8)),
                    )
                ? "Over Time"
                : DateTime.parse(
                      absen.tanggalPulang!,
                    ).isAtSameMomentAs(DateTime.parse(absen.tanggalMasuk!)) &&
                    FormatWaktu.formatJamMenit(
                      jamMenit: absen.jamAbsenPulang!,
                    ).isBefore(
                      FormatWaktu.formatJamMenit(jamMenit: absen.jamPulang!),
                    )
                ? "Early"
                : FormatWaktu.formatJamMenit(
                  jamMenit: absen.jamAbsenPulang!,
                ).isAtSameMomentAs(
                  FormatWaktu.formatJamMenit(jamMenit: absen.jamPulang!),
                )
                ? 'On Time'
                : "Over Time";

        return LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            return InkWell(
              onTap:
                  () => Get.to(() {
                    var detailData = {
                      "nama": absen.nama!,
                      "nama_shift": absen.namaShift!,
                      "id_user": absen.idUser!,
                      "tanggal_masuk": absen.tanggalMasuk!,
                      "tanggal_pulang":
                          absen.tanggalPulang != null
                              ? absen.tanggalPulang!
                              : "",
                      "jam_masuk": stsMasuk,
                      "jam_pulang": stsPulang,
                      "jam_absen_masuk": absen.jamAbsenMasuk!,
                      "jam_absen_pulang": absen.jamAbsenPulang!,
                      "foto_masuk": absen.fotoMasuk!,
                      "foto_pulang": absen.fotoPulang!,
                      "lat_masuk": absen.latMasuk!,
                      "long_masuk": absen.longMasuk!,
                      "lat_pulang": absen.latPulang!,
                      "long_pulang": absen.longPulang!,
                      "device_info": absen.devInfo!,
                      "device_info2": absen.devInfo2!,
                    };
                    return DetailAbsenView(detailData);
                  }, transition: Transition.cupertino),
              child: Container(
                width: maxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isSelected ? AppColors.itemsBackground : Colors.white,
                ),
                height: i == 0 && absenC.statsCon.value != "" ? 147 : 86,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: maxWidth * 0.15,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color:
                                  isSelected
                                      ? AppColors.contentColorWhite
                                      : AppColors.itemsBackground,
                            ),
                            child: Column(
                              children: [
                                // Tanggal
                                Text(
                                  FormatWaktu.formatTanggal(
                                    tanggal: absen.tanggalMasuk!,
                                  ),
                                  style: titleTextStyle.copyWith(
                                    fontSize: maxWidth * 0.06,
                                    color:
                                        isSelected
                                            ? AppColors.itemsBackground
                                            : AppColors.contentColorWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Hari
                                Text(
                                  FormatWaktu.formatHariEn(
                                    tanggal: absen.tanggalMasuk!,
                                  ),
                                  style: subtitleTextStyle.copyWith(
                                    color:
                                        isSelected
                                            ? AppColors.itemsBackground
                                            : AppColors.contentColorWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: maxWidth * 0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            absen.jamAbsenMasuk!,
                                            style: TextStyle(
                                              color:
                                                  stsMasuk == "Late"
                                                      ? red
                                                      : green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: maxWidth * 0.05,
                                            ),
                                          ),
                                          Text(
                                            'Check In',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  isSelected
                                                      ? AppColors
                                                          .contentColorWhite
                                                      : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      const VerticalDivider(
                                        color: Colors.grey, // Warna garis
                                        // thickness: 1, // Ketebalan garis
                                        width: 25, // Lebar box pembungkus
                                        // indent: 20, // Jarak dari atas
                                        endIndent: 5,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            absen.jamAbsenPulang!,
                                            style: TextStyle(
                                              color:
                                                  stsPulang == "Early" ||
                                                          stsPulang == "Absent"
                                                      ? red
                                                      : green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: maxWidth * 0.05,
                                            ),
                                          ),
                                          Text(
                                            'Check Out',
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? AppColors
                                                          .contentColorWhite
                                                      : Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      const VerticalDivider(
                                        color: Colors.grey, // Warna garis
                                        // thickness: 1, // Ketebalan garis
                                        width: 25, // Lebar box pembungkus
                                        // indent: 20, // Jarak dari atas
                                        endIndent: 5,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            data.isNotEmpty &&
                                                    absen.jamAbsenMasuk! != ""
                                                ? '${absen.jamAbsenPulang != "" ? diffHours.inHours % 24 : '-'}j${absen.jamAbsenPulang != "" ? diffHours.inMinutes % 60 : '-'}m'
                                                : '-:-',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color:
                                                  isSelected
                                                      ? AppColors
                                                          .contentColorWhite
                                                      : AppColors
                                                          .itemsBackground,
                                            ),
                                          ),
                                          Text(
                                            'Total Hours',
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? AppColors
                                                          .contentColorWhite
                                                      : Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppColors.contentColorWhite
                                            : AppColors.itemsBackground,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        HeroIcons.map_pin,
                                        size: 16,
                                        color:
                                            isSelected
                                                ? AppColors.itemsBackground
                                                : AppColors.contentColorWhite,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        absen.namaCabang!.capitalize!,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? AppColors.itemsBackground
                                                  : AppColors.contentColorWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      i == 0 && absenC.statsCon.value != ""
                          ? Container(
                            width: Get.mediaQuery.size.width,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(118, 255, 139, 128),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                absenC.statsCon.value,
                                style: TextStyle(color: Colors.redAccent[700]),
                              ),
                            ),
                          )
                          : Container(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
