import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/server_api_model.dart';
import 'package:absensi/app/modules/settings/controllers/settings_controller.dart';

import 'package:dynamic_base_url/dynamic_base_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helper/db_helper.dart';

class ChangeServer extends GetView {
  ChangeServer({super.key});

  final settingC = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SERVER'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/new_bg_app.jpg'),
              // Gantilah dengan path gambar Anda
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return settingC.getServerList();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 15.0, right: 15.0),
          child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: SizedBox(
                  height: 220,
                  width: Get.size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(child: Text('Pilih Server App')),
                              const SizedBox(
                                height: 15,
                              ),
                              FutureBuilder<List<ServerApi>>(
                                  future: settingC.getServerList(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      var serverList = snapshot.data!;

                                      return DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Server List'),
                                        value:
                                            settingC.serverSelected.isNotEmpty
                                                ? settingC.serverSelected.value
                                                : null,
                                        onChanged: (data) {
                                          settingC.serverSelected.value = data!;

                                          serverList.map((e) async {
                                            if (e.serverName == data &&
                                                e.status == "1") {
                                              var serverData = await SQLHelper
                                                  .instance
                                                  .getServer();

                                              if (serverData.isNotEmpty) {
                                                await SQLHelper.instance
                                                    .updateServer({
                                                  "server_name": e.serverName!,
                                                  "base_url": e.baseUrl!,
                                                  "path": e.path!,
                                                  "status": e.status!
                                                }, serverData[0].id!);

                                                BASEURL.PATH =
                                                    e.baseUrl! + e.path!;
                                                BASEURL.URL = e.baseUrl!;

                                                showToast(
                                                    "server berhasil diperbarui");
                                              } else {
                                                await SQLHelper.instance
                                                    .insertServer(ServerApi(
                                                        id: e.id!,
                                                        serverName:
                                                            e.serverName!,
                                                        baseUrl: e.baseUrl!,
                                                        path: e.path!,
                                                        status: e.status!));

                                                BASEURL.PATH =
                                                    e.baseUrl! + e.path!;
                                                BASEURL.URL = e.baseUrl!;

                                                showToast(
                                                    "server berhasil disimpan");
                                              }
                                            }
                                          }).toList();

                                          for (int i = 0;
                                              i < serverList.length;
                                              i++) {
                                            if (serverList[i].serverName ==
                                                    data &&
                                                serverList[i].status == "0") {
                                              showToast(
                                                  "server yang anda pilih sedang tidak aktif");
                                            }
                                          }
                                        },
                                        items: serverList
                                            .map((e) => DropdownMenuItem(
                                                value: e.serverName!,
                                                child: Text(
                                                  e.serverName!,
                                                  style: TextStyle(
                                                    color: e.status == "1"
                                                        ? green
                                                        : red,
                                                  ),
                                                )))
                                            .toList(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('${snapshot.error}'));
                                    }
                                    return const Center(
                                        child: CupertinoActivityIndicator());
                                  }),
                              const SizedBox(
                                height: 18,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: green),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text('Server aktif'),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: red),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text('Server tidak aktif'),
                                ],
                              ),
                            ]),
                      ],
                    ),
                  ))),
        ),
      ),
    );
  }
}
