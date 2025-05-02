import 'dart:developer';

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/req_app_update.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:absensi/app/modules/shared/elevated_button.dart';
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
          title: Text('NOTIFICATIONS',
              style: titleTextStyle.copyWith(
                fontSize: 20,
              )),
          backgroundColor: Colors.transparent.withOpacity(0.4),
          elevation: 0.0,
          // iconTheme: const IconThemeData(color: Colors.black,),
          centerTitle: true,
          actions: [Container()]),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const CsBgImg(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 100, 8, 8),
            child: Card(
                child: Container(
                    // height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: ReqAppUpdate(
                      dataUser: userData!,
                    ))),
          )
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
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
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Cari Data',
                  style: titleTextStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const Divider(),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: CsDropDown(
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
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: CsDropDown(
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
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
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
                              border: OutlineInputBorder()),
                          format: DateFormat("yyyy-MM-dd"),
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                          }),
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
                              border: OutlineInputBorder()),
                          format: DateFormat("yyyy-MM-dd"),
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                          }),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
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
                      icon: const Icon(Icons.save_as_rounded),
                      fontSize: 14,
                      label: 'Cari',
                      onPressed: () {
                        var tglA = DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(adjCtrl.dateInput1.text));
                        var tglB = DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(adjCtrl.dateInput2.text));

                        if (DateTime.parse(tglA)
                            .isAfter(DateTime.parse(tglB))) {
                          failedDialog(context, 'ERROR',
                              'Rentang tanggal yang Anda masukkan salah');
                        } else {
                          adjCtrl.isLoading.value = true;
                          // adjCtrl.selectedType.value = val;
                          adjCtrl.getReqAppUpt(
                              adjCtrl.selectedStatus.value,
                              adjCtrl.selectedType.value,
                              userData!.level,
                              userData!.id,
                              adjCtrl.dateInput1.text,
                              adjCtrl.dateInput2.text);
                          Get.back();
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
