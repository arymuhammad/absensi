import 'dart:io';

import 'package:absensi/app/modules/add_pegawai/controllers/add_pegawai_controller.dart';
import 'package:absensi/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../../../Repo/service_api.dart';

class UpdateProfil extends GetView {
  UpdateProfil({super.key, this.userData});
  final List? userData;
  final ctr = Get.put(AddPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPDATE PROFILE'),
        centerTitle: true,
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
                    if (c.image != null) {
                      return Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(color: Colors.grey[300]),
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
          FutureBuilder(
            future: ctr.getCabang(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var dataCabang = snapshot.data;
                List<String> allStore = <String>[];
                dataCabang!.map((data) {
                  allStore.add(data.namaCabang!);
                }).toList();

                return RawAutocomplete(
                  key: ctr.autocompleteKey,
                  focusNode: ctr.focusNodecabang,
                  textEditingController: ctr.store,
                  optionsBuilder: (TextEditingValue textValue) {
                    if (textValue.text == '') {
                      return const Iterable<String>.empty();
                    } else {
                      List<String> matches = <String>[];
                      matches.addAll(allStore);

                      matches.retainWhere((s) {
                        return s
                            .toLowerCase()
                            .contains(textValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },
                  onSelected: (String selection) {
                    for (int i = 0; i < dataCabang.length; i++) {
                      if (dataCabang[i].namaCabang == selection) {
                        ctr.selectedCabang.value = dataCabang[i].kodeCabang!;
                      }
                    }
                  },
                  fieldViewBuilder: (BuildContext context, cabang,
                      FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextField(
                      decoration: const InputDecoration(
                          labelText: 'Ketik Nama Cabang',
                          border: OutlineInputBorder()),
                      controller: cabang,
                      focusNode: focusNode,
                      onSubmitted: (String value) {},
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      void Function(String) onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                          child: SizedBox(
                        width: 210,
                        height: 170,
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) => Column(
                            children: options.map((opt) {
                              return InkWell(
                                  onTap: () {
                                    onSelected(opt);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    child: Text(opt),
                                  ));
                            }).toList(),
                          ),
                        ),
                      )),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Sedang memuat...'),
                  SizedBox(width: 5),
                  Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: ctr.name,
            decoration: const InputDecoration(
                labelText: 'Nama', border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: ctr.telp,
            decoration: const InputDecoration(
                labelText: 'No Telp', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
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

                return RawAutocomplete(
                  key: ctr.autocompleteKeyLevel,
                  focusNode: ctr.focusNodelevel,
                  textEditingController: ctr.level,
                  optionsBuilder: (TextEditingValue textValue) {
                    if (textValue.text == '') {
                      return const Iterable<String>.empty();
                    } else {
                      List<String> matches = <String>[];
                      matches.addAll(allLevel);

                      matches.retainWhere((s) {
                        return s
                            .toLowerCase()
                            .contains(textValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },
                  onSelected: (String selection) {
                    for (int i = 0; i < dataLevel.length; i++) {
                      if (dataLevel[i].namaLevel == selection) {
                        ctr.selectedLevel.value = dataLevel[i].id!;
                        // print(ctr.selectedLevel);
                      }
                    }
                  },
                  fieldViewBuilder: (BuildContext context, mk,
                      FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextField(
                      decoration: const InputDecoration(
                          labelText: 'Ketik Level User',
                          border: OutlineInputBorder()),
                      controller: mk,
                      focusNode: focusNode,
                      onSubmitted: (String value) {},
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      void Function(String) onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                          child: SizedBox(
                        width: 210,
                        height: 170,
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) => Column(
                            children: options.map((opt) {
                              return InkWell(
                                  onTap: () {
                                    onSelected(opt);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    child: Text(opt),
                                  ));
                            }).toList(),
                          ),
                        ),
                      )),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Sedang memuat...'),
                  SizedBox(width: 5),
                  Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                ctr.addUpdatePegawai("update", userData!);
              },
              child: const Text('UPDATE PROFILE'))
        ],
      ),
    );
  }
}
