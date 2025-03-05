import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_data_absen.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/upt_masuk_pulang.dart';
import 'package:absensi/app/modules/shared/dropdown.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'upt_shift.dart';

class ReqAppUpdate extends GetView {
  ReqAppUpdate({super.key});
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 8.0),
      child: Column(
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
                      adjCtrl.getReqAppUpt(val, adjCtrl.selectedType.value);
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
                      adjCtrl.getReqAppUpt(adjCtrl.selectedStatus.value, val);
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
                          onRefresh: () {
                            // adjCtrl.isLoading.value = true;
                            adjCtrl.selectedType.value = "";
                            adjCtrl.selectedStatus.value = "";
                            return adjCtrl.getReqAppUpt('', '');
                          },
                          child: ListView(children: [
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
                                          ? UptMasukPulang(data: i)
                                          : i.status == "update_data_absen"
                                              ? UptDataAbsen(data: i)
                                              : UptShift(data: i),
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
