import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_data_absen.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_masuk_pulang.dart';
import 'package:absensi/app/modules/shared/dropdown.dart';
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
              Expanded(
                  child: SizedBox(
                height: 50,
                child: Obx(
                  () => CsDropDown(
                    value: adjCtrl.selectedStatus.isNotEmpty
                        ? adjCtrl.selectedStatus.value
                        : null,
                    items: adjCtrl.statusReqApp.map((e) {
                      return DropdownMenuItem(
                        value: e.entries.first.key,
                        child: Text(e.entries.first.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      adjCtrl.isLoading.value = true;
                      adjCtrl.selectedStatus.value = val;
                      adjCtrl.getReqAppUpt(val, adjCtrl.selectedType.value, dataUser.level, dataUser.id);
                    },
                    label: 'Status',
                  ),
                ),
              )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: SizedBox(
                height: 50,
                child: Obx(
                  () => CsDropDown(
                    value: adjCtrl.selectedType.isNotEmpty
                        ? adjCtrl.selectedType.value
                        : null,
                    items: adjCtrl.typeReqApp.map((e) {
                      return DropdownMenuItem(
                        value: e.entries.first.key,
                        child: Text(e.entries.first.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      adjCtrl.isLoading.value = true;
                      adjCtrl.selectedType.value = val;
                      adjCtrl.getReqAppUpt(adjCtrl.selectedStatus.value, val, dataUser.level, dataUser.id);
                    },
                    label: 'Kategori',
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Obx(() => Row(
                children: [
                  Text(
                    adjCtrl.selectedStatus.isNotEmpty
                        ? adjCtrl.selectedStatus.value == "0"
                            ? "Rejected List"
                            : "Accepted List"
                        : 'Unconfirmed List',
                    style: titleTextStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    adjCtrl.selectedStatus.isNotEmpty
                        ? adjCtrl.selectedStatus.value == "0"
                            ? Iconsax.note_remove_bold
                            : Iconsax.tick_circle_bold
                        : Iconsax.warning_2_bold,
                    color: adjCtrl.selectedStatus.isNotEmpty
                        ? adjCtrl.selectedStatus.value == "0"
                            ? red
                            : green
                        : Colors.yellow[900],
                  )
                ],
              )),
          const Divider(
            thickness: 2,
          ),
          Expanded(
            child: Obx(
              () => adjCtrl.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : adjCtrl.listReqUpt.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data'),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            // adjCtrl.isLoading.value = true;
                            adjCtrl.selectedType.value = "";
                            adjCtrl.selectedStatus.value = "";
                            await adjCtrl.getReqAppUpt('', '', dataUser.level, dataUser.id);
                            return Future.delayed(const Duration(seconds: 1),
                                () {
                              showToast("Page Refreshed");
                            });
                          },
                          child: ListView(padding: EdgeInsets.zero, children: [
                            ExpansionTileGroup(
                              toggleType: ToggleType.expandOnlyCurrent,
                              spaceBetweenItem: 10,
                              children: [
                                for (var i in adjCtrl.listReqUpt)
                                  ExpansionTileItem(
                                    title: Text(
                                      i.nama,
                                      style: titleTextStyle,
                                    ),
                                    subtitle: Text(
                                      i.idUser,
                                      style: subtitleTextStyle,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text('Tanggal Masuk', style: titleTextStyle,),
                                        Text(FormatWaktu.formatIndo(
                                            tanggal:
                                                DateTime.parse(i.tglMasuk)), style: subtitleTextStyle,),
                                      ],
                                    ),
                                    border: Border.all(),
                                    isHasBottomBorder: true,
                                    isHasTopBorder: true,
                                    isHasLeftBorder: true,
                                    isHasRightBorder: true,
                                    backgroundColor: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    children: [
                                      i.status == "update_masuk" ||
                                              i.status == "update_pulang"
                                          ? UptMasukPulang(
                                              data: i, dataUser: dataUser)
                                          : i.status == "update_data_absen"
                                              ? UptDataAbsen(
                                                  data: i, dataUser: dataUser)
                                              : UptShift(
                                                  data: i, dataUser: dataUser),
                                    ],
                                  ),
                              ],
                            )
                          ])),
            ),
          )
        ],
      ),
    );
  }
}
