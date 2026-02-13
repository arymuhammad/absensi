import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/req_app_update.dart';
import 'package:absensi/app/modules/shared/elevated_button_icon.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../adjust_presence/controllers/adjust_presence_controller.dart';
import '../../shared/dropdown.dart';

class ReqAppUserView extends GetView {
  ReqAppUserView({super.key, this.userData});
  final Data? userData;
  final adjCtrl = Get.put(AdjustPresenceController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
        actions: [Container()],
        flexibleSpace: Container(decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 100, 8, 8),
            child: Card(
              child: Container(
                // height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: ReqAppUpdate(dataUser: userData!),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder:
            (context) => FloatingActionButton(
              backgroundColor: AppColors.itemsBackground,
              onPressed: () {
                dialogSearchData(context);
              },
              child: const Icon(Icons.manage_search_outlined),
            ),
      ),
    );
  }

  dialogSearchData(BuildContext context) {
    Get.bottomSheet(
      backgroundColor: Colors.white,
      SingleChildScrollView(
        child: Container(
          // Atur tinggi sesuai kebutuhan, misal 400
          height: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.mediaQuery.size.width / 2.1,
                      child: DateTimeField(
                        controller: adjCtrl.dateInput1,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(0.5),
                          prefixIcon: Icon(Iconsax.calendar_edit_outline),
                          hintText: 'Tanggal Awal',
                          filled: true,
                          fillColor: Colors.white,
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
                    SizedBox(
                      width: Get.mediaQuery.size.width / 2.1,
                      child: DateTimeField(
                        controller: adjCtrl.dateInput2,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(0.5),
                          prefixIcon: Icon(Iconsax.calendar_edit_outline),
                          hintText: 'Tanggal Akhir',
                          filled: true,
                          fillColor: Colors.white,
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  userData!.level,
                                  userData!.id,
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
