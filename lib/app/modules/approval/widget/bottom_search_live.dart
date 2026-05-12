import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/login_model.dart';
import '../../leave/controllers/leave_controller.dart';
import '../../shared/dropdown.dart';
import '../../shared/elevated_button_icon.dart';

bottomSearchLive(
  BuildContext context,
  bool isDark,
  Data userData,
  LeaveController ctrl,
) {
  Get.bottomSheet(
    backgroundColor: isDark ? Colors.black : Colors.white,
    SingleChildScrollView(
      child: Container(
        // Atur tinggi sesuai kebutuhan, misal 400
        height: 250,
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Cari Data',
                style: titleTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Divider(),
              Obx(
                () => 
                // Row(
                  // children: [
                    SizedBox(
                      height: 44,
                      child: CsDropDown(
                        value:
                            ctrl.selectedStatus.isNotEmpty
                                ? ctrl.selectedStatus.value
                                : null,
                        items:
                            ctrl.statusReqLeave.map((e) {
                              return DropdownMenuItem(
                                value: e.entries.first.key,
                                child: Text(e.entries.first.value),
                              );
                            }).toList(),
                        onChanged: (val) {
                          // adjCtrl.isLoading.value = true;
                          ctrl.selectedStatus.value = val;
                          // adjCtrl.getReqAppUpt(
                          //     val,
                          //     adjCtrl.selectedType.value,
                          //     userData!.level,
                          //     userData!.id,
                          //     adjCtrl.initDate,
                          //     adjCtrl.lastDate);
                        },
                        label: 'Status',
                        isDark: isDark,
                      ),
                    ),
                    // const SizedBox(width: 5),
                    // Expanded(
                    //   child: SizedBox(
                    //     height: 44,
                    //     child: CsDropDown(
                    //       value:
                    //           ctrl.selectedType.isNotEmpty
                    //               ? ctrl.selectedType.value
                    //               : null,
                    //       items:
                    //           ctrl.typeReqApp.map((e) {
                    //             return DropdownMenuItem(
                    //               value: e.entries.first.key,
                    //               child: Text(e.entries.first.value),
                    //             );
                    //           }).toList(),
                    //       onChanged: (val) {
                    //         // ctrl.isLoading.value = true;
                    //         ctrl.selectedType.value = val;
                    //         // ctrl.getReqAppUpt(
                    //         //     ctrl.selectedStatus.value,
                    //         //     val,
                    //         //     userData!.level,
                    //         //     userData!.id,
                    //         //     ctrl.initDate,
                    //         //     ctrl.lastDate);
                    //       },
                    //       label: 'Kategori',
                    //       isDark: isDark,
                    //     ),
                    //   ),
                    // ),
                  // ],
                // ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: DateTimeField(
                        controller: ctrl.datePick1,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0.5),
                          prefixIcon: const Icon(Iconsax.calendar_edit_outline),
                          hintText: 'Tanggal Awal',
                          filled: true,
                          fillColor: isDark ? Colors.black : Colors.white,
                          border: const OutlineInputBorder(),
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
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: DateTimeField(
                        controller: ctrl.datePick2,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0.5),
                          prefixIcon: const Icon(Iconsax.calendar_edit_outline),
                          hintText: 'Tanggal Akhir',
                          filled: true,
                          fillColor: isDark ? Colors.black : Colors.white,
                          border: const OutlineInputBorder(),
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
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CsElevatedButtonIcon(
                    icon: const Icon(Icons.undo_sharp),
                    fontSize: 14,
                    label: 'Batal',
                    backgroundColor: red,
                    onPressed: () {
                      Get.back();
                      ctrl.datePick1.clear();
                      ctrl.datePick2.clear();
                      ctrl.selectedStatus.value = "";
                      // ctrl.selectedType.value = "";
                    },
                  ),
                  const SizedBox(width: 5),
                  CsElevatedButtonIcon(
                    backgroundColor: AppColors.itemsBackground,
                    icon: const Icon(Icons.save_as_rounded),
                    fontSize: 14,
                    label: 'Cari',
                    onPressed: () {
                      if (ctrl.datePick1.text.isEmpty ||
                          ctrl.datePick2.text.isEmpty) {
                        showToast(
                          'Harap pilih tanggal data adjusment terlebih dahulu',
                        );
                      } else {
                        var tglA = DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.parse(ctrl.datePick1.text));
                        var tglB = DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.parse(ctrl.datePick2.text));

                        if (DateTime.parse(
                          tglA,
                        ).isAfter(DateTime.parse(tglB))) {
                          Get.back();
                          failedDialog(
                            context,
                            'ERROR',
                            'Rentang tanggal yang Anda masukkan salah',
                          );
                        } else {
                          Get.back();
                          Future.delayed(
                            const Duration(milliseconds: 300),
                            () async {
                              ctrl.listLeaveReq.clear();
                              ctrl.isLoading.value = true;
                              // ctrl.selectedType.value = val;
                              var param = {
                                "type": "get_pending_req_leave",
                                "accept": ctrl.selectedStatus.value,
                                "kode_cabang": userData.kodeCabang!,
                                "id_user": userData.id!,
                                "level": userData.level!,
                                "parent_id": userData.parentId!,
                                "date1": ctrl.datePick1.text,
                                "date2": ctrl.datePick2.text,
                              };
                              // print(param);
                              await ctrl.getLeaveReq(param);

                              ctrl.datePick1.clear();
                              ctrl.datePick2.clear();
                              ctrl.selectedStatus.value = "";
                              // ctrl.selectedType.value = "";
                            },
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
