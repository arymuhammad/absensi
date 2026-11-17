import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/shared/container_main_color.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:icons_flutter/icons_flutter.dart';

import '../../../data/helper/custom_dialog.dart';
import '../controllers/add_pegawai_controller.dart';

class AddPegawaiView extends GetView<AddPegawaiController> {
  const AddPegawaiView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // GLOBAL BACKGROUND
          Image.asset(
            isDark ? 'assets/image/bg-ctn-drk.png' : 'assets/image/bg-ctn.png',
            fit: BoxFit.cover,
          ),

          // BLUE HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Image.asset(
              isDark ? 'assets/image/bg-hd-drk.png' : 'assets/image/bg-hd.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          ListView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
            children: [
              Text(
                'WELCOME',
                style: titleTextStyle.copyWith(
                  fontSize: 40,
                  color: AppColors.contentColorWhite,
                ),
              ),
              Text(
                'Create your account',
                style: subtitleTextStyle.copyWith(
                  fontSize: 20,
                  color: AppColors.contentColorWhite,
                ),
              ),
              const SizedBox(height: 40),
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
                                  controller.brandCabang.value == ""
                                      ? null
                                      : controller.brandCabang.value,
                              onChanged: (data) {
                                controller.brandCabang.value = data!;
                                controller.selectedCabang.value = "";
                                controller.store.clear();
                              },
                              items:
                                  controller.listBrand
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.brandCabang!.toString(),
                                          child: Text(e.brandCabang!),
                                        ),
                                      )
                                      .toList(),
                              borderRadius: BorderRadius.circular(10),
                              decoration: InputDecoration(
                                labelText: 'Brand',
                                filled: true,
                                fillColor:
                                    isDark
                                        ? const Color(
                                          0xFF1E293B,
                                        ).withOpacity(0.78)
                                        : Colors.white.withOpacity(0.82),
                                contentPadding: const EdgeInsets.all(8),
                                border: const OutlineInputBorder(),
                              ),
                              dropdownColor:
                                  isDark
                                      ? const Color(
                                        0xFF1E293B,
                                      ).withOpacity(0.78)
                                      : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
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
                                    autoFlipDirection: true,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                          controller: controller.store,
                                          decoration: InputDecoration(
                                            labelText: 'Cabang',
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor:
                                                isDark
                                                    ? const Color(
                                                      0xFF1E293B,
                                                    ).withOpacity(0.78)
                                                    : Colors.white.withOpacity(
                                                      0.82,
                                                    ),
                                          ),
                                        ),
                                    suggestionsBoxDecoration:
                                        SuggestionsBoxDecoration(
                                          color:
                                              isDark
                                                  ? const Color(
                                                    0xFF1E293B,
                                                  ).withOpacity(0.78)
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                    suggestionsCallback: (pattern) {
                                      return allStore.where(
                                        (option) => option
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()),
                                      );
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        tileColor:
                                            isDark
                                                ? const Color(0xFF1E293B)
                                                : Colors.white,
                                        title: Text(suggestion),
                                      );
                                    },
                                    onSuggestionSelected: (suggestion) {
                                      controller.store.text = suggestion;
                                      for (
                                        int i = 0;
                                        i < dataCabang.length;
                                        i++
                                      ) {
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
                                    Center(child: CupertinoActivityIndicator()),
                                    SizedBox(width: 5),
                                    Text('Sedang memuat...'),
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
                      onTap: () => controller.uploadImageProfile(),
                      child: ClipRect(
                        child: GetBuilder<AddPegawaiController>(
                          builder: (c) {
                            if (c.image != null || c.webImage.isNotEmpty) {
                              return kIsWeb
                                  ? Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          isDark
                                              ? const Color(
                                                0xFF1E293B,
                                              ).withOpacity(0.78)
                                              : Colors.white.withOpacity(0.82),
                                    ),
                                    child: Image.memory(
                                      c.webImage,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                  : Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          isDark
                                              ? const Color(
                                                0xFF1E293B,
                                              ).withOpacity(0.78)
                                              : Colors.white.withOpacity(0.82),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(c.image!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                            } else {
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      isDark
                                          ? const Color(
                                            0xFF1E293B,
                                          ).withOpacity(0.78)
                                          : Colors.white.withOpacity(0.82),
                                ),
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
                                    ),
                                  ],
                                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: controller.username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(
                                        0xFF1E293B,
                                      ).withOpacity(0.78)
                                      : Colors.white.withOpacity(0.82),
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            obscureText: true,
                            controller: controller.pass,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(
                                        0xFF1E293B,
                                      ).withOpacity(0.78)
                                      : Colors.white.withOpacity(0.82),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: controller.name,
                            decoration: InputDecoration(
                              labelText: 'Nama',
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(
                                        0xFF1E293B,
                                      ).withOpacity(0.78)
                                      : Colors.white.withOpacity(0.82),
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: controller.telp,
                            decoration: InputDecoration(
                              labelText: 'No Telp',
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(
                                        0xFF1E293B,
                                      ).withOpacity(0.78)
                                      : Colors.white.withOpacity(0.82),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: FutureBuilder(
                  future: controller.getLevel(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var dataLevel = snapshot.data;
                      List<String> allLevel = <String>[];
                      dataLevel!.map((data) {
                        allLevel.add(data.namaLevel!);
                      }).toList();

                      return TypeAheadFormField<String>(
                        autoFlipDirection: true,
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: controller.level,
                          decoration: InputDecoration(
                            labelText: 'Level User',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor:
                                isDark
                                    ? const Color(0xFF1E293B).withOpacity(0.78)
                                    : Colors.white.withOpacity(0.82),
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return allLevel.where(
                            (option) => option.toLowerCase().contains(
                              pattern.toLowerCase(),
                            ),
                          );
                        },
                        itemBuilder: (context, suggestion) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 30,
                              child: Text(
                                suggestion,
                                style: titleTextStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF1E293B).withOpacity(0.78)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                        Center(child: CupertinoActivityIndicator()),
                        SizedBox(width: 5),
                        Text('Sedang memuat...'),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 105),
                child: ContainerMainColor(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  radius: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      minimumSize: const Size(70, 50),
                    ),
                    onPressed: () async {
                      controller.isLoading.value = true;

                      final result = await controller.addUpdatePegawai(
                        context,
                        "add",
                        Data(),
                        isDark,
                      );
                      controller.isLoading.value = false;
                      if (result == true) {
                        Get.back(); // balik ke halaman sebelumnya

                        succesDialog(
                          context: Get.context!,
                          pageAbsen: "N",
                          desc: "Registration successful\nplease log in",
                          type: DialogType.success,
                          title: 'SUCCESS',
                          btnOkOnPress: () {
                            // Get.back(); // tutup dialog
                            Navigator.pop(context); // balik ke halaman profile
                          },
                          isDark: isDark
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('REGISTER', style: titleTextStyle),
                        const Icon(Typicons.arrows_cw),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
