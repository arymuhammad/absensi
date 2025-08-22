import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_data_absen.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_masuk_pulang.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/model/login_model.dart';
import 'upt_shift.dart';

class ReqAppUpdate extends GetView {
  ReqAppUpdate({super.key, required this.dataUser});
  final Data dataUser;
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.task_outline,
                color: AppColors.contentColorBlue,
              ),
              const SizedBox(width: 5),
              Text(
                'Data Adjusment List',
                style: titleTextStyle.copyWith(fontSize: 16),
              ),
            ],
          ),

          const Divider(thickness: 2),
          // SizedBox(
          //   height: 30,
          //   child: Marquee(
          //     text:
          //         'Selalu periksa pengajuan edit data absen pada bagian status Accept / Reject',
          //     style: const TextStyle(fontWeight: FontWeight.bold),
          //     scrollAxis: Axis.horizontal,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     blankSpace: 20.0,
          //     velocity: 50.0,
          //     pauseAfterRound: const Duration(seconds: 1),
          //     startPadding: 10.0,
          //     accelerationDuration: const Duration(seconds: 1),
          //     accelerationCurve: Curves.linear,
          //     decelerationDuration: const Duration(milliseconds: 500),
          //     decelerationCurve: Curves.easeOut,
          //   ),
          // ),
          Expanded(
            child: Obx(
              () =>
                  adjCtrl.isLoading.value
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Memuat data...'),
                          SizedBox(width: 10),
                          CircularProgressIndicator(),
                        ],
                      )
                      : adjCtrl.listReqUpt.isEmpty
                      ? RefreshIndicator(
                        onRefresh: () async {
                          adjCtrl.isLoading.value = true;
                          adjCtrl.selectedType.value = "";
                          // adjCtrl.selectedStatus.value = "";
                          await adjCtrl.getReqAppUpt(
                            '',
                            '',
                            dataUser.level,
                            dataUser.id,
                            adjCtrl.dateInput1.text != ""
                                ? adjCtrl.dateInput1.text
                                : adjCtrl.initDate,
                            adjCtrl.dateInput2.text != ""
                                ? adjCtrl.dateInput2.text
                                : adjCtrl.lastDate,
                          );
                          return Future.delayed(Duration.zero, () {
                            showToast("Page Refreshed");
                          });
                        },
                        child: ListView(
                          children: const [
                            Center(child: Text('Tidak ada data')),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: () async {
                          // adjCtrl.isLoading.value = true;
                          adjCtrl.selectedType.value = "";
                          // adjCtrl.selectedStatus.value = "";
                          await adjCtrl.getReqAppUpt(
                            '',
                            '',
                            dataUser.level,
                            dataUser.id,
                            adjCtrl.dateInput1.text != ""
                                ? adjCtrl.dateInput1.text
                                : adjCtrl.initDate,
                            adjCtrl.dateInput2.text != ""
                                ? adjCtrl.dateInput2.text
                                : adjCtrl.lastDate,
                          );
                          return Future.delayed(Duration.zero, () {
                            showToast("Page Refreshed");
                          });
                        },
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ExpansionTileGroup(
                              toggleType: ToggleType.expandOnlyCurrent,
                              spaceBetweenItem: 10,
                              children: [
                                for (var i in adjCtrl.listReqUpt)
                                  ExpansionTileItem(
                                    tilePadding: const EdgeInsets.fromLTRB(
                                      2,
                                      2,
                                      2,
                                      2,
                                    ),
                                    childrenPadding: const EdgeInsets.fromLTRB(
                                      2,
                                      2,
                                      2,
                                      2,
                                    ),
                                    isHasBottomBorder: true,
                                    isHasTopBorder: true,
                                    isHasLeftBorder: true,
                                    isHasRightBorder: true,
                                    collapsedBackgroundColor:
                                        i.isRead == "" && i.accept != ""
                                            ? Colors.blue[200]
                                            : Colors.white,
                                    onExpansionChanged: (value) {
                                      // print(value);
                                      if (i.accept != "" && i.isRead == "") {
                                        adjCtrl.updateStatIsReadNotif(
                                          id: i.id,
                                          idUser: i.idUser,
                                        );
                                        Future.delayed(
                                          const Duration(seconds: 3),
                                          () async {
                                            await adjCtrl.getReqAppUpt(
                                              '',
                                              '',
                                              dataUser.level,
                                              dataUser.id,
                                              adjCtrl.dateInput1.text != ""
                                                  ? adjCtrl.dateInput1.text
                                                  : adjCtrl.initDate,
                                              adjCtrl.dateInput2.text != ""
                                                  ? adjCtrl.dateInput2.text
                                                  : adjCtrl.lastDate,
                                            );
                                          },
                                        );
                                      } else {
                                        null;
                                      }
                                    },
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5),
                                    ),

                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                i.accept == ""
                                                    ? Colors.amber
                                                    : i.accept == "1"
                                                    ? Colors.green
                                                    : Colors.grey,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  bottomRight: Radius.circular(
                                                    20,
                                                  ),
                                                ),
                                          ),
                                          child: Text(
                                            i.accept == ""
                                                ? 'Pending'
                                                : i.accept == "1"
                                                ? 'Approved'
                                                : 'Canceled',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(height: 5),
                                        Text(i.nama, style: titleTextStyle),
                                        Text(
                                          i.idUser,
                                          style: subtitleTextStyle,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Iconsax.calendar_1_outline,
                                              color: AppColors.itemsBackground,
                                              size: 15,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              FormatWaktu.formatIndo(
                                                tanggal: DateTime.parse(
                                                  i.tglMasuk,
                                                ),
                                              ),
                                              style: subtitleTextStyle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // border: Border.all(),
                                    children: [
                                      i.status == "update_masuk" ||
                                              i.status == "update_pulang"
                                          ? UptMasukPulang(
                                            data: i,
                                            dataUser: dataUser,
                                          )
                                          : i.status == "update_data_absen"
                                          ? UptDataAbsen(
                                            data: i,
                                            dataUser: dataUser,
                                          )
                                          : UptShift(
                                            data: i,
                                            dataUser: dataUser,
                                          ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
