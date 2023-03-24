import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../Repo/service_api.dart';
import '../controllers/detail_absen_controller.dart';

class DetailAbsenView extends GetView<DetailAbsenController> {
  const DetailAbsenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Absen'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat("EEEE dd/MM/yyyy")
                            .format(DateTime.parse(Get.arguments['tanggal'])),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          height: 75,
                          width: 75,
                          color: Colors.white,
                          child: Center(
                            child: Image.network(
                              "${ServiceApi().baseUrl}${Get.arguments['foto_masuk']}",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Nama'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      '${Get.arguments["nama"].toString().capitalize}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Shift'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text('${Get.arguments['nama_shift']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Masuk'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text('${Get.arguments['jam_absen_masuk']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Status Masuk'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text("${Get.arguments['jam_masuk']}",
                                      style: TextStyle(
                                          color: Get.arguments['jam_masuk'] ==
                                                  "Telat"
                                              ? Colors.redAccent[700]
                                              : Colors.greenAccent[700],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat("EEEE dd/MM/yyyy")
                            .format(DateTime.parse(Get.arguments['tanggal'])),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          height: 75,
                          width: 75,
                          color: Colors.white,
                          child: Center(
                            child: Get.arguments['foto_pulang'] != ""
                                ? Image.network(
                                    "${ServiceApi().baseUrl}${Get.arguments['foto_pulang']}",
                                    fit: BoxFit.cover,
                                    // progressIndicatorBuilder:
                                    //     (context, url, progress) {
                                    //   print(
                                    //       "${ServiceApi().baseUrl}${Get.arguments['foto_masuk']}");
                                    //   return CircularProgressIndicator(
                                    //     value: progress.progress,
                                    //     strokeWidth: 5,
                                    //   );
                                    // },
                                  )
                                : const Icon(Icons.image_not_supported_sharp),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Nama'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      '${Get.arguments["nama"].toString().capitalize}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Shift'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text('${Get.arguments['nama_shift']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Pulang'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text('${Get.arguments['jam_absen_pulang']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Status Pulang'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text("${Get.arguments['jam_pulang']}",
                                      style: TextStyle(
                                          color: Get.arguments['jam_pulang'] ==
                                                      "Belum / Tidak\nAbsen Pulang" ||
                                                  Get.arguments['jam_pulang'] ==
                                                      "Pulang Cepat"
                                              ? Colors.redAccent[700]
                                              : Colors.greenAccent[700],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                ],
              ))
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
      // ),
    );
  }
}
