import 'dart:io';

import 'package:absensi/app/helper/app_colors.dart';
import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../services/service_api.dart';

class UpdateProfil extends GetView {
  UpdateProfil({super.key, this.userData});
  final List? userData;
  final ctr = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('UPDATE PROFILE',
            style: TextStyle(color: AppColors.mainTextColor1)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/image/bgapp.jpg'), // Gantilah dengan path gambar Anda
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: ListView(
        // scrollDirection: Axis.vertical,
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
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
                        child: userData![5] != ""
                            ? Image.network(
                                "${ServiceApi().baseUrl}${userData![5]}")
                            : Image.network(
                                "https://ui-avatars.com/api/?name=${userData![1]}",
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
              value: ctr.brandCabang.value == "" ? null : ctr.brandCabang.value,
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
                      controller: ctr.store,
                      decoration: const InputDecoration(
                        labelText: 'Cabang',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return allStore.where((option) =>
                          option.toLowerCase().contains(pattern.toLowerCase()));
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
                          ctr.selectedCabang.value = dataCabang[i].kodeCabang!;
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
          Visibility(
            visible: userData![9] == "1" ? true : false,
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
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: ctr.level,
                      decoration: const InputDecoration(
                        labelText: 'Level User',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return allLevel.where((option) =>
                          option.toLowerCase().contains(pattern.toLowerCase()));
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
          TextField(
            controller: ctr.name,
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
            decoration: const InputDecoration(
                labelText: 'No Telp',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder()),
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
                  ctr.addUpdatePegawai(context, "update", userData!);
                },
                child: const Text('UPDATE PROFILE', style: TextStyle(color: AppColors.mainTextColor1),)),
          )
        ],
      ),
    );
  }
}
