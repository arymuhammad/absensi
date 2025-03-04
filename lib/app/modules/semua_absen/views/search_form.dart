import 'dart:io';

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

final absC = Get.put(AbsenController());

searchForm() {
  return Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: 400,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Iconsax.search_zoom_out_outline),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Cari Data Absensi',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 2,
                  height: 2,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.mediaQuery.size.width / 2.1,
                          child: DateTimeField(
                              controller: absC.date1,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(0.5),
                                  prefixIcon:
                                      Icon(Iconsax.calendar_edit_outline),
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
                              controller: absC.date2,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(0.5),
                                  prefixIcon:
                                      Icon(Iconsax.calendar_edit_outline),
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
                    const SizedBox(height: 8),
                    FutureBuilder(
                        future: absC.getCabang(),
                        builder: (ctx, snapshot) {
                          if (snapshot.hasData) {
                            var dataCabang = snapshot.data;
                            List<String> allStore = <String>[];
                            dataCabang!.map((data) {
                              allStore.add(data.namaCabang!);
                            }).toList();

                            return TypeAheadFormField<String>(
                              textFieldConfiguration: TextFieldConfiguration(
                                style: const TextStyle(fontSize: 16),
                                controller: absC.store,
                                decoration: const InputDecoration(
                                  labelText: 'Cabang',
                                  hintText: "AEON BSD",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return allStore.where((option) => option
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()));
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  tileColor: Colors.white,
                                  title: Text(suggestion),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                absC.store.text = suggestion;
                                for (int i = 0; i < dataCabang.length; i++) {
                                  if (dataCabang[i].namaCabang == suggestion) {
                                    absC.selectedCabang.value =
                                        dataCabang[i].kodeCabang!;
                                  }
                                }
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Platform.isAndroid
                                  ? const CircularProgressIndicator()
                                  : const CupertinoActivityIndicator(),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text('Loading')
                            ],
                          );
                        }),
                    const SizedBox(height: 8),
                    Obx(
                      () => FutureBuilder(
                          future: absC.getUserCabang(
                              absC.selectedCabang.isNotEmpty
                                  ? absC.selectedCabang.value
                                  : "UE526"),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              var dataUserCabang = snapshot.data;
                              List<String> userCab = <String>[];
                              dataUserCabang!.map((data) {
                                userCab.add(data.nama!);
                              }).toList();

                              return TypeAheadFormField<String>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  style: const TextStyle(fontSize: 16),
                                  controller: absC.userCab,
                                  decoration: const InputDecoration(
                                    labelText: 'User',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                suggestionsCallback: (pattern) {
                                  return userCab.where((option) => option
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()));
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    tileColor: Colors.white,
                                    title: Text(suggestion),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  absC.userCab.text = suggestion;
                                  absC.userMonitor.value = suggestion;
                                  for (int i = 0;
                                      i < dataUserCabang.length;
                                      i++) {
                                    if (dataUserCabang[i].nama == suggestion) {
                                      absC.selectedUserCabang.value =
                                          dataUserCabang[i].id!;
                                    }
                                  }
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Platform.isAndroid
                                    ? const Row(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Load user')
                                        ],
                                      )
                                    : const Row(
                                        children: [
                                          CupertinoActivityIndicator(),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Load user')
                                        ],
                                      ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('Loading')
                              ],
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    OutlinedButton(
                        onPressed: () async {
                          absC.userCab.clear();
                          absC.store.clear();
                          absC.selectedCabang.value = "";
                          absC.selectedUserCabang.value = "";
                          absC.date1.clear();
                          absC.date2.clear();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            side:
                                const BorderSide(width: 2.0, color: Colors.red),
                            fixedSize: Size(Get.mediaQuery.size.width, 50)),
                        child: const Text(
                          'BATALKAN',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (absC.date1.text == "" ||
                              absC.date2.text == "" ||
                              absC.selectedCabang.isEmpty ||
                              absC.userMonitor.isEmpty ||
                              absC.selectedUserCabang.isEmpty) {
                            failedDialog(
                                Get.context, 'ERROR', 'Harap isi semua kolom');
                          } else {
                            absC.isLoading.value = true;
                            await absC.getFilteredAbsen(
                                absC.selectedUserCabang.value);
                            absC.userCab.clear();
                            absC.selectedUserCabang.value = "";
                            // absC.store.clear();
                            // absC.selectedCabang.value = "";
                            // absC.date1.clear();
                            // absC.date2.clear();
                            
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            fixedSize: Size(Get.mediaQuery.size.width, 50)),
                        child: const Text(
                          'CARI',
                          style: TextStyle(fontSize: 18),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
}
