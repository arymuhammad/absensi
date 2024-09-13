import 'dart:io';

import 'package:absensi/app/modules/adjust_presence/views/expanded_data_absen.dart';
import 'package:absensi/app/modules/adjust_presence/views/expanded_data_visit.dart';
import 'package:absensi/app/modules/shared/elevated_button_icon.dart';
import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/loading_dialog.dart';
import '../controllers/adjust_presence_controller.dart';

class AdjustPresenceView extends GetView<AdjustPresenceController> {
  AdjustPresenceView({super.key});
  final ctrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Presence'),
        centerTitle: true,flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/new_bg_app.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.search_sharp),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Cari Data Absensi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.size.width / 1.8,
                      child: DateTimeField(
                          controller: ctrl.date1,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(0.5),
                              prefixIcon: Icon(Icons.calendar_month_outlined),
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
                    ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          if (ctrl.target.value == "absen") {
                            if (ctrl.date1.text == "" ||
                                ctrl.selectedCabang.isEmpty ||
                                // ctrl.userMonitor.isEmpty ||
                                ctrl.userCab.text == "" ||
                                ctrl.selectedUserCabang.isEmpty) {
                              failedDialog(Get.context, 'ERROR',
                                  'Harap isi semua kolom');
                            } else {
                              ctrl.isLoading.value = true;
                              await ctrl
                                  .getDataAbsen(ctrl.selectedUserCabang.value);
                            }
                          } else {
                            if (ctrl.date1.text == "" ||
                                ctrl.selectedDept.isEmpty ||
                                // ctrl.userMonitor.isEmpty ||
                                ctrl.userDept.text == "" ||
                                ctrl.selectedUserDept.isEmpty) {
                              failedDialog(Get.context, 'ERROR',
                                  'Harap isi semua kolom');
                            } else {
                              ctrl.isLoading.value = true;
                              await ctrl.getDataVisit(
                                  ctrl.date1.text,
                                  ctrl.date1.text,
                                  ctrl.selectedDept.value,
                                  ctrl.selectedUserDept.value);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            fixedSize: Size(Get.mediaQuery.size.width / 3, 50)),
                        label: const Text(
                          'CARI',
                          style: TextStyle(fontSize: 18),
                        ))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Get.size.width / 1.8,
                      height: 50,
                      child: Obx(
                        () => ctrl.target.value == "absen"
                            ? FutureBuilder(
                                future: ctrl.getCabang(),
                                builder: (ctx, snapshot) {
                                  if (snapshot.hasData) {
                                    var dataCabang = snapshot.data;
                                    List<String> allStore = <String>[];
                                    dataCabang!.map((data) {
                                      allStore.add(data.namaCabang!);
                                    }).toList();

                                    return TypeAheadFormField<String>(
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        style: const TextStyle(fontSize: 16),
                                        controller: ctrl.store,
                                        decoration:  InputDecoration(
                                          labelText: 'Cabang',
                                          hintText: "AEON BSD",
                                          border: const OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                          suffixIcon: Obx(() => ctrl
                                                    .selectedCabang.isNotEmpty
                                                ? IconButton(
                                                    onPressed: () {
                                                      ctrl.selectedCabang.value =
                                                          "";
                                                      ctrl.store.clear();
                                                      // ctrl.fcsDept.requestFocus();
                                                    },
                                                    icon:
                                                        const Icon(Icons.clear))
                                                : const Text(''))
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
                                        ctrl.store.text = suggestion;
                                        for (int i = 0;
                                            i < dataCabang.length;
                                            i++) {
                                          if (dataCabang[i].namaCabang ==
                                              suggestion) {
                                            ctrl.selectedCabang.value =
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
                                })
                            : FutureBuilder(
                                future: ctrl.getDeptVisit(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var dataDept = snapshot.data!;
                                    List<String> user = <String>[];
                                    dataDept.map((data) {
                                      user.add(data.nama);
                                    }).toList();

                                    return TypeAheadFormField<String>(
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        style: const TextStyle(fontSize: 13),
                                        controller: ctrl.dept,
                                        // focusNode: ctrl.fcsDept,
                                        decoration: InputDecoration(
                                            labelText: 'Department',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            filled: true,
                                            fillColor: Colors.white,
                                            suffixIcon: Obx(() => ctrl
                                                    .selectedDept.isNotEmpty
                                                ? IconButton(
                                                    onPressed: () {
                                                      ctrl.selectedDept.value =
                                                          "";
                                                      ctrl.dept.clear();
                                                      // ctrl.fcsDept.requestFocus();
                                                    },
                                                    icon:
                                                        const Icon(Icons.clear))
                                                : const Text(''))),
                                      ),
                                      suggestionsCallback: (pattern) {
                                        return user.where((option) => option
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
                                        ctrl.dept.text = suggestion;
                                        for (int i = 0;
                                            i < dataDept.length;
                                            i++) {
                                          if (dataDept[i].nama == suggestion) {
                                            ctrl.selectedDept.value =
                                                dataDept[i].id;
                                          }
                                        }
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('${snapshot.error}');
                                  }
                                  return const CupertinoActivityIndicator();
                                },
                              ),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      height: 50,
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                              hintText: 'Pilih sumber',
                              contentPadding: EdgeInsets.all(8),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder()),
                          items: ctrl.listTarget
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) {
                            ctrl.target.value = value!;
                          }),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ctrl.target.value == "absen"
                        ? FutureBuilder(
                            future: ctrl.getUserCabang(
                                ctrl.selectedCabang.isNotEmpty
                                    ? ctrl.selectedCabang.value
                                    : "UE526"),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                var dataUserCabang = snapshot.data;
                                List<String> userCab = <String>[];
                                dataUserCabang!.map((data) {
                                  userCab.add(data.nama!);
                                }).toList();

                                return TypeAheadFormField<String>(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    style: const TextStyle(fontSize: 16),
                                    controller: ctrl.userCab,
                                    decoration:  InputDecoration(
                                      labelText: 'User',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: Obx(() => ctrl
                                                .selectedUserCabang.isNotEmpty
                                            ? IconButton(
                                                onPressed: () {
                                                  ctrl.selectedUserCabang.value =
                                                      "";
                                                  ctrl.userCab.clear();
                                                  // ctrl.fcsUser
                                                  //     .requestFocus();
                                                },
                                                icon: const Icon(Icons.clear))
                                            : const Text(''))
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
                                    ctrl.userCab.text = suggestion;
                                    // ctrl.userMonitor.value = suggestion;
                                    for (int i = 0;
                                        i < dataUserCabang.length;
                                        i++) {
                                      if (dataUserCabang[i].nama ==
                                          suggestion) {
                                        ctrl.selectedUserCabang.value =
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
                                ],
                              );
                            })
                        : FutureBuilder(
                            future: ctrl.getUserVisit(
                                ctrl.selectedDept.isNotEmpty
                                    ? ctrl.selectedDept.value
                                    : "26"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var dataUser = snapshot.data!;
                                List<String> user = <String>[];
                                dataUser.map((data) {
                                  user.add(data.nama!);
                                }).toList();

                                return TypeAheadFormField<String>(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    style: const TextStyle(fontSize: 13),
                                    controller: ctrl.userDept,
                                    // focusNode: ctrl.fcsUser,
                                    decoration: InputDecoration(
                                        labelText: 'Pilih User',
                                        border: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.all(8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: Obx(() => ctrl
                                                .selectedUserDept.isNotEmpty
                                            ? IconButton(
                                                onPressed: () {
                                                  ctrl.selectedUserDept.value =
                                                      "";
                                                  ctrl.userDept.clear();
                                                  // ctrl.fcsUser
                                                  //     .requestFocus();
                                                },
                                                icon: const Icon(Icons.clear))
                                            : const Text(''))),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    return user.where((option) => option
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
                                    ctrl.userDept.text = suggestion;
                                    for (int i = 0; i < dataUser.length; i++) {
                                      if (dataUser[i].nama == suggestion) {
                                        ctrl.selectedUserDept.value =
                                            dataUser[i].id!;
                                      }
                                    }
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }
                              return const CupertinoActivityIndicator();
                            },
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              thickness: 2,
            ),
            Obx(() {
              if (ctrl.target.value == "absen") {
                
                return ExpandedDataAbsen(data: ctrl.resultData.value);
              } else {
                return ExpandedDataVisit(dataVisit: ctrl.dataVisit);
              }
            })
          ],
        ),
      ),
    );
  }
}
