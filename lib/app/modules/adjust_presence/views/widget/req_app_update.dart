import 'dart:io';
import 'dart:math' as math;
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_data_absen.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_masuk_pulang.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/helper/helper_ui.dart';
import '../../../../data/helper/loading_platform.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../login/controllers/login_controller.dart';
import 'upt_shift.dart';

class ReqAppUpdate extends GetView {
  ReqAppUpdate({super.key, required this.isInbox});
  final bool isInbox;
  final auth = Get.find<LoginController>();
  final homeC = Get.find<HomeController>();
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    final dataUser = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
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

          Expanded(
            child: Obx(() {
              final keyword = homeC.search.value.toLowerCase();
              final filteredList =
                  adjCtrl.listReqUpt.where((exc) {
                    return (exc.nama).toLowerCase().contains(keyword) ||
                        (exc.idUser).toLowerCase().contains(keyword) ||
                        (exc.namaCabang).toLowerCase().contains(keyword);
                  }).toList();

              if (adjCtrl.isLoading.value) {
                return Center(child: platFormDevice());
              }
              if (filteredList.isEmpty) {
                return CustomMaterialIndicator(
                  onRefresh: () async {
                    adjCtrl.selectedType.value = "";

                    await adjCtrl.getReqAppUpt(
                      '',
                      '',
                      dataUser.level,
                      dataUser.id,
                      dataUser.kodeCabang,
                      adjCtrl.dateInput1.text != ""
                          ? adjCtrl.dateInput1.text
                          : adjCtrl.initDate,
                      adjCtrl.dateInput2.text != ""
                          ? adjCtrl.dateInput2.text
                          : adjCtrl.lastDate,
                    );
                  },
                  backgroundColor: Colors.white,
                  indicatorBuilder: (context, controller) {
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child:
                          Platform.isAndroid
                              ? CircularProgressIndicator(
                                color: AppColors.itemsBackground,
                                value:
                                    controller.state.isLoading
                                        ? null
                                        : math.min(controller.value, 1.0),
                              )
                              : const CupertinoActivityIndicator(),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      const Icon(Icons.inbox, size: 50, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text('No Request Exceptions Occurred'),
                      ),
                    ],
                  ),
                );
              }

              return adjCtrl.isLoading.value
                  ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Memuat data...'),
                      SizedBox(width: 10),
                      CircularProgressIndicator(),
                    ],
                  )
                  : adjCtrl.listReqUpt.isEmpty
                  ? CustomMaterialIndicator(
                    onRefresh: () async {
                      adjCtrl.isLoading.value = true;
                      adjCtrl.selectedType.value = "";
                      // adjCtrl.selectedStatus.value = "";
                      await adjCtrl.getReqAppUpt(
                        '',
                        '',
                        dataUser.level,
                        dataUser.id,
                        dataUser.kodeCabang,
                        adjCtrl.dateInput1.text != ""
                            ? adjCtrl.dateInput1.text
                            : adjCtrl.initDate,
                        adjCtrl.dateInput2.text != ""
                            ? adjCtrl.dateInput2.text
                            : adjCtrl.lastDate,
                      );

                      // return Future.delayed(Duration.zero, () {
                      //   showToast("Page Refreshed");
                      // });
                    },
                    backgroundColor: Colors.white,
                    indicatorBuilder: (context, controller) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child:
                            Platform.isAndroid
                                ? CircularProgressIndicator(
                                  color: AppColors.itemsBackground,
                                  value:
                                      controller.state.isLoading
                                          ? null
                                          : math.min(controller.value, 1.0),
                                )
                                : const CupertinoActivityIndicator(),
                      );
                    },
                    child: ListView(
                      children: const [Center(child: Text('Tidak ada data'))],
                    ),
                  )
                  : CustomMaterialIndicator(
                    onRefresh: () async {
                      adjCtrl.selectedType.value = "";
                      // adjCtrl.selectedStatus.value = "";
                      await adjCtrl.getReqAppUpt(
                        '',
                        'inbox',
                        dataUser.level,
                        dataUser.id,
                        dataUser.kodeCabang,
                        adjCtrl.dateInput1.text != ""
                            ? adjCtrl.dateInput1.text
                            : adjCtrl.initDate,
                        adjCtrl.dateInput2.text != ""
                            ? adjCtrl.dateInput2.text
                            : adjCtrl.lastDate,
                      );

                      // adjCtrl.isLoading.value = true;

                      // return Future.delayed(Duration.zero, () {
                      //   showToast("Page Refreshed");
                      // });
                    },
                    backgroundColor: Colors.white,
                    indicatorBuilder: (context, controller) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child:
                            Platform.isAndroid
                                ? CircularProgressIndicator(
                                  color: AppColors.itemsBackground,
                                  value:
                                      controller.state.isLoading
                                          ? null
                                          : math.min(controller.value, 1.0),
                                )
                                : const CupertinoActivityIndicator(),
                      );
                    },
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ExpansionTileGroup(
                          toggleType: ToggleType.expandOnlyCurrent,
                          spaceBetweenItem: 5,
                          children: List.generate(filteredList.length, (i) {
                            final excData = filteredList[i];
                            final status = excData.statusExcep ?? 'pending';
                            final color = getStatusColor(status);

                            return ExpansionTileItem(
                              key: Key(
                                'adjust_tile_$i',
                              ), // key unik per item penting!
                              tilePadding: const EdgeInsets.fromLTRB(
                                2,
                                2,
                                2,
                                2,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                8,
                                2,
                                8,
                                2,
                              ),
                              isHasBottomBorder: true,
                              isHasTopBorder: true,
                              isHasLeftBorder: true,
                              isHasRightBorder: true,
                              // collapsedBackgroundColor:
                              //     excData.isRead == "" && excData.accept != ""
                              //         ? Colors.blue[200]
                              //         : isDark
                              //         ? Theme.of(context).canvasColor
                              //         : Colors.white,
                              // onExpansionChanged: (value) {
                              //   // print(value);
                              //   if (excData.accept != "" && excData.isRead == "") {
                              //     adjCtrl.updateStatIsReadNotif(
                              //       id: excData.id,
                              //       idUser: excData.idUser,
                              //     );
                              //     Future.delayed(
                              //       const Duration(seconds: 3),
                              //       () async {
                              //         await adjCtrl.getReqAppUpt(
                              //           '',
                              //           '',
                              //           dataUser.level,
                              //           dataUser.id,
                              //           adjCtrl.dateInput1.text != ""
                              //               ? adjCtrl.dateInput1.text
                              //               : adjCtrl.initDate,
                              //           adjCtrl.dateInput2.text != ""
                              //               ? adjCtrl.dateInput2.text
                              //               : adjCtrl.lastDate,
                              //         );
                              //       },
                              //     );
                              //   } else {
                              //     null;
                              //   }
                              // },
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),

                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const SizedBox(height: 5),
                                  Text(
                                    excData.nama,
                                    style: titleTextStyle.copyWith(
                                      color:
                                          isDark
                                              ? Colors.grey[600]
                                              : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    excData.namaCabang,
                                    style: subtitleTextStyle,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.calendar_1_outline,
                                        color:
                                            isDark
                                                ? Colors.grey[600]
                                                : AppColors.itemsBackground,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        FormatWaktu.formatIndo(
                                          tanggal: DateTime.parse(
                                            excData.tglMasuk,
                                          ),
                                        ),
                                        style: subtitleTextStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      excData.statusExcep == "pending"
                                          ? Colors.amber.withOpacity(.1)
                                          : excData.statusExcep == "approved"
                                          ? Colors.green.withOpacity(.1)
                                          : red!.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  excData.statusExcep!.toUpperCase(),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // border: Border.all(),
                              children: [
                                excData.status == "update_masuk" ||
                                        excData.status == "update_masuk_cst" ||
                                        excData.status == "update_pulang"
                                    ? UptMasukPulang(data: excData, isInbox:false)
                                    : excData.status == "update_data_absen"
                                    ? UptDataAbsen(data: excData, isInbox: false,)
                                    : UptShift(data: excData, isInbox:false),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  );
            }),
          ),
        ],
      ),
    );
  }
}
