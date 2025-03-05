import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../data/helper/const.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../services/service_api.dart';

class UpdateProfil extends GetView {
  UpdateProfil({super.key, this.userData});
  final Data? userData;
  final ctr = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('PROFILE',
            style: titleTextStyle.copyWith(
              fontSize: 20,
            )),
        backgroundColor: Colors.transparent.withOpacity(0.4),
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const CsBgImg(),
          ListView(
            // scrollDirection: Axis.vertical,
            // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
            children: [
              Center(
                child: InkWell(
                  onTap: () => ctr.uploadImageProfile(),
                  child: ClipOval(
                    child: GetBuilder<AddPegawaiController>(
                      builder: (c) {
                        if (c.image != null || c.webImage.isNotEmpty) {
                          return kIsWeb
                              ? Container(
                                  height: 150,
                                  width: 150,
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  child: Image.memory(
                                    c.webImage,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Container(
                                  height: 150,
                                  width: 150,
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  child: Image.file(
                                    File(c.image!.path),
                                    fit: BoxFit.cover,
                                  ),
                                );
                        } else {
                          return Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            child: userData!.foto != ""
                                ? Image.network(
                                    "${ServiceApi().baseUrl}${userData!.foto}",
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    "https://ui-avatars.com/api/?name=${userData!.nama}",
                                    fit: BoxFit.cover,
                                  ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Obx(
                () => DropdownButtonFormField(
                  value: ctr.brandCabang.value == ""
                      ? null
                      : ctr.brandCabang.value,
                  onChanged: (data) {
                    ctr.brandCabang.value = data!;
                    ctr.selectedCabang.value = "";
                    ctr.store.clear();
                  },
                  items: ctr.listBrand
                      .map((e) => DropdownMenuItem(
                          value: e.brandCabang!.toString(),
                          child: Text(e.brandCabang!)))
                      .toList(),
                  decoration: const InputDecoration(
                      labelText: 'Brand',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder()),
                  dropdownColor: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Obx(
                () => FutureBuilder(
                  future: ctr.getCabang(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var dataCabang = snapshot.data;
                      List<String> allStore = <String>[];
                      dataCabang!.map((data) {
                        allStore.add(data.namaCabang!);
                      }).toList();

                      return TypeAheadFormField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: ctr.store..text = userData!.namaCabang!,
                          decoration: const InputDecoration(
                            labelText: 'Cabang',
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
                          ctr.store.text = suggestion;
                          for (int i = 0; i < dataCabang.length; i++) {
                            if (dataCabang[i].namaCabang == suggestion) {
                              ctr.selectedCabang.value =
                                  dataCabang[i].kodeCabang!;
                              ctr.cabangName.value = dataCabang[i].namaCabang!;
                              ctr.lat.value = dataCabang[i].lat!;
                              ctr.long.value = dataCabang[i].long!;
                              ctr.cvrArea.value = dataCabang[i].cvrArea!;
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
                        Center(
                          child: CupertinoActivityIndicator(),
                        ),
                        SizedBox(width: 5),
                        Text('Sedang memuat...'),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder(
                future: ctr.getLevel(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var dataLevel = snapshot.data;
                    List<String> allLevel = <String>[];
                    dataLevel!.map((data) {
                      allLevel.add(data.namaLevel!);
                    }).toList();

                    return TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: ctr.level..text = userData!.levelUser!,
                        decoration: InputDecoration(
                            labelText: 'Level User',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  ctr.level.clear();
                                },
                                icon: const Icon(
                                  Icons.highlight_remove_rounded,
                                ))),
                      ),
                      suggestionsCallback: (pattern) {
                        return allLevel.where((option) => option
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
                        ctr.level.text = suggestion;
                        for (int i = 0; i < dataLevel.length; i++) {
                          if (dataLevel[i].namaLevel == suggestion) {
                            ctr.selectedLevel.value = dataLevel[i].id!;
                            ctr.levelName.value = dataLevel[i].namaLevel!;
                            ctr.vst.value = dataLevel[i].visit!;
                            ctr.cekStok.value = dataLevel[i].cekStok!;
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
                      Center(
                        child: CupertinoActivityIndicator(),
                      ),
                      SizedBox(width: 5),
                      Text('Sedang memuat...'),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: ctr.name..text = userData!.nama!,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: ctr.telp,
                decoration: InputDecoration(
                    labelText: 'No Telp',
                    hintText: userData!.noTelp!,
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.contentDefBtn,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        minimumSize: Size(Get.size.width / 2, 50)),
                    onPressed: () {
                      loadingDialog("updating data", "");
                      ctr.addUpdatePegawai(context, "update", userData!);
                    },
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(color: AppColors.mainTextColor1),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
