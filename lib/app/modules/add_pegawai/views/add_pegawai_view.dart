import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../controllers/add_pegawai_controller.dart';

class AddPegawaiView extends GetView<AddPegawaiController> {
  const AddPegawaiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // height: Get.mediaQuery.size.height / 2,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/image/bg.png'),
                    fit: BoxFit.fill)),
          ),
          ListView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
            children: [
              Text(
                'WELCOME',
                style: titleTextStyle.copyWith(
                  fontSize: 40,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Create your account',
                style: subtitleTextStyle.copyWith(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
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
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder()),
                              dropdownColor: Colors.white,
                              
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 50,
                            child: FutureBuilder(
                              future: controller.getCabang(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var dataCabang = snapshot.data;
                                  List<String> allStore = <String>[];
                                  dataCabang!.map((data) {
                                    allStore.add(data.namaCabang!);
                                  }).toList();
                                  return TypeAheadFormField<String>(
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: controller.store,
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
                                      controller.store.text = suggestion;
                                      for (int i = 0;
                                          i < dataCabang.length;
                                          i++) {
                                        if (dataCabang[i].namaCabang ==
                                            suggestion) {
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
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () => controller.uploadImageProfile(),
                      child: ClipRect(
                        child: GetBuilder<AddPegawaiController>(
                          builder: (c) {
                            if (c.image != null || c.webImage.isNotEmpty) {
                              return kIsWeb
                                  ? Container(
                                      height: 110,
                                      width: 110,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300]),
                                      child: Image.memory(
                                        c.webImage,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Container(
                                      height: 110,
                                      width: 110,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300]),
                                      child: Image.file(
                                        File(c.image!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                            } else {
                              return Container(
                                height: 110,
                                width: 110,
                                decoration:
                                    BoxDecoration(color: Colors.grey[300]),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 45,
                                    ),
                                    Text(
                                      textAlign: TextAlign.center,
                                      'Upload\nFoto Profil',
                                      style: subtitleTextStyle.copyWith(
                                        color: Colors.blue,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controller.username,
                            decoration: const InputDecoration(
                                labelText: 'Username',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            obscureText: true,
                            controller: controller.pass,
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder()),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controller.name,
                            decoration: const InputDecoration(
                                labelText: 'Nama',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controller.telp,
                            decoration: const InputDecoration(
                                labelText: 'No Telp',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.phone,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                child: FutureBuilder(
                  future: controller.getLevel(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var dataLevel = snapshot.data;
                      List<String> allLevel = <String>[];
                      dataLevel!.map((data) {
                        allLevel.add(data.namaLevel!);
                      }).toList();
          
                      return TypeAheadFormField<String>(autoFlipDirection: true,
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
                          return allLevel.where((option) => option
                              .toLowerCase()
                              .contains(pattern.toLowerCase()));
                        },
                        itemBuilder: (context, suggestion) {
                          return  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 30,
                              child: Text(suggestion, style: titleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.normal),)),
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
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 105),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.contentDefBtn,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        minimumSize: const Size(70, 50)),
                    onPressed: () {
                      controller.addUpdatePegawai(context, "add", Data());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REGISTER',
                          style: titleTextStyle,
                        ),
                        const Icon(Iconsax.arrow_right_bold)
                      ],
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
