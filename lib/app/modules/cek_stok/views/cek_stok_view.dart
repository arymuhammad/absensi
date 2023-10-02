import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:get/get.dart';
import 'package:ternav_icons/ternav_icons.dart';

import '../controllers/cek_stok_controller.dart';

class CekStokView extends GetView<CekStokController> {
  CekStokView({super.key, this.kodeCabang});

  final cekStokC = Get.put(CekStokController());
  final String? kodeCabang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Stok'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, top: 10.0, right: 15.0, bottom: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 8,
              child: TextField(
                controller: cekStokC.cariArtikel,
                onSubmitted: (value) {
                  cekStokC.fetchDataStok(kodeCabang!);
                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: 'Cari Artikel',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          // void scanCariBarcode() async {
                          String barcodeScanRes;
                          // Platform messages may fail, so we use a try/catch PlatformException.
                          try {
                            barcodeScanRes =
                                await FlutterBarcodeScanner.scanBarcode(
                                    '#ff6666',
                                    'Cancel',
                                    true,
                                    ScanMode.BARCODE);
                            // print(barcodeScanRes);
                            if (barcodeScanRes == "-1") {
                              cekStokC.cariArtikel.clear();
                            } else {
                              cekStokC.cariArtikel.text = barcodeScanRes;
                              await cekStokC.fetchDataStok(kodeCabang!);
                            }
                            // Get.back();
                            // masterCtr.artikel.clear();
                          } on PlatformException {
                            barcodeScanRes = 'Failed to get platform version.';
                          }
                          // }
                        },
                        icon: const Icon(Icons.qr_code_scanner_outlined))),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Divider(
              color: Colors.white,
              thickness: 2,
            ),
          ),

          Obx(
            () => Visibility(
              visible: cekStokC.dataStok.isNotEmpty ? true : false,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Text(
                      'Nama Barang',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text('Sisa Stok',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() => cekStokC.dataStok.isEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: Get.size.height / 3),
                        child: Column(
                          children: const [
                            Center(
                              child: Text('Tidak ada data'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    // itemExtent: 35,
                    itemCount: cekStokC.dataStok.length,
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        title: Text(cekStokC.dataStok[i].namaBarang!),
                        trailing: Text(cekStokC.dataStok[i].sISA!),
                      );
                    },
                  )),
          )
          // Expanded(
          //   child: Obx(
          //     () => absenC.isLoading.value
          //         ? ListView.builder(
          //             padding: const EdgeInsets.only(
          //                 bottom: 20.0, left: 20.0, right: 20.0),
          //             itemCount: 3,
          //             itemBuilder: (context, index) {
          //               return Container(
          //                 margin: const EdgeInsets.only(bottom: 20),
          //                 padding: const EdgeInsets.all(10),
          //                 decoration: BoxDecoration(
          //                     color: Colors.grey[200],
          //                     borderRadius: BorderRadius.circular(20)),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Row(
          //                       mainAxisAlignment:
          //                           MainAxisAlignment.spaceBetween,
          //                       children: [
          //                         Shimmer.fromColors(
          //                           baseColor: Colors.grey,
          //                           highlightColor: const Color.fromARGB(
          //                               255, 238, 238, 238),
          //                           child: Container(
          //                             width: 60,
          //                             height: 15,
          //                             decoration: BoxDecoration(
          //                                 color: Colors.white,
          //                                 borderRadius:
          //                                     BorderRadius.circular(10)),
          //                           ),
          //                         ),
          //                         Shimmer.fromColors(
          //                           baseColor: Colors.grey,
          //                           highlightColor: const Color.fromARGB(
          //                               255, 238, 238, 238),
          //                           child: Container(
          //                             width: 130,
          //                             height: 15,
          //                             decoration: BoxDecoration(
          //                                 color: Colors.white,
          //                                 borderRadius:
          //                                     BorderRadius.circular(10)),
          //                           ),
          //                         )
          //                       ],
          //                     ),
          //                     const SizedBox(
          //                       height: 8,
          //                     ),
          //                     Shimmer.fromColors(
          //                       baseColor: Colors.grey,
          //                       highlightColor:
          //                           const Color.fromARGB(255, 238, 238, 238),
          //                       child: Container(
          //                         width: 70,
          //                         height: 15,
          //                         decoration: BoxDecoration(
          //                             color: Colors.white,
          //                             borderRadius: BorderRadius.circular(10)),
          //                       ),
          //                     ),
          //                     const SizedBox(
          //                       height: 8,
          //                     ),
          //                     Shimmer.fromColors(
          //                       baseColor: Colors.grey,
          //                       highlightColor:
          //                           const Color.fromARGB(255, 238, 238, 238),
          //                       child: Container(
          //                         width: 60,
          //                         height: 15,
          //                         decoration: BoxDecoration(
          //                             color: Colors.white,
          //                             borderRadius: BorderRadius.circular(10)),
          //                       ),
          //                     ),
          //                     const SizedBox(
          //                       height: 8,
          //                     ),
          //                     Shimmer.fromColors(
          //                       baseColor: Colors.grey,
          //                       highlightColor:
          //                           const Color.fromARGB(255, 238, 238, 238),
          //                       child: Container(
          //                         width: 70,
          //                         height: 15,
          //                         decoration: BoxDecoration(
          //                             color: Colors.white,
          //                             borderRadius: BorderRadius.circular(10)),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               );
          //             },
          //           )
          //         : absenC.searchAbsen.isEmpty
          //             ? RefreshIndicator(
          //                 onRefresh: () {
          //                   return Future.delayed(const Duration(seconds: 1),
          //                       () async {
          //                     // await absenC
          //                     //     .getAllAbsen(Get.arguments["id_user"]);
          //                     // showToast("Halaman Disegarkan.");
          //                   });
          //                 },
          //                 child: ListView(
          //                   physics: const AlwaysScrollableScrollPhysics(),
          //                   children: [
          //                     Padding(
          //                       padding:
          //                           EdgeInsets.only(top: Get.size.height / 3),
          //                       child: Column(
          //                         children: const [
          //                           Center(
          //                             child: Text('Belum ada data absen'),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               )
          //             : RefreshIndicator(
          //                 onRefresh: () {
          //                   return Future.delayed(const Duration(seconds: 1),
          //                       () async {
          //                     // await absenC
          //                     //     .getAllAbsen(absenC.searchAbsen[0].idUser!);
          //                     // showToast("Halaman Disegarkan.");
          //                   });
          //                 },
          //                 child: Container(),
          //                 // child: ListView.builder(
          //                 //   shrinkWrap: true,
          //                 //   padding: const EdgeInsets.only(
          //                 //       bottom: 20.0, left: 20.0, right: 20.0),
          //                 //   itemCount: absenC.searchAbsen.length,
          //                 //   itemBuilder: (c, i) {
          //                 //     return InkWell(
          //                 //       onTap: () {
          //                 //         absenC.searchAbsen;
          //                 //         Get.toNamed(Routes.DETAIL_ABSEN, arguments: {
          //                 //           "nama": absenC.searchAbsen[i].nama!,
          //                 //           "nama_shift":
          //                 //               absenC.searchAbsen[i].namaShift!,
          //                 //           "id_user": absenC.searchAbsen[i].idUser!,
          //                 //           "tanggal": absenC.searchAbsen[i].tanggal!,
          //                 //           "jam_masuk": DateFormat("HH:mm:ss")
          //                 //                   .parse(absenC
          //                 //                       .searchAbsen[i].jamAbsenMasuk!)
          //                 //                   .isBefore(DateFormat("HH:mm:ss")
          //                 //                       .parse(absenC
          //                 //                           .searchAbsen[i].jamMasuk!))
          //                 //               ? "Awal Waktu"
          //                 //               : "Telat",
          //                 //           "jam_pulang": absenC.searchAbsen[i]
          //                 //                       .jamAbsenPulang! ==
          //                 //                   ""
          //                 //               ? "Belum Absen"
          //                 //               : DateFormat("HH:mm:ss")
          //                 //                       .parse(absenC.searchAbsen[i]
          //                 //                           .jamAbsenPulang!)
          //                 //                       .isBefore(DateFormat("HH:mm:ss")
          //                 //                           .parse(absenC.searchAbsen[i]
          //                 //                               .jamPulang!))
          //                 //                   ? "Pulang Cepat"
          //                 //                   : "Lembur",
          //                 //           "jam_absen_masuk":
          //                 //               absenC.searchAbsen[i].jamAbsenMasuk!,
          //                 //           "jam_absen_pulang":
          //                 //               absenC.searchAbsen[i].jamAbsenPulang!,
          //                 //           "foto_masuk":
          //                 //               absenC.searchAbsen[i].fotoMasuk!,
          //                 //           "foto_pulang":
          //                 //               absenC.searchAbsen[i].fotoPulang!,
          //                 //           "lat_masuk":
          //                 //               absenC.searchAbsen[i].latMasuk!,
          //                 //           "long_masuk":
          //                 //               absenC.searchAbsen[i].longMasuk!,
          //                 //           "lat_pulang":
          //                 //               absenC.searchAbsen[i].latPulang!,
          //                 //           "long_pulang":
          //                 //               absenC.searchAbsen[i].longPulang!,
          //                 //           "device_info":
          //                 //               absenC.searchAbsen[i].devInfo!,
          //                 //           "device_info2":
          //                 //               absenC.searchAbsen[i].devInfo2!,
          //                 //         });
          //                 //         absenC.filterAbsen.clear();
          //                 //         absenC.filterDataAbsen("");
          //                 //       },
          //                 //       child: Container(
          //                 //         margin: const EdgeInsets.only(bottom: 20),
          //                 //         padding: const EdgeInsets.all(10),
          //                 //         decoration: BoxDecoration(
          //                 //             color: Colors.white,
          //                 //             borderRadius: BorderRadius.circular(20)),
          //                 //         child: Column(
          //                 //           crossAxisAlignment:
          //                 //               CrossAxisAlignment.start,
          //                 //           children: [
          //                 //             Row(
          //                 //               mainAxisAlignment:
          //                 //                   MainAxisAlignment.spaceBetween,
          //                 //               children: [
          //                 //                 const Text(
          //                 //                   'Masuk',
          //                 //                   style: TextStyle(
          //                 //                       fontWeight: FontWeight.bold),
          //                 //                 ),
          //                 //                 Text(
          //                 //                     DateFormat("EEEE, d MMMM yyyy",
          //                 //                             "id_ID")
          //                 //                         .format(DateTime.parse(absenC
          //                 //                             .searchAbsen[i]
          //                 //                             .tanggal!)),
          //                 //                     style: const TextStyle(
          //                 //                         fontWeight: FontWeight.bold)),
          //                 //               ],
          //                 //             ),
          //                 //             Text(
          //                 //                 absenC.searchAbsen[i].jamAbsenMasuk!),
          //                 //             const SizedBox(
          //                 //               height: 8,
          //                 //             ),
          //                 //             const Text(
          //                 //               'Keluar',
          //                 //               style: TextStyle(
          //                 //                   fontWeight: FontWeight.bold),
          //                 //             ),
          //                 //             Text(absenC.searchAbsen[i]
          //                 //                         .jamAbsenPulang !=
          //                 //                     ""
          //                 //                 ? absenC
          //                 //                     .searchAbsen[i].jamAbsenPulang!
          //                 //                 : "-"),
          //                 //           ],
          //                 //         ),
          //                 //       ),
          //                 //     );
          //                 //   },
          //                 // ),
          //               ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
