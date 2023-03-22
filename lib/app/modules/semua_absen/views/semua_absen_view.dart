import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/controllers/page_index_controller.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../routes/app_pages.dart';
import '../controllers/semua_absen_controller.dart';
import 'package:intl/intl.dart';

class SemuaAbsenView extends GetView<SemuaAbsenController> {
  SemuaAbsenView({Key? key}) : super(key: key);
  final absenC = Get.put(AbsenController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Absensi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 8,
              child: TextField(
                controller: absenC.filterAbsen,
                onChanged: (data) => absenC.filterDataAbsen(data),
                decoration: InputDecoration(
                    hintText: 'Cari berdasarkan tanggal (Cth : 2023-01-01)',
                    labelText: 'Cari Absen',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => absenC.isLoading.value
                  ? ListView.builder(
                      padding: const EdgeInsets.only(
                          bottom: 20.0, left: 20.0, right: 20.0),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey,
                                    highlightColor: const Color.fromARGB(
                                        255, 238, 238, 238),
                                    child: Container(
                                      width: 60,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey,
                                    highlightColor: const Color.fromARGB(
                                        255, 238, 238, 238),
                                    child: Container(
                                      width: 130,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.grey,
                                highlightColor:
                                    const Color.fromARGB(255, 238, 238, 238),
                                child: Container(
                                  width: 70,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.grey,
                                highlightColor:
                                    const Color.fromARGB(255, 238, 238, 238),
                                child: Container(
                                  width: 60,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.grey,
                                highlightColor:
                                    const Color.fromARGB(255, 238, 238, 238),
                                child: Container(
                                  width: 70,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : absenC.searchAbsen.isEmpty
                      ? const Center(
                          child: Text('Belum ada data absen'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(
                              bottom: 20.0, left: 20.0, right: 20.0),
                          itemCount: absenC.searchAbsen.length,
                          itemBuilder: (c, i) {
                            return InkWell(
                              onTap: () {
                                absenC.searchAbsen;
                                Get.toNamed(Routes.DETAIL_ABSEN);
                                absenC.filterAbsen.clear();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Masuk',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            DateFormat('EE, dd-MM-yyyy').format(
                                                DateTime.parse(absenC
                                                    .searchAbsen[i].tanggal!)),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text(absenC.searchAbsen[i].jamAbsenMasuk!),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text(
                                      'Keluar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(absenC.searchAbsen[i].jamAbsenPulang !=
                                            ""
                                        ? absenC.searchAbsen[i].jamAbsenPulang!
                                        : "-"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
