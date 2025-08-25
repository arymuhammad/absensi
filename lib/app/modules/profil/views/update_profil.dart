import 'dart:io';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/const.dart';
import '../../../services/service_api.dart';

class UpdateProfil extends GetView {
  UpdateProfil({super.key, this.userData});
  final Data? userData;
  final ctr = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    ctr.store.text = userData!.namaCabang ?? '';
    ctr.joinDate.text = userData!.createdAt ?? '';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile', style: titleTextStyle.copyWith(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        // centerTitle: true,
      ),
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // const CsBgImg(),
          Container(
            height: 250,
            decoration: const BoxDecoration(color: AppColors.itemsBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150, left: 15.0, right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Your Account',
                  style: subtitleTextStyle.copyWith(
                    fontSize: 18,
                    color: AppColors.contentColorWhite,
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: DropdownButtonFormField(
                                          value:
                                              ctr.brandCabang.value == ""
                                                  ? null
                                                  : ctr.brandCabang.value,
                                          onChanged: (data) {
                                            ctr.store.clear();
                                            ctr.selectedCabang.value = "";
                                            ctr.cabangName.value = "";
                                            ctr.brandCabang.value = data!;
                                          },
                                          items:
                                              ctr.listBrand
                                                  .map(
                                                    (e) => DropdownMenuItem(
                                                      value:
                                                          e.brandCabang!
                                                              .toString(),
                                                      child: Text(
                                                        e.brandCabang!,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(5),
                                            labelText: 'Brand',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(),
                                          ),
                                          dropdownColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 50,
                                        child: FutureBuilder(
                                          future: ctr.getCabang(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              var dataCabang = snapshot.data;
                                              List<String> allStore =
                                                  <String>[];
                                              dataCabang!.map((data) {
                                                allStore.add(data.namaCabang!);
                                              }).toList();

                                              return TypeAheadFormField<String>(
                                                autoFlipDirection: true,
                                                textFieldConfiguration:
                                                    TextFieldConfiguration(
                                                      controller: ctr.store,
                                                      decoration:
                                                          const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                  5,
                                                                ),
                                                            labelText: 'Branch',
                                                            border:
                                                                OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                suggestionsCallback: (pattern) {
                                                  return allStore.where(
                                                    (option) => option
                                                        .toLowerCase()
                                                        .contains(
                                                          pattern.toLowerCase(),
                                                        ),
                                                  );
                                                },
                                                itemBuilder: (
                                                  context,
                                                  suggestion,
                                                ) {
                                                  return ListTile(
                                                    tileColor: Colors.white,
                                                    title: Text(suggestion),
                                                  );
                                                },
                                                onSuggestionSelected: (
                                                  suggestion,
                                                ) {
                                                  ctr.store.text = suggestion;
                                                  for (
                                                    int i = 0;
                                                    i < dataCabang.length;
                                                    i++
                                                  ) {
                                                    if (dataCabang[i]
                                                            .namaCabang ==
                                                        suggestion) {
                                                      ctr.selectedCabang.value =
                                                          dataCabang[i]
                                                              .kodeCabang!;
                                                      ctr.cabangName.value =
                                                          dataCabang[i]
                                                              .namaCabang!;
                                                      ctr.lat.value =
                                                          dataCabang[i].lat!;
                                                      ctr.long.value =
                                                          dataCabang[i].long!;
                                                      ctr.cvrArea.value =
                                                          dataCabang[i]
                                                              .cvrArea!;
                                                    }
                                                  }
                                                },
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }
                                            return const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child:
                                                      CupertinoActivityIndicator(),
                                                ),
                                                SizedBox(width: 5),
                                                Text('Loading...'),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () => ctr.uploadImageProfile(),
                                  child: ClipRect(
                                    child: GetBuilder<AddPegawaiController>(
                                      builder: (c) {
                                        if (c.image != null ||
                                            c.webImage.isNotEmpty) {
                                          return kIsWeb
                                              ? Container(
                                                height: 110,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                ),
                                                child: Image.memory(
                                                  c.webImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : Stack(
                                                children: [
                                                  Container(
                                                    height: 110,
                                                    width: 110,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                    ),
                                                    child: Image.file(
                                                      File(c.image!.path),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Icon(
                                                      Icons.camera_alt_rounded,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              );
                                        } else {
                                          return Stack(
                                            children: [
                                              Container(
                                                height: 110,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                ),
                                                child:
                                                    userData!.foto != ""
                                                        ? Image.network(
                                                          "${ServiceApi().baseUrl}${userData!.foto}",
                                                          fit: BoxFit.cover,
                                                        )
                                                        : Image.network(
                                                          "https://ui-avatars.com/api/?name=${userData!.nama}",
                                                          fit: BoxFit.cover,
                                                        ),
                                              ),
                                              const Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Icon(
                                                  Icons.camera_alt_rounded,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            child: TextField(
                              controller: ctr.name..text = userData!.nama!,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: TextField(
                                    controller: ctr.telp,
                                    decoration: InputDecoration(
                                      labelText: 'Phone No',
                                      hintText: userData!.noTelp!,
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: DateTimeField(
                                  // enabled: userData!.createdAt!="" ?false:true,
                                  controller: ctr.joinDate,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(0.5),
                                    prefixIcon: Icon(
                                      Iconsax.calendar_edit_outline,
                                    ),
                                    hintText: 'Join Date',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                  ),
                                  format: DateFormat("yyyy-MM-dd"),
                                  onShowPicker: (context, currentValue) {
                                    return showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            child: FutureBuilder(
                              future: ctr.getLevel(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var dataLevel = snapshot.data;
                                  List<String> allLevel = <String>[];
                                  dataLevel!.map((data) {
                                    allLevel.add(data.namaLevel!);
                                  }).toList();

                                  return TypeAheadFormField<String>(
                                    autoFlipDirection: true,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                          controller:
                                              ctr.level
                                                ..text = userData!.levelUser!,
                                          decoration: InputDecoration(
                                            labelText: 'User Level',
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                ctr.level.clear();
                                              },
                                              icon: const Icon(
                                                Icons.highlight_remove_rounded,
                                              ),
                                            ),
                                          ),
                                        ),
                                    suggestionsCallback: (pattern) {
                                      return allLevel.where(
                                        (option) => option
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()),
                                      );
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        tileColor: Colors.white,
                                        title: Text(suggestion),
                                      );
                                    },
                                    onSuggestionSelected: (suggestion) {
                                      ctr.level.text = suggestion;
                                      for (
                                        int i = 0;
                                        i < dataLevel.length;
                                        i++
                                      ) {
                                        if (dataLevel[i].namaLevel ==
                                            suggestion) {
                                          ctr.selectedLevel.value =
                                              dataLevel[i].id!;
                                          ctr.levelName.value =
                                              dataLevel[i].namaLevel!;
                                          ctr.vst.value = dataLevel[i].visit!;
                                          ctr.cekStok.value =
                                              dataLevel[i].cekStok!;
                                        }
                                      }
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                return const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(child: CupertinoActivityIndicator()),
                                    SizedBox(width: 5),
                                    Text('Loading...'),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.itemsBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                minimumSize: Size(Get.size.width / 2, 50),
                              ),
                              onPressed: () {
                                // loadingDialog("updating data", "");
                                ctr.isLoading.value = true;
                                ctr.addUpdatePegawai(
                                  context,
                                  "update",
                                  userData!,
                                );
                              },
                              child: Obx(
                                () =>
                                    ctr.isLoading.value
                                        ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('LOADING...   '),
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  Platform.isAndroid
                                                      ? const CircularProgressIndicator(
                                                        color:
                                                            AppColors
                                                                .contentColorWhite,
                                                      )
                                                      : const CupertinoActivityIndicator(),
                                            ),
                                          ],
                                        )
                                        : const Text(
                                          'UPDATE',
                                          style: TextStyle(
                                            color: AppColors.mainTextColor1,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
