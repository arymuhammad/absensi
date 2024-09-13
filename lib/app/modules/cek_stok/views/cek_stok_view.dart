import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:get/get.dart';

import '../controllers/cek_stok_controller.dart';

class CekStokView extends GetView<CekStokController> {
  CekStokView({super.key, this.kodeCabang});

  final cekStokC = Get.put(CekStokController());
  final String? kodeCabang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.mainTextColor1),
        title: const Text('CEK STOK', style: TextStyle(color: AppColors.mainTextColor1),),
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
              child: const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                        child: const Column(
                          children: [
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
                        trailing: Text(cekStokC.dataStok[i].sisa!),
                      );
                    },
                  )),
          )
        ],
      ),
    );
  }
}
