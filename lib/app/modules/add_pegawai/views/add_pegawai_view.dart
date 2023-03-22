import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/add_pegawai_controller.dart';
import '../../../controllers/page_index_controller.dart';

class AddPegawaiView extends GetView<AddPegawaiController> {
  AddPegawaiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD PEGAWAI'),
        centerTitle: true,
      ),
      body: ListView(
        // scrollDirection: Axis.vertical,
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: InkWell(
              onTap: () => controller.uploadImageProfile(),
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
                        child: const Center(
                            child: Icon(
                          Icons.camera_alt_rounded,
                          size: 50,
                        )),
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
            future: controller.getCabang(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var dataCabang = snapshot.data;
                List<String> allStore = <String>[];
                dataCabang!.map((data) {
                  allStore.add(data.namaCabang!);
                }).toList();

                return RawAutocomplete(
                  key: controller.autocompleteKey,
                  focusNode: controller.focusNodecabang,
                  textEditingController: controller.store,
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
                        controller.selectedCabang.value =
                            dataCabang[i].kodeCabang!;
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
            controller: controller.username,
            decoration: const InputDecoration(
                labelText: 'Username', border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            obscureText: true,
            controller: controller.pass,
            decoration: const InputDecoration(
                labelText: 'Password', border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.name,
            decoration: const InputDecoration(
                labelText: 'Nama', border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.telp,
            decoration: const InputDecoration(
                labelText: 'No Telp', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
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

                return RawAutocomplete(
                  key: controller.autocompleteKeyLevel,
                  focusNode: controller.focusNodelevel,
                  textEditingController: controller.level,
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
                        controller.selectedLevel.value = dataLevel[i].id!;
                        // print(controller.selectedLevel);
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
                controller.addUpdatePegawai("add", [""]);
              },
              child: const Text('ADD PEGAWAI'))
        ],
      ),
      // bottomNavigationBar: ConvexAppBar(
      //   items: const [
      //     TabItem(icon: Icons.home, title: 'Home'),
      //     TabItem(icon: Icons.camera_outlined),
      //     TabItem(icon: Icons.person, title: 'Profile'),
      //   ],
      //   initialActiveIndex: pageC.pageIndex.value,
      //   activeColor: Colors.white,
      //   style: TabStyle.fixedCircle,
      //   onTap: (i) => pageC.changePage(i),
      // )
    );
  }
}
