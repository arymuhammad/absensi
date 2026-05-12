import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/const.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/login_model.dart';
import '../../adjust_presence/controllers/adjust_presence_controller.dart';
import '../../adjust_presence/views/widget/req_app_update.dart';
import '../../login/controllers/login_controller.dart';
import '../../shared/container_main_color.dart';
import '../../shared/dropdown.dart';
import '../../shared/elevated_button_icon.dart';

class ReqPresenceExcepView extends StatelessWidget {
  ReqPresenceExcepView({super.key});
  final auth = Get.find<LoginController>();
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    final userData = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8, 8),
            child: Card(
              // color: isDark ? Theme.of(context).canvasColor : Colors.white,
              child: Container(
                // height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: isDark ? Theme.of(context).canvasColor : Colors.white,
                ),
                child: ReqAppUpdate(isInbox: false),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder:
            (context) => ContainerMainColor(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              radius: 30,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                onPressed: () {
                  dialogSearchData(context, isDark, userData);
                },
                child: Icon(
                  Icons.manage_search_outlined,
                  color: isDark ? Colors.blue : Colors.white,
                ),
              ),
            ),
      ),
    );
  }

  dialogSearchData(BuildContext context, bool isDark, Data userData) {
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
                  () => Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: CsDropDown(
                            value:
                                adjCtrl.selectedStatus.isNotEmpty
                                    ? adjCtrl.selectedStatus.value
                                    : null,
                            items:
                                adjCtrl.statusReqApp.map((e) {
                                  return DropdownMenuItem(
                                    value: e.entries.first.key,
                                    child: Text(e.entries.first.value),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              // adjCtrl.isLoading.value = true;
                              adjCtrl.selectedStatus.value = val;
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
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: CsDropDown(
                            value:
                                adjCtrl.selectedType.isNotEmpty
                                    ? adjCtrl.selectedType.value
                                    : null,
                            items:
                                adjCtrl.typeReqApp.map((e) {
                                  return DropdownMenuItem(
                                    value: e.entries.first.key,
                                    child: Text(e.entries.first.value),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              // adjCtrl.isLoading.value = true;
                              adjCtrl.selectedType.value = val;
                              // adjCtrl.getReqAppUpt(
                              //     adjCtrl.selectedStatus.value,
                              //     val,
                              //     userData!.level,
                              //     userData!.id,
                              //     adjCtrl.initDate,
                              //     adjCtrl.lastDate);
                            },
                            label: 'Kategori',
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: DateTimeField(
                          controller: adjCtrl.dateInput1,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0.5),
                            prefixIcon: const Icon(
                              Iconsax.calendar_edit_outline,
                            ),
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
                          controller: adjCtrl.dateInput2,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0.5),
                            prefixIcon: const Icon(
                              Iconsax.calendar_edit_outline,
                            ),
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
                        adjCtrl.dateInput1.clear();
                        adjCtrl.dateInput2.clear();
                        adjCtrl.selectedStatus.value = "";
                        adjCtrl.selectedType.value = "";
                      },
                    ),
                    const SizedBox(width: 5),
                    CsElevatedButtonIcon(
                      backgroundColor: AppColors.itemsBackground,
                      icon: const Icon(Icons.save_as_rounded),
                      fontSize: 14,
                      label: 'Cari',
                      onPressed: () {
                        if (adjCtrl.dateInput1.text.isEmpty ||
                            adjCtrl.dateInput2.text.isEmpty) {
                          showToast(
                            'Harap pilih tanggal data adjusment terlebih dahulu',
                          );
                        } else {
                          var tglA = DateFormat(
                            'yyyy-MM-dd',
                          ).format(DateTime.parse(adjCtrl.dateInput1.text));
                          var tglB = DateFormat(
                            'yyyy-MM-dd',
                          ).format(DateTime.parse(adjCtrl.dateInput2.text));

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
                                adjCtrl.isLoading.value = true;
                                // adjCtrl.selectedType.value = val;
                                await adjCtrl.getReqAppUpt(
                                  adjCtrl.selectedStatus.value,
                                  adjCtrl.selectedType.value,
                                  userData.level,
                                  userData.id,
                                  userData.kodeCabang,
                                  adjCtrl.dateInput1.text,
                                  adjCtrl.dateInput2.text,
                                );

                                adjCtrl.dateInput1.clear();
                                adjCtrl.dateInput2.clear();
                                adjCtrl.selectedStatus.value = "";
                                adjCtrl.selectedType.value = "";
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
}
