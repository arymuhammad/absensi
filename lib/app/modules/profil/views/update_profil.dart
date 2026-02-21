import 'dart:io';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/shared/container_main_color.dart';
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
import '../../shared/input_decoration.dart';

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
           decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
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
                    color: Colors.blueGrey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
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
                                        height: 44,
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
                                          decoration: inputDecoration(
                                            label: 'Brand',
                                          ),
                                          dropdownColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 44,
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
                                                          inputDecoration(
                                                            label: 'Branch',
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
                                                height: 100,
                                                width: 100,
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
                                                    height: 100,
                                                    width: 100,
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
                                                height: 95,
                                                width: 95,
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
                            height: 44,
                            child: TextField(
                              controller: ctr.name..text = userData!.nama!,
                              decoration: inputDecoration(label: 'Full Name'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 44,
                                  child: TextField(
                                    controller: ctr.telp,
                                    keyboardType: TextInputType.phone,
                                    decoration: inputDecoration(
                                      label: 'Phone No',
                                      hint: userData!.noTelp!,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 44,
                                  child: DateTimeField(
                                    // enabled: userData!.createdAt!="" ?false:true,
                                    controller: ctr.joinDate,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: inputDecoration(
                                      label: '',
                                      hint: 'Join Date',
                                      prefixIcon: Iconsax.calendar_edit_outline,
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
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
                                          decoration: inputDecoration(
                                            label: 'User Level',
                                            suffixIcon:
                                                Icons.highlight_remove_rounded,
                                            onPressed: () => ctr.level.clear(),
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
                            child: ContainerMainColor(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              radius: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
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
