import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../controllers/add_pegawai_controller.dart';

class AddPegawaiView extends GetView<AddPegawaiController> {
  const AddPegawaiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Register', style: TextStyle(color: AppColors.mainTextColor1),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/image/new_bg_app.jpg'), // Gantilah dengan path gambar Anda
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: InkWell(
              onTap: () => controller.uploadImageProfile(),
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
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              size: 50,
                            ),
                            Text(
                              'Choose File',
                              style: TextStyle(color: Colors.blue),
                            )
                          ],
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
              value: controller.brandCabang.value == ""
                  ? null
                  : controller.brandCabang.value,
              onChanged: (data) {
                controller.brandCabang.value = data!;
                controller.selectedCabang.value = "";
                controller.store.clear();
              },
              items: controller.listBrand
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
              future: controller.getCabang(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var dataCabang = snapshot.data;
                  List<String> allStore = <String>[];
                  dataCabang!.map((data) {
                    allStore.add(data.namaCabang!);
                  }).toList();
                  return TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: controller.store,
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
                      controller.store.text = suggestion;
                      for (int i = 0; i < dataCabang.length; i++) {
                        if (dataCabang[i].namaCabang == suggestion) {
                          controller.selectedCabang.value =
                              dataCabang[i].kodeCabang!;
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
            future: controller.getLevel(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var dataLevel = snapshot.data;
                List<String> allLevel = <String>[];
                dataLevel!.map((data) {
                  allLevel.add(data.namaLevel!);
                }).toList();

                return TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller.level,
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
                    controller.level.text = suggestion;
                    for (int i = 0; i < dataLevel.length; i++) {
                      if (dataLevel[i].namaLevel == suggestion) {
                        controller.selectedLevel.value = dataLevel[i].id!;
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
            controller: controller.username,
            decoration: const InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            obscureText: true,
            controller: controller.pass,
            decoration: const InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.name,
            decoration: const InputDecoration(
                labelText: 'Nama',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.telp,
            decoration: const InputDecoration(
                labelText: 'No Telp',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(
            height: 20,
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
                  controller.addUpdatePegawai(context, "add", Data());
                },
                child: const Text('SUBMIT', style: TextStyle(color: AppColors.mainTextColor1),)),
          )
        ],
      ),
    );
  }
}
